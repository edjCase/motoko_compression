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
    type BitBuffer = BitBuffer.BitBuffer;
    type Time = Time.Time;

    type HeaderOptions = Header.HeaderOptions;
    type DeflateOptions = Deflate.DeflateOptions;

    public type EncodedResponse = [Nat8];

    type DeflateEncoder = {
        encode : ([Nat8]) -> ();
        finish : (BitBuffer) -> ();
    };

    type GzipEncoderParams = {
        header_options : HeaderOptions;
        deflate : DeflateEncoder;
    };

    public class EncoderBuilder() = self {
        var header_options : HeaderOptions = Header.defaultHeaderOptions();

        var deflate_options : DeflateOptions = {
            lzss = ?Lzss.Encoder(null);
            block_size = 1024 * 1024;
            dynamic_huffman = false;
        };

        public func header(options : HeaderOptions) : EncoderBuilder {
            header_options := options;
            self;
        };

        public func noCompression() : EncoderBuilder {
            deflate_options := { deflate_options with lzss = null };
            header_options := {
                header_options with compression_level = #Unknown
            };
            self;
        };

        public func lzss(encoder : Lzss.Encoder) : EncoderBuilder {
            deflate_options := { deflate_options with lzss = ?encoder };
            // let compression_level = lzss.compressionLevel(lzss);
            // header_options := { header_options with compression_level = #Lzss };
            self;
        };

        public func blockSize(size : Nat) : EncoderBuilder {
            deflate_options := { deflate_options with block_size = size };
            self;
        };

        public func build() : Encoder {
            Encoder(header_options, deflate_options);
        };
    };

    public func DefaultEncoder() : Encoder {
        EncoderBuilder().build();
    };

    public class Encoder(header_options : HeaderOptions, deflate_options : DeflateOptions) {
        var input_size = 0;
        let crc32_builder = CRC32.CRC32();
        let bitbuffer = BitBuffer.BitBuffer(8);

        func encode_header() {
            // Add Header bytes to the bitbuffer
            // - magic header
            BitBuffer.addByte(bitbuffer, 0x1f);
            BitBuffer.addByte(bitbuffer, 0x8b);

            // - compression method: deflate
            BitBuffer.addByte(bitbuffer, 8);

            // - flags
            bitbuffer.addBit(header_options.is_text);
            bitbuffer.addBit(header_options.is_verified);
            bitbuffer.addBit(header_options.extra_fields.size() > 0);
            bitbuffer.addBit(Option.isSome(header_options.filename));
            bitbuffer.addBit(Option.isSome(header_options.comment));
            bitbuffer.byteAlign();

            // - modification time
            let mtime = switch (header_options.modification_time) {
                case (?t) { t };
                case (_) { Time.now() / 10 ** 9 };
            };

            let mtime_nat = Int.abs(mtime);
            BitBuffer.addBytes(bitbuffer, nat_to_le_bytes(mtime_nat, 4));

            // - compression method flags
            let compression_level = Header.compressionLevelToByte(header_options.compression_level);
            BitBuffer.addByte(bitbuffer, compression_level);

            // - operating system
            let os = Header.osToByte(header_options.os);
            BitBuffer.addByte(bitbuffer, os);

            // - extra fields
            let extra_fields = header_options.extra_fields;

            if (extra_fields.size() > 0) {
                var fields_total_size = 0;

                for ({ data } in header_options.extra_fields.vals()) {
                    fields_total_size += (4 + data.size());
                };

                BitBuffer.addBytes(bitbuffer, nat_to_le_bytes(fields_total_size, 2));

                for (field in header_options.extra_fields.vals()) {
                    BitBuffer.addByte(bitbuffer, field.ids.0);
                    BitBuffer.addByte(bitbuffer, field.ids.1);

                    BitBuffer.addBytes(bitbuffer, nat_to_le_bytes(field.data.size(), 2));
                    BitBuffer.addBytes(bitbuffer, field.data);
                };
            };

            // - filename
            switch (header_options.filename) {
                case (?filename) {
                    let bytes = Text.encodeUtf8(filename);
                    BitBuffer.addBytes(bitbuffer, Blob.toArray(bytes));
                    BitBuffer.addByte(bitbuffer, 0);
                };
                case (_) {};
            };

            // - comment
            switch (header_options.comment) {
                case (?comment) {
                    let bytes = Text.encodeUtf8(comment);
                    BitBuffer.addBytes(bitbuffer, Blob.toArray(bytes));
                    BitBuffer.addByte(bitbuffer, 0);
                };
                case (_) {};
            };

            // - crc16
            if (header_options.is_verified) {
                let bytes = Iter.toArray(bitbuffer.bytes());

                let crc32 = CRC32.checksum(bytes);
                let crc16 = Nat32.toNat(crc32) % (2 ** 16);

                BitBuffer.addBytes(bitbuffer, nat_to_le_bytes(crc16, 2));
            };
        };

        // Compression
        let deflate = Deflate.Encoder(bitbuffer, deflate_options);

        public func encode(bytes : [Nat8]) {
            input_size += bytes.size();
            crc32_builder.update(bytes);

            if (bitbuffer.bitSize() == 0){
                encode_header();
            };

            deflate.encode(bytes);
        };

        public func clear() {
            input_size := 0;
            crc32_builder.reset();
            bitbuffer.clear();
        };

        // Finish and add the Footer
        public func finish() : [Nat8] {
            ignore deflate.finish();

            // pad the bitbuffer with zero bits until it has a multiple of 8 bits
            bitbuffer.byteAlign();

            // Footer
            // - crc32
            let crc32 = crc32_builder.finish();
            BitBuffer.addBytes(bitbuffer, nat_to_le_bytes(Nat32.toNat(crc32), 4));

            // - input size
            BitBuffer.addBytes(bitbuffer, nat_to_le_bytes(input_size, 4));

            let bytes : [Nat8] = Array.tabulate(
                bitbuffer.byteSize(),
                func (i : Nat): Nat8 = BitBuffer.getByte(bitbuffer, i * 8)
            );

            clear();
            bytes
        };
    };
};
