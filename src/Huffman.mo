import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat16 "mo:base/Nat16";

import BitBuffer "mo:bitbuffer/BitBuffer";

module {

    public type Code = {
        bitwidth : Nat;
        bits : Nat16;
    };

    public func reverseCodeBits(code: Code): Code {
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
        }
    };

    type BitBuffer<NatX> = BitBuffer.BitBuffer<NatX>;
    
    public class Builder(symbols_count : Nat) = self {
        let table : [var Code] = Array.init(symbols_count, { bitwidth = 0; bits = 0 : Nat16 });
        
        public var set_mapping = func(symbol: Nat, code: Code) {
            let prev_code = table[symbol];
            assert prev_code.bitwidth == 0 and prev_code.bits == 0;
            table[symbol] := reverseCodeBits(code);
        };

        public func build() : Encoder {
            Encoder(table);
        };
    };

    public class Encoder(table : [var Code]) {
        public func encode(bitbuffer: BitBuffer<Nat16>, symbol : Nat) {
            let code = table[symbol];
            assert code != { bitwidth = 0; bits = 0 : Nat16 };
            bitbuffer.addBits(code.bitwidth, code.bits);
        };

        public func lookup(symbol : Nat) : Code {
            assert symbol < table.size();
            table[symbol]
        };
    };

};
