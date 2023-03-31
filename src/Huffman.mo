import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat16 "mo:base/Nat16";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Order "mo:base/Order";

import BitBuffer "mo:bitbuffer/BitBuffer";
import BitReader "BitReader";
import Nat8 "mo:base/Nat8";

import { nat8_to_16 } "utils";

module {
    type Result<A, B> = Result.Result<A, B>;
    type BitBuffer = BitBuffer.BitBuffer;
    type BitReader = BitReader.BitReader;

    public type Code = {
        bitwidth : Nat;
        bits : Nat16;
    };

    public func reverseCodeBits(code : Code) : Code {
        var prev = code.bits;
        var curr = 0 : Nat16;

        for (_ in Iter.range(1, code.bitwidth)) {
            curr <<= 1;
            curr |= prev & 1;
            prev >>= 1;
        };

        {
            bitwidth = code.bitwidth;
            bits = curr : Nat16;
        };
    };

    public func fromBitwidths(bitwidths : [Nat8]) : Result<Encoder, Text> {
        var symbols_count = 0;

        for (bitwidth in bitwidths.vals()) {
            if (bitwidth > 0) {
                symbols_count += 1;
            };
        };

        let builder = Builder(symbols_count);

        builder.restore_huffman_codes(bitwidths);
    };

    public func fromFrequencies(freqs : [Nat], bitwidth : Nat) : Result<Encoder, Text> {
        let max_bitwidth = Nat.min(bitwidth, 15);
        // calc bitwidths

        let bitwidthes : [Nat8] = [];
        fromBitwidths(bitwidthes);
    };

    public class Builder(symbols_count : Nat) = self {
        let table : [var Code] = Array.init(symbols_count, { bitwidth = 0; bits = 0 : Nat16 });

        public var set_mapping = func(symbol : Nat, code : Code) {
            let prev_code = table[symbol];
            assert prev_code.bitwidth == 0 and prev_code.bits == 0;
            table[symbol] := reverseCodeBits(code);
        };

        public func restore_huffman_codes(bitwidth_arr : [Nat8]) : Result<Encoder, Text> {
            if (bitwidth_arr.size() == 0) return #err("Cannot generate huffman codes from empty array");

            let bitwidth_buffer = Buffer.Buffer<(Nat, Nat8)>(8);

            var i = 0;
            for (bitwidth in bitwidth_arr.vals()) {
                if (bitwidth > 0) {
                    bitwidth_buffer.add((i, bitwidth));
                };
                i += 1;
            };

            bitwidth_buffer.sort(
                func(a : (Nat, Nat8), b : (Nat, Nat8)) : Order.Order {
                    Nat8.compare(a.1, b.1);
                }
            );

            var bits = 0 : Nat16;
            var prev_width = 0 : Nat8;

            for ((symbol, bitwidth) in bitwidth_buffer.vals()) {
                bits <<= (nat8_to_16(bitwidth) - nat8_to_16(prev_width));

                let code : Code = { bitwidth = Nat8.toNat(bitwidth); bits };
                set_mapping(symbol, code);
                bits += 1;
                prev_width := bitwidth;
            };

            #ok(build());
        };

        public func build() : Encoder {
            Encoder(table);
        };
    };

    public class Encoder(table : [var Code]) {

        public func encode(bitbuffer : BitBuffer, symbol : Nat) {
            let code = table[symbol];
            assert code != { bitwidth = 0; bits = 0 : Nat16 };
            bitbuffer.addBits(code.bitwidth, Nat16.toNat(code.bits));
        };

        public func lookup(symbol : Nat) : Code {
            assert symbol < table.size();
            table[symbol];
        };
    };

    let MAX_BITWIDTH : Nat = 15;

    public type DecoderOptions = {
        max_bitwidth : Nat;
    };

    public class DecoderBuilder(max_bitwidth : Nat) = self {
        let table = Array.init<Nat>(1 * (2 ** max_bitwidth), MAX_BITWIDTH + 1);

        public func setMapping(symbol : Nat, code : Code) : Result<(), Text>{
            assert symbol < table.size();

            if (code.bitwidth > max_bitwidth) {
                return #err("Code bitwidth is greater than max bitwidth");
            };

            let value = (Nat16.fromNat(symbol) << 5 ) | Nat16.fromNat(code.bitwidth );

            let code_be = reverseCodeBits(code);

            let possible_mappings = ( 1 * (2 ** (max_bitwidth - code.bitwidth)) ) - 1: Nat;

            for (p in Iter.range(0, possible_mappings)) {
                let padding = Nat16.fromNat(p);
                let i = Nat16.toNat((padding << Nat16.fromNat(code.bitwidth)) | code_be.bits);
                
                if (i >= table.size()){
                    return #err("Index out of bounds at i = " # debug_show i 
                    # " | table size = " # debug_show table.size() 
                    # " | padding = " # debug_show padding 
                    # " | code_be.bits = " # debug_show (code_be.bits)
                    # " | code_be.bitwidth = " # debug_show (code.bitwidth));
                };
                
                if (table[i] != MAX_BITWIDTH + 1) {
                    return #err("Bit region conflict");
                };

                table[i] := Nat16.toNat(value);
            };

            #ok()
        };

        public func build() : Decoder {
            Decoder(table, max_bitwidth);
        }
    };

    public class Decoder(table : [var Nat], max_bitwidth: Nat) {
        
        var min_bidwidth : ?Nat = null;

        public func decode(reader: BitReader) : Result<Nat, Text>{
            
            var value = 0;
            var bitwidth = 0;
            var peek_bitwidth = Option.get(min_bidwidth, 1);

            label _loop loop {
                let code = reader.peekBits(peek_bitwidth); 
                value := table[code];
                bitwidth := (value  % (2 ** 5)); /* take last 5 bits */

                if (bitwidth <= peek_bitwidth ){
                    break _loop;
                };

                if (bitwidth > max_bitwidth) {
                    Debug.print(debug_show (table, max_bitwidth));
                    return #err("Invalid bitwidth " # debug_show bitwidth # " at position " # debug_show reader.getPosition() # " (max bitwidth is " # debug_show max_bitwidth # ") peeked: " # debug_show (peek_bitwidth) # " code: " # debug_show (code) # " value: " # debug_show (value) # " table size: " # debug_show (table.size()) );
                };

                peek_bitwidth := bitwidth;
            };

            reader.skipBits(bitwidth);

            switch (min_bidwidth){
                case (null) min_bidwidth := ?bitwidth;
                case (?n) min_bidwidth := ?Nat.min(n, bitwidth);
            };

            let decoded = value / (2 ** 5); /* == value >> 5 */
            #ok(decoded)
        };
    };

};
