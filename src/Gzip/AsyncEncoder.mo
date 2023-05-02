
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Prelude "mo:base/Prelude";
import Timer "mo:base/Timer";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";

import ArrayMod "mo:array/Array";
import CRC32 "../libs/CRC32";
import BitBuffer "mo:bitbuffer/BitBuffer";
import BufferDeque "mo:buffer-deque/BufferDeque";
import Itertools "mo:itertools/Iter";

import Lzss "../LZSS";
import Header "Header";
import Deflate "../Deflate";

import { nat_to_le_bytes; INSTRUCTION_LIMIT } "../utils";

module {
    type Header = Header.Header;
    type DeflateOptions = Deflate.DeflateOptions;
    type BitBuffer = BitBuffer.BitBuffer;
    type Buffer<A> = Buffer.Buffer<A>;
    type Iter<A> = Iter.Iter<A>;
    type Result<A, B> = Result.Result<A, B>;

    type OnCompleteFn = (Result<[Nat8], ()>) -> ();

    public class AsyncEncoderBuilder(data_size : Nat) = self {
        var _header : Header = Header.defaultHeaderOptions();

        var deflate_options : DeflateOptions = {
            lzss = ?Lzss.Encoder(null);
            block_size = INSTRUCTION_LIMIT;
            dynamic_huffman = false;
        };

        public func header(options : Header) : AsyncEncoderBuilder {
            _header := options;
            self;
        };

        public func noCompression() : AsyncEncoderBuilder {
            deflate_options := { deflate_options with lzss = null };
            _header := {
                _header with compression_level = #Unknown
            };
            self;
        };

        public func dynamicHuffman() : AsyncEncoderBuilder {
            deflate_options := { deflate_options with dynamic_huffman = true };
            self;
        };

        public func fixedHuffman() : AsyncEncoderBuilder {
            deflate_options := { deflate_options with dynamic_huffman = false };
            self;
        };

        public func lzss(encoder : Lzss.Encoder) : AsyncEncoderBuilder {
            deflate_options := { deflate_options with lzss = ?encoder };
            // let compression_level = lzss.compressionLevel(lzss);
            // _header := { _header with compression_level = #Lzss };
            self;
        };

        public func blockSize(size : Nat) : AsyncEncoderBuilder {
            deflate_options := { deflate_options with block_size = size };
            self;
        };

        public func build() : AsyncEncoder {
            AsyncEncoder(data_size, _header, deflate_options);
        };
    };

    public class AsyncEncoder(data_size: Nat, header : Header, deflate_options : DeflateOptions){
        var input_size = 0;
        let crc32_builder = CRC32.CRC32();
        let bitbuffer = BitBuffer.BitBuffer(8);

        Header.encode(bitbuffer, header);

        // let { block_size } = deflate_options;
        let block_size = 500_000;

        let input_buffer = BufferDeque.BufferDeque<Nat8>(8);
        let expected_chunks = (data_size + block_size - 1 : Nat / block_size);
        let output_buffer = Array.init<?BitBuffer>(expected_chunks, null);

        var chunk_index = 0;

        var onCompleteFn : OnCompleteFn = func (buffer){
            Debug.trap("Failed to set a callback for AsyncEncoder.onComplete()");
        };

        public func encode(bytes: [Nat8]){
            crc32_builder.update(bytes);

            for (byte in bytes.vals()){
                input_buffer.addBack(byte);
            };

            while (input_buffer.size() >= block_size){
                let chunk = input_buffer.removeRange(0, block_size);
                encode_chunk(chunk_index, chunk);
                chunk_index += 1;
                input_size += chunk.size();
            };
        };

        public func finish() {
            if (input_buffer.size() > 0){
                let chunk = input_buffer.removeRange(0, input_buffer.size());
                encode_chunk(chunk_index, chunk);
                chunk_index += 1;
                input_size += chunk.size();
            };

            Debug.print("chunk_index = " # debug_show chunk_index # "| expected_chunks = " # debug_show expected_chunks);
            // assert chunk_index == expected_chunks;
            // assert input_size == data_size;
        };

        func is_complete() : Bool {
            Itertools.all(output_buffer.vals(), Option.isSome);
        };

        func append_async_output(){
            for (opt_chunk in output_buffer.vals()){
                let ?chunk = opt_chunk else Prelude.unreachable();

                while (chunk.bitSize() > 0){
                    let nbits = Nat.min(8, chunk.bitSize());
                    let bits = chunk.getBits(0, nbits);
                    chunk.dropBits(nbits);
                    bitbuffer.addBits(bits, nbits);
                };
            };
            
        };

        public func onComplete(fn: OnCompleteFn){
            onCompleteFn := fn;
        };

        func encode_footer(){
            bitbuffer.byteAlign();

            let crc32 = crc32_builder.finish();
            BitBuffer.addBytes(bitbuffer, nat_to_le_bytes(Nat32.toNat(crc32), 4));

            // - input size
            BitBuffer.addBytes(bitbuffer, nat_to_le_bytes(input_size, 4));
        };

        func encode_chunk(index: Nat, chunk: [Nat8]) {
            ignore Timer.setTimer(#seconds(0), func () : async (){
                Debug.print("Encoding chunk: " # debug_show index # " of size: " # debug_show  chunk.size());

                let compressed = BitBuffer.BitBuffer(8);
                let deflate = Deflate.Encoder(compressed, deflate_options);
                deflate.encode(chunk);
                ignore deflate.finish();
                output_buffer[index] := ?compressed;

                Debug.print("Finished encoding chunk: " # debug_show index # " of size: " # debug_show  chunk.size());

                if (is_complete()){
                    append_async_output();
                    encode_footer();

                    let bytes : [Nat8] = Array.tabulate(
                        bitbuffer.byteSize(),
                        func (i : Nat): Nat8 = BitBuffer.getByte(bitbuffer, i * 8)
                    );

                    onCompleteFn(#ok(bytes));
                };
            });
        };

    };
}