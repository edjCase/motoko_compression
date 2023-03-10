import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";

import BitBuffer "mo:bitbuffer/BitBuffer";

import Block "Block";
import Symbol "Symbol";
import LZSS "../LZSS";
import LzssEncoder "../LZSS/Encoder";

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

    public class Deflate(
        bitbuffer : BitBuffer<Nat16>,
        options: DeflateOptions
    ) {

        let block_type = switch(options.lzss){
            case (null) { #Raw };
            case (?_) { 
                if(options.dynamic_huffman){
                    #Dynamic
                } else {
                    #Fixed
                }
            };
        };
        
        let block = Block.Block(block_type, options.lzss);

        public func encode(data: [Nat8]) {
            block.append(data);

            while (block.size() > options.block_size){
                flush(false);
            };
        };
        
        public func flush(is_final : Bool) {
            bitbuffer.add(is_final);
            bitbuffer.addBits(2, Nat16.fromNat(Block.blockToNat(block_type)));
            block.flush(bitbuffer);
        };

        public func finish(): BitBuffer<Nat16> {
            flush(true);
            return bitbuffer;
        };
    };
};