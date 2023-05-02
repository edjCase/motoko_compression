import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Time "mo:base/Time";

import BitBuffer "mo:bitbuffer/BitBuffer";
import CRC32 "../libs/CRC32";

import Deflate "../Deflate";
import Lzss "../LZSS";
import Header "Header";

import { nat_to_le_bytes; INSTRUCTION_LIMIT } "../utils";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type BitBuffer = BitBuffer.BitBuffer;
    type Time = Time.Time;

    type Header = Header.Header;
    type DeflateOptions = Deflate.DeflateOptions;

    public type EncodedResponse = [Nat8];

    type DeflateEncoder = {
        encode : ([Nat8]) -> ();
        finish : (BitBuffer) -> ();
    };

    type GzipEncoderParams = {
        header : Header;
        deflate : DeflateEncoder;
    };

    /// Configure the header and deflate options for a Gzip Encoder
    public class EncoderBuilder() = self {
        var _header : Header = Header.defaultHeaderOptions();

        var deflate_options : DeflateOptions = {
            lzss = ?Lzss.Encoder(null);
            block_size = INSTRUCTION_LIMIT;
            dynamic_huffman = false;
        };

        /// Configure the header options for a Gzip Encoder
        public func header(options : Header) : EncoderBuilder {
            _header := options;
            self;
        };

        public func noCompression() : EncoderBuilder {
            deflate_options := { deflate_options with lzss = null };
            _header := {
                _header with compression_level = #Unknown
            };
            self;
        };

        /// Set the huffman encoding to dynamic
        public func dynamicHuffman() : EncoderBuilder {
            deflate_options := { deflate_options with dynamic_huffman = true };
            self;
        };

        /// Set the huffman encoding to fixed
        public func fixedHuffman() : EncoderBuilder {
            deflate_options := { deflate_options with dynamic_huffman = false };
            self;
        };

        /// Set the lzss encoder
        public func lzss(lzss_encoder : Lzss.Encoder) : EncoderBuilder {
            deflate_options := { deflate_options with lzss = ?lzss_encoder };
            // let compression_level = lzss.compressionLevel(lzss);
            // _header := { _header with compression_level = #Lzss };
            self;
        };

        /// Set the block size for the encoder
        public func blockSize(size : Nat) : EncoderBuilder {
            deflate_options := { deflate_options with block_size = size };
            self;
        };

        /// Returns the configured Gzip Encoder
        public func build() : Encoder {
            Encoder(_header, deflate_options);
        };
    };

    /// Gzip Encoder
    ///
    /// ### Inputs
    /// - `header` : [Header]() - the header options for the encoder
    /// - `deflate_options` : [DeflateOptions]() - options for the deflate aglorithms
    ///
    public class Encoder(header : Header, deflate_options : DeflateOptions) {
        var input_size = 0;
        let crc32_builder = CRC32.CRC32();
        public let bitbuffer = BitBuffer.BitBuffer(8);
        var is_header_encoded = false; // created for class re-use

        // Compression
        let deflate = Deflate.Encoder(bitbuffer, deflate_options);

        /// Returns the block size for the encoder
        public func block_size() : Nat {
            deflate_options.block_size;
        };
        
        /// Compresses a byte array and adds it to the internal buffer
        public func encode(bytes : [Nat8]) {
            input_size += bytes.size();
            crc32_builder.update(bytes);

            if (not is_header_encoded) {
                is_header_encoded := true;
                Header.encode(bitbuffer, header);
            };

            deflate.encode(bytes);
        };

        /// Compresses text and adds it to the internal buffer
        public func encodeText(text : Text) {
            encode(Blob.toArray(Text.encodeUtf8(text)));
        };

        /// Compresses a Blob and adds it to the internal buffer
        public func encodeBlob(blob : Blob) {
            encode(Blob.toArray(blob));
        };

        /// Compresses data in a Buffer and adds it to the internal buffer
        public func encodeBuffer(buffer : Buffer<Nat8>) {
            encode(Buffer.toArray(buffer));
        };

        /// Clears the internal state of the encoder
        public func clear() {
            input_size := 0;
            crc32_builder.reset();
            bitbuffer.clear();
            is_header_encoded := false;
        };

        /// Returns the compressed data as a byte array and clears the internal state
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
