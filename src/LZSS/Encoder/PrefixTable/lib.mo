import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import HashMap "mo:base/HashMap";
import TrieMap "mo:base/TrieMap";

import It "mo:itertools/Iter";
import HashValueTrieMap "HashValueTrieMap";

import Utils "../../../utils";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type Iter<A> = Iter.Iter<A>;
    type HashMap<K, V> = HashMap.HashMap<K, V>;
    type TrieMap<K, V> = TrieMap.TrieMap<K, V>;
    type HashValueTrieMap<K, V> = HashValueTrieMap.HashValueTrieMap<K, V>;

    public class PrefixTable() {
        type TableType = {
            #small : HashValueTrieMap<Iter<Nat8>, Nat>;
            #large : [var ?Buffer<(Nat8, Nat)>];
        };

        let LARGE_TABLE_SIZE = 258 ** 2;

        let hash_fn = Utils.iter_hash(Utils.nat8_to_32);

        // var table : TableType = #small(
        //     HashValueTrieMap.HashValueTrieMap<Iter<Nat8>, Nat>(hash_fn),
        // );

        var table : TableType = #large(
            Array.init<?Buffer<(Nat8, Nat)>>(LARGE_TABLE_SIZE, null)
        );

        /// Inserts a new prefix of 3 bytes into the table and returns the index of the previous match if it exists.
        public func insert(
            bytes : [Nat8],
            start : Nat,
            len : Nat,
            index : Nat
        ) : ?Nat {
            if (bytes.size() < (start +  len)){
                Debug.trap("PrefixTable.insert: bytes.size() < (start +  len)");
            };

            switch table {
                case (#small(small_table)) {
                    let iter = It.fromArraySlice(bytes, start, start + len);
                    small_table.replace(iter, index);
                };
                case (#large(large_table)) {
                    var nat16 = Utils.nat8_to_16(bytes[start]);
                    nat16 <<= 8;
                    nat16 |= Utils.nat8_to_16(bytes[start + 1]);

                    let table_index = Nat16.toNat(nat16);
                    let third_byte_buffer = switch (large_table.get(table_index)) {
                        case (?buffer) { buffer };
                        case (null) {
                            let new_buffer = Buffer.Buffer<(Nat8, Nat)>(8);
                            large_table.put(table_index, ?new_buffer);
                            new_buffer;
                        };
                    };

                    for (i in It.range(0, third_byte_buffer.size())) {
                        let (byte, prev_index) = third_byte_buffer.get(i);

                        if (byte == bytes[start + 2]) {
                            third_byte_buffer.put(i, (byte, index));
                            return ?prev_index;
                        };
                    };

                    third_byte_buffer.add((bytes[start + 2], index));

                    null;
                };
            };
        };

        public func clear() {
            switch(table){
                case (#small(small_table)) {
                    table := #small(HashValueTrieMap.HashValueTrieMap(hash_fn));
                };
                case (#large(large_table)) {
                    for (i in It.range(0, LARGE_TABLE_SIZE)) {
                        switch (large_table.get(i)) {
                            case (?buffer) {
                                buffer.clear();
                            };
                            case (null) {};
                        };
                    };
                };
            };
        };

        func resize() {
            switch table {
                case (#large(_)) {};
                case (#small(small_table)) {
                    let large_table = Array.init<?Buffer<(Nat8, Nat)>>(LARGE_TABLE_SIZE, null);

                    for ((prefix_hash, index) in small_table.entries()) {

                        var table_index = Nat32.toNat(prefix_hash >> 8);
                        let third_byte = Nat8.fromNat(Nat32.toNat(prefix_hash & 0xFF));

                        let third_byte_buffer = switch (large_table.get(table_index)) {
                            case (?buffer) buffer;
                            case (null) {
                                let new_buffer = Buffer.Buffer<(Nat8, Nat)>(8);
                                large_table.put(table_index, ?new_buffer);
                                new_buffer;
                            };
                        };

                        third_byte_buffer.add((third_byte, index));
                    };

                    table := #large(large_table);
                };
            };
        };
    };
};
