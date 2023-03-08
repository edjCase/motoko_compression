import Buffer "mo:base/Buffer";

import It "mo:itertools/Iter";

import Common "../LZSS/Common";
import Utils "../utils";

module {
    public type Symbol = Common.LZSSEntry or {
        #end_of_block;
    };

    /// encode LZSS entry to bytes
    public func toNat16(entry : Symbol) : Nat16 {
        switch entry {
            case (#end_of_block) { 256 : Nat16 };

            case (#literal(byte)) { Utils.nat8_to_16(byte) };

            case (#pointer(offset, length)) {
                // let offset_bytes = Buffer.fromNat16(offset);
                // let length_bytes = Buffer.fromNat16(length);
                // [0x01, offset_bytes[0], offset_bytes[1], length_bytes[0], length_bytes[1]];
                0
            };
        };
    };
};
