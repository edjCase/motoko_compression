import Buffer "mo:base/Buffer";

import It "mo:itertools/Iter";

import Common "Common";
import Utils "../utils";

module {
    public type BlockCode = {
        #lzss : Common.LZSSEntry;
        #end;
    };

    /// encode LZSS entry to bytes
    public func encode(entry : BlockCode) : Nat16 {
        switch entry {
            case (#end) { 256 : Nat16 };

            case (#lzss(#literal(byte))) { Utils.nat8_to_16(byte) };

            case (#lzss(#pointer(offset, length))) {
                // let offset_bytes = Buffer.fromNat16(offset);
                // let length_bytes = Buffer.fromNat16(length);
                // [0x01, offset_bytes[0], offset_bytes[1], length_bytes[0], length_bytes[1]];
                0
            };
        };
    };
};
