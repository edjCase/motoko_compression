import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Nat16 "mo:base/Nat16";
import Iter "mo:base/Iter";

import BitBuffer "mo:bitbuffer/BitBuffer";

import Common "../LZSS/Common";
import Utils "../utils";
import Huffman "../Huffman";

module {
    type BitBuffer<A> = BitBuffer.BitBuffer<A>;

    public type Symbol = Common.LZSSEntry or {
        #end_of_block;
    };

    let FIXED_LENGTH_CODES : [{
        bitwidth : Nat;
        symbol_start : Nat;
        symbol_end : Nat;
        base_code : Nat16;
    }] = [
        {
            bitwidth = 8;
            symbol_start = 0;
            symbol_end = 143;
            base_code = 0x30;
        },
        {
            bitwidth = 9;
            symbol_start = 144;
            symbol_end = 255;
            base_code = 0x190;
        },
        {
            bitwidth = 7;
            symbol_start = 256;
            symbol_end = 279;
            base_code = 0x00;
        },
        {
            bitwidth = 8;
            symbol_start = 280;
            symbol_end = 287;
            base_code = 0xc0;
        },
    ];

    /// Encodes the literal and length Deflate Symbol to Nat16 and returns the extra bits
    public func lengthCode(symbol : Symbol) : (Nat16, Nat, Nat16) {
        switch symbol {
            case (#end_of_block) { (256, 0, 0) };

            case (#literal(byte)) { (Utils.nat8_to_16(byte), 0, 0) };

            case (#pointer(_, length)) {
                if (length > 258 or length < 3) {
                    Debug.trap("Invalid deflate distance pair: length '" # debug_show (length) # "' is out of range 3 <= length <= 258");
                };

                let len16 = Nat16.fromNat(length);

                var marker = 0 : Nat16;
                var extra_bits = 0;
                var offset = 0 : Nat16;

                if (len16 <= 10) {
                    marker := 257 + (len16 - 3);
                } else if (len16 <= 18) {
                    marker := 265 + ((len16 - 11) / 2);
                    extra_bits := 1;
                    offset := (len16 - 11) % 2;
                } else if (len16 <= 34) {
                    marker := 269 + ((len16 - 19) / 4);
                    extra_bits := 2;
                    offset := (len16 - 19) % 4;
                } else if (len16 <= 66) {
                    marker := 273 + ((len16 - 35) / 8);
                    extra_bits := 3;
                    offset := (len16 - 35) % 8;
                } else if (len16 <= 130) {
                    marker := 277 + ((len16 - 67) / 16);
                    extra_bits := 4;
                    offset := (len16 - 67) % 16;
                } else if (len16 <= 257) {
                    marker := 281 + ((len16 - 131) / 32);
                    extra_bits := 5;
                    offset := (len16 - 131) % 32;
                } else {
                    marker := 285;
                };

                (marker, extra_bits, offset);
            };
        };
    };

    public let MAX_DISTANCE = 32768;
    public func distanceCode(symbol : Symbol) : ?(Nat, Nat, Nat16) {
        switch (symbol) {
            case (#pointer(distance, _)) {
                if (distance > MAX_DISTANCE or distance == 0) {
                    Debug.trap("Invalid deflate distance pair: distance '" # debug_show (distance) # "' is out of range 1 <= distance <= 32768");
                };

                if (distance >= 1 and distance <= 4) {
                    ?(distance - 1, 0, 0);
                } else {
                    var extra_bits = 1;
                    var base = 4;
                    var marker = 4;

                    while (base * 2 < distance) {
                        extra_bits += 1;
                        marker += 2;
                        base *= 2;
                    };

                    let half = base / 2;
                    let delta = (distance - base - 1) : Nat;

                    let offset = Nat16.fromNat(delta % half);
                    if (distance <= base + half) {
                        ?(marker, extra_bits, offset);
                    } else {
                        ?(marker + 1, extra_bits, offset);
                    };
                };
            };
            case (_) null;
        };
    };

    public class Encoder(literal_encoder : Huffman.Encoder, distance_encoder : Huffman.Encoder) {
        public func encode(bitbuffer : BitBuffer<Nat16>, symbol : Symbol) {

            let (marker, extra_bits, offset) = lengthCode(symbol);
            literal_encoder.encode(bitbuffer, Nat16.toNat(marker));

            if (extra_bits > 0) {
                bitbuffer.addBits(extra_bits, offset);
            };

            switch (distanceCode(symbol)) {
                case (?(marker, extra_bits, offset)) {
                    distance_encoder.encode(bitbuffer, marker);
                    if (extra_bits > 0){
                        bitbuffer.addBits(extra_bits, offset);
                    };
                };
                case (null) {};
            };
        };
    };

    public class FixedCodec() {

        public func build() : Encoder {
            let literal_builder = Huffman.Builder(288);

            for (
                {
                    bitwidth;
                    symbol_start;
                    symbol_end;
                    base_code;
                } in FIXED_LENGTH_CODES.vals()
            ) {

                for (symbol in Iter.range(symbol_start, symbol_end)) {
                    let code = {
                        bitwidth;
                        bits = base_code + Nat16.fromNat(symbol - symbol_start);
                    };

                    literal_builder.set_mapping(symbol, code);
                };

            };

            let literal_encoder = literal_builder.build();

            let distance_builder = Huffman.Builder(30);

            for (symbol in Iter.range(0, 29)) {
                let code = { bitwidth = 5; bits = Nat16.fromNat(symbol) };

                distance_builder.set_mapping(symbol, code);
            };

            let distance_encoder = distance_builder.build();

            Encoder(literal_encoder, distance_encoder);
        };

        public func save() {};

    };
};
