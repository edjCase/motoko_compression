import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";

import BitBuffer "mo:bitbuffer/BitBuffer";

import Block "../LZSS/Block";
import Symbol "Symbol";
import LZSS "../LZSS";
import LzssEncoder "../LZSS/Encoder";
import { nat_to_le_bytes } "../utils";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type BitBuffer<A> = BitBuffer.BitBuffer<A>;
    type Iter<A> = Iter.Iter<A>;
    type LZSSEntry = LZSS.LZSSEntry;
    type LzssEncoder = LzssEncoder.Encoder;
    type Symbol = Symbol.Symbol;

    public type DeflateOptions = {
        block_size: Nat;
        dynamic_huffman: Bool;
        lzss: ?LzssEncoder;
    };

    public let NO_COMPRESSION_MAX_BLOCK_SIZE = 65535;

    public class Deflate(
        max_block_size: Nat,
        is_dynamic_huffman: Bool,
        lzss: ?LzssEncoder,
    ) {

        let block_type = switch(lzss){
            case (null) { #Raw };
            case (?lzss) { 
                if(is_dynamic_huffman){
                    #Dynamic
                } else {
                    #Fixed
                }
            };
        };

        let buffer = Buffer.Buffer<Nat8>(max_block_size);
        let lzss_buffer = Buffer.Buffer<Symbol>(8);
        let symbol_buffer = BitBuffer.BitBuffer<Nat16>(Nat16, 8);
        let block_buffer = BitBuffer.BitBuffer<Nat16>(Nat16, 8);

        public func encode(data: [Nat8]) {

            for (byte in data.vals()){
                buffer.add(byte);

                if (buffer.size() >= max_block_size){
                    ignore do? {
                        let encoding = lzss!.encodeToIter(Buffer.toArray(buffer));
                        
                        for (entry in encoding){
                            lzss_buffer.add(entry);
                        };

                        lzss_buffer.add(#end_of_block);

                        buffer.clear();

                        for (entry in lzss_buffer.vals()){
                            let n16 = Symbol.toNat16(entry);
                            let size = 1;

                            symbol_buffer.addBits(size, n16);
                        };

                        encode_block(false);
                    };

                    // add end of block marker

                };
            };
        };

        func encode_block(is_final: Bool) {
            bitbuffer.add(is_final);

            switch(block_type){
                case (#Raw) {
                    bitbuffer.addBits(2, 0);
                    bitbuffer.byteAlign();

                    let size = Nat.min(NO_COMPRESSION_MAX_BLOCK_SIZE, buffer.size());
                    let size_as_bytes = nat_to_le_bytes(size, 2);
                    bitbuffer.addBits(16, size_as_bytes);

                    let bitnot_size_as_bytes = Array.map(2, func (x: Nat8) { ^x });
                    bitbuffer.addBits(16, bitnot_size_as_bytes);

                    for (i in Iter.range(0, size - 1)){
                        bitbuffer.addByte(buffer.get(i));
                    };

                    buffer.remove(0, size);
                };
                case (#Fixed) {
                    bitbuffer.addBits(2, 1);
                    // lzss.encode(buffer);
                    // lzss.flush(lzss_buffer);
                };
                case (#Dynamic) {
                    bitbuffer.addBits(2, 2);
                };
            }
        };
    };
};