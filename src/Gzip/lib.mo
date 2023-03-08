import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Time "mo:base/Time";

import BitBuffer "mo:bitbuffer/BitBuffer";
import CRC32 "../deps/CRC32";
import NatX "mo:xtended-numbers/NatX";

import Deflate "../Deflate";
import Header "Header";
import { nat_to_le_bytes } "../utils";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type BitBuffer<A> = BitBuffer.BitBuffer<A>;
    type Time = Time.Time;

    public type HeaderOptions = Header.HeaderOptions;
    public type DeflateOptions = Header.DeflateOptions;
    
    type DeflateEncoder = {
        encode: ([Nat8]) -> ();
        finish: (BitBuffer<Nat32>) -> (); 
    };

    type GzipEncoderParams = {
        header_options : HeaderOptions;
        deflate: DeflateEncoder;
    };

    public class EncoderBuilder() = self {
        var header_options: HeaderOptions = {
            is_text = false;
            is_verified = false;
            extra_fields = [];
            filename = null;
            comment = null;
            modification_time = ?Time.now();
            os = #Unix;
        };

        var deflate_options : DeflateOptions = {
            lzss = null;
            block_size = 32 * 1024;
            dynamic_huffman = true;
        };

        public func header(options: HeaderOptions) : EncoderBuilder {
            header_options := options;
            self
        };

        public func noCompresstion() : EncoderBuilder{
            deflate_options := { deflate_options with lzss = null };
            header_options := { header_options with compression_level = #Unknown };
            self
        };

        public func lzss(lzss: Lzss) : EncoderBuilder {
            deflate_options := { deflate_options with lzss = lzss };
            // let compression_level = lzss.compressionLevel(lzss);
            // header_options := { header_options with compression_level = #Lzss };
            self
        };

        public func blockSize(size: Nat32) : EncoderBuilder {
            deflate_options := { deflate_options with block_size = size };
            self
        };

        public func build() : GZipEncoder {
            GzipEncoder(header_options, deflate_options)
        };
    };

    public func DefaultEncoder() : GzipEncoder {
        EncoderBuilder().build()
    };

    public class GzipEncoder(header_options: HeaderOptions, deflate_options: DeflateOptions) {
        var input_size = 0;
        var crc32 : Nat32 = 0;
        let bitbuffer = BitBuffer.BitBuffer<Nat32>(Nat32, 8);
        
        // Add Header bytes to the bitbuffer
        // - magic header
        bitbuffer.addByte(0x1f);
        bitbuffer.addByte(0x8b);

        // - compression method: deflate
        bitbuffer.addByte(8);

        // - flags
        bitbuffer.add(header_options.is_text);
        bitbuffer.add(header_options.is_verified);
        bitbuffer.add(header_options.extra_fields.size() > 0);
        bitbuffer.add(Option.isSome(header_options.filename));
        bitbuffer.add(Option.isSome(header_options.comment));
        bitbuffer.addBits(3, 0);

        // - modification time
        let mtime = switch(header_options.modification_time) {
            case (?t) { t };
            case (_) { Time.now() / 10 ** 9 };
        };

        let mtime_nat = Int.abs(mtime);
        bitbuffer.addBytes(nat_to_le_bytes(mtime_nat, 4));

        // - compression method flags
        let extra_flags = Header.compressionLevelToByte(header_options.compression_level);
        bitbuffer.addByte(extra_flags);

        // - operating system
        let os = Header.osToByte(header_options.os);
        bitbuffer.addByte(os);

        // - extra fields
        var fields_total_size = 0;

        for ({data} in header_options.extra_fields.vals()){
            fields_total_size += (4 + data.size());
        };
        
        bitbuffer.addBytes(nat_to_le_bytes(fields_total_size, 2));

        for (field in header_options.extra_fields.vals()){
            bitbuffer.addByte(field.ids.0);
            bitbuffer.addByte(field.ids.1);

            bitbuffer.addBytes(nat_to_le_bytes(field.data.size(), 2));
            bitbuffer.addBytes(field.data);
        };

        // - filename
        switch(header_options.filename) {
            case (?filename) {
                let bytes = Text.encodeUtf8(filename);
                bitbuffer.addBytes(Blob.toArray(bytes));
                bitbuffer.addByte(0);
            };
            case (_) {};
        };

        // - comment
        switch(header_options.comment) {
            case (?comment) {
                let bytes = Text.encodeUtf8(comment);
                bitbuffer.addBytes(Blob.toArray(bytes));
                bitbuffer.addByte(0);
            };
            case (_) {};
        };

        // - crc16
        if (header_options.is_verified) {
            let bytes = BitBuffer.toBytes(bitbuffer);

            let crc32 = CRC32.checksum(bytes);
            let crc16 = Nat32.toNat(crc32) % (2 ** 16);

            bitbuffer.addBytes(nat_to_le_bytes(crc16, 2));
        };


        // Compression
        public func encode(bytes: [Nat8]){
            input_size += bytes.size();
            crc32 := CRC32.update(crc32, bytes);
            deflate.encode(bytes);
        };

        // Finish and add the Footer
        public func finish() : Blob {
            deflate.finish(bitbuffer);

            // pad the bitbuffer with zero bits until it has a multiple of 8 bits
            bitbuffer.byteAlign();

            // Footer
            // - crc32
            let crc = Nat32.toNat(crc32);
            bitbuffer.addBytes(nat_to_le_bytes(crc, 4));

            // - input size
            bitbuffer.addBytes(nat_to_le_bytes(input_size, 4));

            Blob.fromArray(BitBuffer.toBytes(bitbuffer));
        };

    };
}