import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Deque "mo:base/Deque";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";

import It "mo:itertools/Iter";
import Deiter "mo:itertools/Deiter";
import CircularBuffer "mo:CircularBuffer";

import Common "../Common";
import Utils "../../utils";

import PrefixTable "PrefixTable";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type CircularBuffer<A> = CircularBuffer.CircularBuffer<A>;
    type Deque<A> = Deque.Deque<A>;
    type Iter<A> = Iter.Iter<A>;

    type LZSSEntry = Common.LZSSEntry;
    type Result<Ok, Err> = Result.Result<Ok, Err>;

    public class PrefixTableEncoder() {
        let search_buffer = CircularBuffer.CircularBuffer<Nat8>(Common.MATCH_WINDOW_SIZE);
        let result_buffer = Buffer.Buffer<LZSSEntry>(8);

        let prefix_table = PrefixTable.PrefixTable();

        var input_size : Nat = 0;

        public func size() : Nat = result_buffer.size();
        public func inputSize() : Nat = input_size;

        public func encodeBlob(blob : Blob) {
            let bytes = Blob.toArray(blob);
            encode(bytes);
        };

        public func encode(bytes : [Nat8]) {
            var curr_index = 0;

            label while_loop while (curr_index < bytes.size()) {

                if (((bytes.size() - curr_index) : Nat) >= 3) {
                    let opt_prefix_index = prefix_table.insert(bytes, curr_index, 3, input_size);

                    switch (opt_prefix_index) {
                        case (?prefix_index) {
                            let backward_offset = (input_size - prefix_index) : Nat;

                            if (backward_offset <= Common.MATCH_WINDOW_SIZE) {
                                let search_index = (search_buffer.size() - backward_offset) : Nat;

                                let len = longest_prefix_length(bytes, search_index, curr_index);

                                for (i in It.range(0, len)) {
                                    search_buffer.push(bytes[curr_index + i]);
                                };
                                input_size += len;

                                result_buffer.add(#pointer(backward_offset, len));
                                curr_index += len;
                                continue while_loop;
                            };
                        };
                        case (null) {};
                    };
                };

                search_buffer.push(bytes[curr_index]);
                input_size += 1;

                result_buffer.add(#literal(bytes[curr_index]));
                curr_index += 1;
            };
        };

        public func clear() {
            search_buffer.clear();
            result_buffer.clear();
            prefix_table.clear();
            input_size := 0;
        };

        func longest_prefix_length(
            bytes : [Nat8],
            _search_index : Nat,
            _curr_index : Nat,
        ) : Nat {
            var len = 3;

            func is_match() : Bool {
                let search_index = _search_index + len;
                let curr_index = _curr_index + len;

                if (search_index >= search_buffer.size() or curr_index >= bytes.size()) {
                    return false;
                };

                search_buffer.get(search_index) == bytes[curr_index];
            };

            while (is_match()) {
                len += 1;
            };

            len;
        };

        public func getCompressedBytes() : Buffer<LZSSEntry> {
            Buffer.clone(result_buffer);
        };

    };
};
