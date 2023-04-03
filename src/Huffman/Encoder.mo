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
import BitReader "../BitReader";

import { nat8_to_16 } "../utils";
import Common "Common";

module {
    type Result<A, B> = Result.Result<A, B>;
    type BitBuffer = BitBuffer.BitBuffer;
    type BitReader = BitReader.BitReader;

    let { reverseCodeBits } = Common;

    public type Code = Common.Code;

    public func fromBitwidths(bitwidths : [Nat]) : Result<Encoder, Text> {
        var symbols_count = 0;

        for (bitwidth in bitwidths.vals()) {
            if (bitwidth > 0) {
                symbols_count += 1;
            };
        };

        let builder = Builder(symbols_count);

        Common.restore_huffman_codes<Encoder>(builder, bitwidths);
    };

    public func fromFrequencies(freqs : [Nat], bitwidth : Nat) : Result<Encoder, Text> {
        let max_bitwidth = Nat.min(bitwidth, 15);
        // calc bitwidths

        let bitwidthes : [Nat] = [];
        fromBitwidths(bitwidthes);
    };

    public class Builder(symbols_count : Nat) : Common.BuilderInterface<Encoder> {
        let table : [var Code] = Array.init(symbols_count, { bitwidth = 0; bits = 0 : Nat16 });

        public let setMapping = func(symbol : Nat, code : Code) :  Result<(), Text> {
            let prev_code = table[symbol];
            assert prev_code.bitwidth == 0 and prev_code.bits == 0;

            if (prev_code.bitwidth != 0 or prev_code.bits != 0) {
                return #err("symbol has already been mapped");
            };

            table[symbol] := reverseCodeBits(code);

            #ok
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

};
