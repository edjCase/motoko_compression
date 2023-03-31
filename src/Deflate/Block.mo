import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Deque "mo:base/Deque";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Option "mo:base/Option";
import Iter "mo:base/Iter";

import BitBuffer "mo:bitbuffer/BitBuffer";

import Lzss "../LZSS";
import Symbol "Symbol";
import Huffman "../Huffman";

import { nat_to_le_bytes } "../utils";

module {
    type BitBuffer = BitBuffer.BitBuffer;

    public let NO_COMPRESSION_MAX_BLOCK_SIZE = 65535;

    public type BlockType = {
        #Raw;
        #Fixed;
        #Dynamic;
    };

    public func blockToNat(blockType : BlockType) : Nat {
        switch blockType {
            case (#Raw) 0;
            case (#Fixed) 1;
            case (#Dynamic) 2;
        };
    };

    public func natToBlock(byte : Nat) : BlockType {
        switch byte {
            case 0 (#Raw);
            case 1 (#Fixed);
            case 2 (#Dynamic);
            case _ Debug.trap("Invalid block type");
        };
    };

    public type BlockInterface = {
        size : () -> Nat;
        append : ([Nat8]) -> ();
        flush : (BitBuffer) -> ();
    };

    public func Block(block_type: BlockType, opt_lzss: ?Lzss.Encoder): BlockInterface {
        switch block_type {
            case (#Raw) Raw();
            case (_block_type) {
                if (Option.isNull(opt_lzss)) {
                    Debug.trap("LZSS encoder is required for fixed and dynamic blocks");
                };

                let lzss = Option.get(opt_lzss, Lzss.Encoder(null));
                
                switch(_block_type) {
                    case (#Fixed)  Compress(lzss, Symbol.FixedHuffmanCodec());
                    case (#Dynamic) Compress(lzss, Symbol.FixedHuffmanCodec());
                    case _ Debug.trap("Invalid block type");
                };
            };
        };
    };

    public class Raw() {
        var deque = Deque.empty<Nat8>();
        var input_size = 0;
        var byte_aligned = false;

        public func size() : Nat { input_size; };

        public func append(bytes : [Nat8]) {
            input_size += bytes.size();

            for (byte in bytes.vals()) {
                deque := Deque.pushBack<Nat8>(deque, byte);
            };
        };

        public func flush(bitbuffer : BitBuffer) {
            if (not byte_aligned) {
                bitbuffer.byteAlign();
                byte_aligned := true;
            };

            let size = Nat.min(NO_COMPRESSION_MAX_BLOCK_SIZE, input_size);

            let size_as_bytes = nat_to_le_bytes(size, 2);
            BitBuffer.addBytes(bitbuffer, size_as_bytes);

            let bitnot_size_as_bytes = Array.map<Nat8, Nat8>(size_as_bytes, func(x : Nat8) { ^x });
            BitBuffer.addBytes(bitbuffer, bitnot_size_as_bytes);

            for (i in Iter.range(0, size - 1)) {
                let ?(byte, xs) = Deque.popFront<Nat8>(deque) else { return };
                deque := xs;
                input_size -= 1;
                BitBuffer.addByte(bitbuffer, byte);
            };
        };
    };

    public class Compress(lzss : Lzss.Encoder, huffman : Symbol.FixedHuffmanCodec) {
        var input_size = 0;
        let buffer = Buffer.Buffer<Symbol.Symbol>(8);
        
        public func size() : Nat {
            return input_size;
        };

        public func append(bytes : [Nat8]) {
            input_size += bytes.size();
            let sink = {
                add = func  (symbol: Lzss.LZSSEntry) {
                    buffer.add(symbol);
                };
            };
            
            lzss.encode(bytes, sink);
        };

        public func flush(bitbuffer : BitBuffer) {
            let symbol_encoder_rs = huffman.build(buffer);
            let #ok(symbol_encoder) = huffman.build(buffer) else {
                return;
            };

            for (symbol in buffer.vals()){
                symbol_encoder.encode(bitbuffer, symbol);
            };

            symbol_encoder.encode(bitbuffer, #end_of_block);

            input_size := 0;
            buffer.clear();
        };

    };
};
