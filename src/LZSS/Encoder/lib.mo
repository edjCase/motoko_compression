import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Deque "mo:base/Deque";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";

import It "mo:itertools/Iter";
import Deiter "mo:itertools/Deiter";
import CircularBuffer "mo:circular-buffer";

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

    public func Default() : Encoder {
        Encoder(null);
    };

    public func encode(blob : Blob) : Buffer<LZSSEntry> {
        let encoder = Default();
        let buffer = Buffer.Buffer<LZSSEntry>(8);
        encoder.encodeBlob(blob, buffer);
        buffer
    };

    public class Encoder(opt_window_size : ?Nat) {

        let window_size = Option.get(opt_window_size, Common.MATCH_WINDOW_SIZE);
        let search_buffer = CircularBuffer.CircularBuffer<Nat8>(window_size);

        let prefix_table = PrefixTable.PrefixTable();

        var input_size : Nat = 0;

        public func size() : Nat = input_size;
        public func windowSize() : Nat = window_size;

        public func encodeBlob(blob : Blob, output: Buffer<LZSSEntry>) {
            let bytes = Blob.toArray(blob);
            encode(bytes, output);
        };

        public func encodeToIter(bytes : [Nat8]) : Iter<LZSSEntry> = object {
            var curr_index = 0;

            public func next() : ?LZSSEntry {
                Debug.print("curr_index: " # debug_show(curr_index));
                if (curr_index >= bytes.size()) {
                    return null;
                };

                if (((bytes.size() - curr_index) : Nat) >= 3) {
                    let opt_prefix_index = prefix_table.insert(bytes, curr_index, 3, input_size);

                    switch (opt_prefix_index) {
                        case (?prefix_index) {
                            let backward_offset = (input_size - prefix_index) : Nat;

                            if (backward_offset <= window_size) {
                                let search_index = (search_buffer.size() - backward_offset) : Nat;

                                let len = longest_prefix_length(bytes, search_index, curr_index);

                                label for_loop for (i in It.range(0, len)) {
                                    if ((bytes.size() - (curr_index + i) : Nat) < 3) {
                                        break for_loop;
                                    };
                                    ignore prefix_table.insert(bytes, curr_index + i, 3, input_size + i);
                                    search_buffer.push(bytes[curr_index + i]);
                                };

                                curr_index += len;
                                input_size += len;

                                return ?#pointer(backward_offset, len);
                            };
                        };
                        case (null) {};
                    };
                };

                search_buffer.push(bytes[curr_index]);
                input_size += 1;
                curr_index += 1;

                ?#literal(bytes[curr_index]);
            };
        };

        public func encode(bytes : [Nat8], output: Buffer<LZSSEntry>) {
            var curr_index = 0;

            label while_loop while (curr_index < bytes.size()) {

                if (((bytes.size() - curr_index) : Nat) >= 3) {
                    let opt_prefix_index = prefix_table.insert(bytes, curr_index, 3, input_size);

                    switch (opt_prefix_index) {
                        case (?prefix_index) {
                            let backward_offset = (input_size - prefix_index) : Nat;

                            if (backward_offset <= window_size) {
                                let search_index = (search_buffer.size() - backward_offset) : Nat;

                                let len = longest_prefix_length(bytes, search_index, curr_index);

                                label for_loop for (i in It.range(0, len)) {
                                    if ((bytes.size() - (curr_index + i) : Nat) < 3) {
                                        break for_loop;
                                    };
                                    ignore prefix_table.insert(bytes, curr_index + i, 3, input_size + i);
                                    search_buffer.push(bytes[curr_index + i]);
                                };
                                
                                output.add(#pointer(backward_offset, len));

                                curr_index += len;
                                input_size += len;

                                continue while_loop;
                            };
                        };
                        case (null) {};
                    };
                };

                search_buffer.push(bytes[curr_index]);
                input_size += 1;

                output.add(#literal(bytes[curr_index]));
                curr_index += 1;
            };
        };

        public func clear() {
            search_buffer.clear();
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

    };
};
