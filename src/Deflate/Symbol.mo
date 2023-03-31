import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Iter "mo:base/Iter";
import Result "mo:base/Result";

import BitBuffer "mo:bitbuffer/BitBuffer";

import Common "../LZSS/Common";
import Utils "../utils";
import Huffman "../Huffman";
import BitReader "../BitReader";

module {
    type BitBuffer = BitBuffer.BitBuffer;
    type BitReader = BitReader.BitReader;

    type Buffer<A> = Buffer.Buffer<A>;
    type Result<A, B> = Result.Result<A, B>;

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

    let BITWIDTH_CODE_ORDER: [Nat] = [
        16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15,
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

        public func encode(bitbuffer : BitBuffer, symbol : Symbol) {

            let (marker, extra_bits, offset) = lengthCode(symbol);
            literal_encoder.encode(bitbuffer, Nat16.toNat(marker));

            if (extra_bits > 0) {
                bitbuffer.addBits(extra_bits, Nat16.toNat(offset));
            };

            switch (distanceCode(symbol)) {
                case (?(marker, extra_bits, offset)) {
                    distance_encoder.encode(bitbuffer, marker);
                    if (extra_bits > 0) {
                        bitbuffer.addBits(extra_bits, Nat16.toNat(offset));
                    };
                };
                case (null) {};
            };
        };
    };

    let LENGTH_TABLE : [(Nat, Nat)] = [
        (3, 0),
        (4, 0),
        (5, 0),
        (6, 0),
        (7, 0),
        (8, 0),
        (9, 0),
        (10, 0),
        (11, 1),
        (13, 1),
        (15, 1),
        (17, 1),
        (19, 2),
        (23, 2),
        (27, 2),
        (31, 2),
        (35, 3),
        (43, 3),
        (51, 3),
        (59, 3),
        (67, 4),
        (83, 4),
        (99, 4),
        (115, 4),
        (131, 5),
        (163, 5),
        (195, 5),
        (227, 5),
        (258, 0),
    ];

    let DISTANCE_TABLE: [(Nat, Nat)] = [
        (1, 0),
        (2, 0),
        (3, 0),
        (4, 0),
        (5, 1),
        (7, 1),
        (9, 2),
        (13, 2),
        (17, 3),
        (25, 3),
        (33, 4),
        (49, 4),
        (65, 5),
        (97, 5),
        (129, 6),
        (193, 6),
        (257, 7),
        (385, 7),
        (513, 8),
        (769, 8),
        (1025, 9),
        (1537, 9),
        (2049, 10),
        (3073, 10),
        (4097, 11),
        (6145, 11),
        (8193, 12),
        (12_289, 12),
        (16_385, 13),
        (24_577, 13),
    ];

    public class Decoder(literal_decoder : Huffman.Decoder, distance_decoder : Huffman.Decoder) {
        public func decode(reader: BitReader) : Result<Symbol, Text> {
            let symbol_res = decode_literal(reader);

            let #ok(symbol) = symbol_res else return symbol_res;

            let #pointer(_, length) = symbol else return #ok(symbol);

            let bwd_res = decode_distance(reader);
            
            let backward_distance = switch(bwd_res){
                case(#ok(backward_distance)) backward_distance;
                case(#err(msg)) return #err(msg);
            };

            let back_ref = #pointer(backward_distance, length);

            #ok(back_ref);
        };

        func decode_literal(reader : BitReader) : Result<Symbol, Text> {
            let res = literal_decoder.decode(reader);

            let val = switch(res){
                case (#ok(val)) val;
                case (#err(msg)) return #err(msg);
            };

            let symbol = if (val >= 0 and val <= 255) {
                #literal(Nat8.fromNat(val));
            } else if (val == 256) {
                #end_of_block;
            } else if (val == 286 or val == 287) {
                return #err(
                    "Invalid deflate symbol " # debug_show (val) # ". Values 286 and 287 should not be in the compressed bytes."
                );
            } else {
                let (base, extra_bits) = LENGTH_TABLE[val - 257];
                let extra = reader.readBits(extra_bits);

                #pointer(0, base + extra);
            };

            #ok(symbol)
        };

        func decode_distance(reader: BitReader) : Result<Nat, Text> {
            let res = distance_decoder.decode(reader);

            let val = switch(res){
                case (#ok(val)) val;
                case (#err(msg)) return #err(msg);
            };

            let (base, extra_bits) = DISTANCE_TABLE[val];
            let distance = base + reader.readBits(extra_bits);

            #ok(distance)
        };  
    };

    public type HuffmanCodec = {
        build : (Buffer<Symbol>) -> Result<Encoder, Text>;
        save : () -> ();
        load : (BitReader) -> Result<Decoder, Text>;
    };

    public class FixedHuffmanCodec() : HuffmanCodec {

        public func build(_ : Buffer<Symbol>) : Result<Encoder, Text> {
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

            #ok(Encoder(literal_encoder, distance_encoder));
        };

        public func save() {};

        public func load(reader : BitReader) : Result<Decoder, Text> {
            let literal_decoder = Huffman.DecoderBuilder(9);

            for ({
                bitwidth;
                symbol_start;
                symbol_end;
                base_code;
            } in FIXED_LENGTH_CODES.vals()) {
                for (symbol in Iter.range(symbol_start, symbol_end)) {
                    let code = {
                        bitwidth;
                        bits = base_code + Nat16.fromNat(symbol - symbol_start);
                    };

                    let res = literal_decoder.setMapping(symbol, code);
                    switch(res){
                        case(#ok(_)) ();
                        case(#err(msg)) return #err(msg);
                    };
                };
            };

            let distance_decoder = Huffman.DecoderBuilder(5);

            for (symbol in Iter.range(0, 29)) {
                let code = { bitwidth = 5; bits = Nat16.fromNat(symbol) };

                let res = distance_decoder.setMapping(symbol, code);
                    switch(res){
                        case(#ok(_)) ();
                        case(#err(msg)) return #err(msg);
                    };
            };

            let symbol_decoder = Decoder(literal_decoder.build(), distance_decoder.build());
            #ok(symbol_decoder)
        };
    };

    public class DynamicHuffmanCodec() : HuffmanCodec {
        public func build(symbols : Buffer<Symbol>) : Result<Encoder, Text> {
            let literal_freq = Array.init<Nat>(288, 0);
            let distance_freq = Array.init<Nat>(30, 0);

            for (symbol in symbols.vals()) {
                let (marker, _, _) = lengthCode(symbol);
                literal_freq[Nat16.toNat(marker)] += 1;

                ignore do ? {
                    let (marker, _, _) = distanceCode(symbol)!;
                    distance_freq[marker] += 1;
                };
            };

            let literal_result = Huffman.fromFrequencies(Array.freeze(literal_freq), 15);
            let literal_encoder = switch (literal_result) {
                case (#ok(encoder)) encoder;
                case (#err(err)) return #err(err);
            };

            let distance_result = Huffman.fromFrequencies(Array.freeze(distance_freq), 15);
            let distance_encoder = switch (distance_result) {
                case (#ok(encoder)) encoder;
                case (#err(err)) return #err(err);
            };

            #ok(Encoder(literal_encoder, distance_encoder));
        };

        public func save() {
            
        };

        let MAX_DISTANCE_CODE_COUNT = 30;

        public func load(reader : BitReader) : Result<Decoder, Text> {
            let literal_code_count = reader.readBits(5) + 257;
            let distance_code_count = reader.readBits(5) + 1;
            let bitwidth_code_count = reader.readBits(4) + 4;

            if (distance_code_count > MAX_DISTANCE_CODE_COUNT) {
                return #err("The value of HDIST is too big: max="# debug_show (MAX_DISTANCE_CODE_COUNT) # ", actual="# debug_show (distance_code_count));
            };

            let bitwidths = Array.init<Nat>(19, 0);

            for (i in Iter.range(1, bitwidth_code_count)) {
                bitwidths[i - 1] := reader.readBits(3);
            };

            let bitwidth_decoder = Huffman.DecoderBuilder(7);

            


            #err("Dynamic Huffman codec cannot be saved or loaded");
        };
    };
};
