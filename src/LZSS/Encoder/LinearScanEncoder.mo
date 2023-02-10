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

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type CircularBuffer<A> = CircularBuffer.CircularBuffer<A>;
    type Deque<A> = Deque.Deque<A>;
    type Iter<A> = Iter.Iter<A>;

    type LZSSEntry = Common.LZSSEntry;
    type Result<Ok, Err> = Result.Result<Ok, Err>;

    public class LinearScanEncoder() {
        let search_buffer = CircularBuffer.CircularBuffer<Nat8>(Common.MATCH_WINDOW_SIZE);
        let result_buffer = Buffer.Buffer<LZSSEntry>(8);

        var input_size : Nat = 0;

        public func size() : Nat {
            result_buffer.size();
        };

        public func inputSize() : Nat {
            input_size;
        };

        public func encodeBlob(blob : Blob) {
            let bytes = Blob.toArray(blob);
            encode(bytes);
        };

        public func encode(bytes : [Nat8]) {
            var curr_index = 0;

            while (curr_index < bytes.size()) {
                switch (find_longest_match(bytes, curr_index)) {
                    case (#ok((backward_offset, len))) {
                        if (len == 1) {
                            let byte = bytes[curr_index];
                            result_buffer.add(#literal(byte));
                        } else {
                            result_buffer.add(#pointer((backward_offset, len)));
                        };

                        for (i in It.range(0, len)) {
                            let byte = bytes[curr_index + i];
                            search_buffer.push(byte);
                            input_size += 1;
                        };
                        curr_index += len;
                    };
                    case (#err()) {
                        let byte = bytes[curr_index];
                        search_buffer.push(byte);
                        input_size += 1;

                        result_buffer.add(#literal(byte));

                        curr_index += 1;
                    };
                };
            };
        };

        public func getCompressedBytes() : Buffer<LZSSEntry> {
            Buffer.clone(result_buffer);
        };
        

        func find_longest_match(bytes : [Nat8], curr_index : Nat) : Result<(Nat, Nat), ()> {
            var len = 0;
            var backward_offset = 0;

            let range = Deiter.range(0, search_buffer.size());
            let reversed = Deiter.reverse(range);

            let byte = bytes[curr_index];

            for (i in reversed) {
                if (byte == search_buffer.get(i)) {
                    let match_len = get_match_len(bytes, i, curr_index);

                    if (match_len > len) {
                        len := match_len;
                        backward_offset := (search_buffer.size() - i) : Nat;
                    };
                };
            };

            if (len > 0) {
                #ok((backward_offset, len));
            } else {
                #err();
            };
        };

        func get_match_len(bytes : [Nat8], search_index : Nat, curr_index : Nat) : Nat {
            var len = 0;

            func is_match() : Bool {
                let new_search_index = search_index + len;
                let new_curr_index = curr_index + len;

                if (new_search_index >= search_buffer.size()) {
                    return false;
                };

                if (new_curr_index >= bytes.size()) {
                    return false;
                };

                search_buffer.getOpt(new_search_index) == ?bytes[new_curr_index];
            };

            while (is_match()) {
                len += 1;
            };

            len;
        };

        public func clear() {
            search_buffer.clear();
            result_buffer.clear();
            input_size := 0;
        }
    };
}