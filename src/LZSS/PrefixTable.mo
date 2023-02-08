import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import TrieMap "mo:base/TrieMap";

import It "mo:itertools/Iter";

import Utils "../utils";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type TrieMap<K, V> = TrieMap.TrieMap<K, V>;

    public class PrefixTable() {
        type TableType = {
            #small : TrieMap<[Nat8], Nat>;
            #large : Buffer<?Buffer<(Nat8, Nat)>>;
        };

        let LARGE_TABLE_SIZE = 258 ** 2;

        let is_equal = Utils.array_equal(Nat8.equal);
        let is_hash = Utils.array_hash<Nat8>(Utils.nat8_to_32);

        var table : TableType = #small(
            TrieMap.TrieMap<[Nat8], Nat>(is_equal, is_hash),
        );

        public func insert(prefix : [Nat8], new_index : Nat) : ?Nat {
            switch table {
                case (#small(small_table)) {
                    let prefix_index = small_table.get(prefix);
                    small_table.put(prefix, new_index);
                    prefix_index;
                };
                case (#large(large_table)) {
                    var nat16 = Utils.nat8_to_16(prefix[0]);
                    nat16 <<= 8;
                    nat16 &= Utils.nat8_to_16(prefix[1]);

                    let table_index = Nat16.toNat(nat16);
                    let third_byte_buffer = switch (large_table.get(table_index)){
                        case (?buffer) { buffer };
                        case (null) {
                            let new_buffer = Buffer.Buffer<(Nat8, Nat)>(8);
                            large_table.put(table_index, ?new_buffer);
                            new_buffer;
                        };
                    };

                    for (i in It.range(0, third_byte_buffer.size())) {
                        let (byte, prefix_index) = third_byte_buffer.get(i);

                        if (byte == prefix[2]) {
                            third_byte_buffer.put(i, (byte, new_index));
                            return ?prefix_index;
                        };
                    };

                    null;
                };
            };
        };

        func resize(){
            switch table {
                case (#large(_)){ };
                case( #small(small_table)){
                    let large_table = Buffer.Buffer<?Buffer<(Nat8, Nat)>>(LARGE_TABLE_SIZE);

                    for ((prefix, prefix_index) in small_table.entries()) {

                        var nat16 = Utils.nat8_to_16(prefix[0]);
                        nat16 <<= 8;
                        nat16 &= Utils.nat8_to_16(prefix[1]);

                        let table_index = Nat16.toNat(nat16);

                        let third_byte_buffer = switch(large_table.get(table_index)){
                            case (?buffer) buffer;
                            case (null) {
                                let new_buffer = Buffer.Buffer<(Nat8, Nat)>(8);
                                large_table.put(table_index, ?new_buffer);
                                new_buffer;
                            };
                        };

                        third_byte_buffer.add((prefix[2], prefix_index));
                    };

                    table := #large(large_table);
                };
            }
        };

    };
};
