import Array "mo:base/Array";
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
import CRC32 "mo:hash/CRC32";

import Deflate "../Deflate";
import Lzss "../LZSS";
import Header "Header";

import { nat_to_le_bytes } "../utils";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type BitBuffer<A> = BitBuffer.BitBuffer<A>;
    type Time = Time.Time;

    public type HeaderOptions = Header.HeaderOptions;
    public type DeflateOptions = Deflate.DeflateOptions;
    
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
            modification_time = ?12; // Time.now() doesn't work locally
            compression_level = #Unknown;
            os = #Unix;
        };

        var deflate_options : DeflateOptions = {
            lzss = ?Lzss.Encoder(null);
            block_size = 32 * 1024;
            dynamic_huffman = false;
        };

        public func header(options: HeaderOptions) : EncoderBuilder {
            header_options := options;
            self
        };

        public func noCompression() : EncoderBuilder{
            deflate_options := { deflate_options with lzss = null };
            header_options := { header_options with compression_level = #Unknown };
            self
        };

        public func lzss(encoder: Lzss.Encoder) : EncoderBuilder {
            deflate_options := { deflate_options with lzss = ?encoder };
            // let compression_level = lzss.compressionLevel(lzss);
            // header_options := { header_options with compression_level = #Lzss };
            self
        };

        public func blockSize(size: Nat) : EncoderBuilder {
            deflate_options := { deflate_options with block_size = size };
            self
        };

        public func build() : GzipEncoder {
            GzipEncoder(header_options, deflate_options)
        };
    };

    public func DefaultEncoder() : GzipEncoder {
        EncoderBuilder().build()
    };

    public class GzipEncoder(header_options: HeaderOptions, deflate_options: DeflateOptions) {
        var input_size = 0;
        var crc32_builder = CRC32.CRC32();
        let bitbuffer = BitBuffer.BitBuffer<Nat16>(Nat16, 8);
        
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
            case (_) { 0 /* (Time.now() / 10 ** 9)  but it doesn't work locally */ };
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
        let extra_fields = header_options.extra_fields;

        if (extra_fields.size() > 0){
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
        let deflate = Deflate.Deflate(bitbuffer, deflate_options);
        
        public func encode(bytes: [Nat8]){
            input_size += bytes.size();
            crc32_builder.update(bytes);
            deflate.encode(bytes);
        };

        // Finish and add the Footer
        public func finish() : Blob {
            ignore deflate.finish();

            // pad the bitbuffer with zero bits until it has a multiple of 8 bits
            bitbuffer.byteAlign();

            // Footer
            // - crc32
            let crc32 = crc32_builder.finish();
            bitbuffer.addBytes(nat_to_le_bytes(Nat32.toNat(crc32), 4));

            // - input size
            bitbuffer.addBytes(nat_to_le_bytes(input_size, 4));

            Blob.fromArray(BitBuffer.toBytes(bitbuffer));
        };

    };
}