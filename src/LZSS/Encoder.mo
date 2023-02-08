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

import Common "Common";
import Utils "../utils";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type CircularBuffer<A> = CircularBuffer.CircularBuffer<A>;
    type Deque<A> = Deque.Deque<A>;
    type Iter<A> = Iter.Iter<A>;

    type LZSSEntry = Common.LZSSEntry;
    type Result<Ok, Err> = Result.Result<Ok, Err>;

    let MATCH_WINDOW_SIZE = 32_768;
    let MATCH_MAX_SIZE = 258;

    public class Encoder() {
        let search_buffer = CircularBuffer.CircularBuffer<Nat8>(MATCH_WINDOW_SIZE);
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
                            result_buffer.add(#ref((backward_offset, len)));
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

        // public func encoded_chunks(){
        //     let chunks = Buffer.Buffer<>(8);
        // };

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
    };

    public func encode(blob : Blob) : Buffer<LZSSEntry> {
        let bytes = Blob.toArray(blob);
        let buffer = Buffer.Buffer<LZSSEntry>(8);
        let bytes_iter = bytes.vals();
        let iter = It.peekable(It.enumerate(bytes_iter));

        var char_index = 0;

        while (char_index < bytes.size()) {
            switch (find_longest_match(bytes, char_index)) {
                case (#ok(pointer)) {
                    let forward_match_len = pointer.1;
                    // Debug.print("forward_match_len: " # debug_show (forward_match_len));

                    if (forward_match_len == 1) {
                        let byte = bytes[char_index];
                        buffer.add(#literal(byte));
                    } else {
                        buffer.add(#ref(pointer));
                    };

                    char_index += forward_match_len;
                };
                case (#err()) {
                    let byte = bytes[char_index];
                    buffer.add(#literal(byte));

                    char_index += 1;
                };
            };
        };

        buffer;
    };

    func find_longest_match(bytes : [Nat8], from_index : Nat) : Result<(Nat, Nat), ()> {
        let i = from_index;

        var limit = MATCH_WINDOW_SIZE;
        var longest_match : ?(Nat, Nat) = null;
        var len = 0;

        var backward_offset = 0;

        func find_match() : Result<Nat, ()> {
            find_match_from_offset(bytes, i, backward_offset, limit - backward_offset);
        };

        label while_loop while (backward_offset < limit and backward_offset < i) {
            switch (find_match()) {
                case (#ok(match_index)) {
                    let match_len = get_match_len(bytes, match_index, i);
                    // Debug.print("match_len: " # debug_show(match_len) # " match_index: " # debug_show(match_index) # " i: " # debug_show(i) # " bo: " # debug_show(backward_offset));
                    backward_offset := (i - match_index) : Nat;

                    if (match_len > len) {
                        longest_match := ?(backward_offset, match_len);

                        len := match_len;
                    } else {
                        backward_offset += 1;
                    };

                    if (match_len >= 5) {
                        break while_loop;
                    };

                    // Debug.print("longest_match: " # debug_show (longest_match));
                };

                case (#err()) break while_loop;
            };
        };

        switch (longest_match) {
            case (?longest) return #ok(longest);
            case (null) return #err();
        };
    };

    func is_match(bytes : [Nat8], prev_index : Nat, forward_index : Nat) : Bool {
        let prev_byte = bytes[prev_index];
        let forward_byte = bytes[forward_index];

        prev_byte == forward_byte;
    };

    func is_slice_match(bytes : [Nat8], prev_index : Nat, forward_index : Nat, len : Nat) : Bool {
        for (i in It.range(0, len)) {
            let prev_byte = bytes[prev_index + i];
            let forward_byte = bytes[forward_index + i];

            if (prev_byte != forward_byte) {
                return false;
            };
        };

        true;
    };

    func find_match_from_offset(
        bytes : [Nat8],
        from_index : Nat,
        backward_offset : Nat,
        limit : Nat,
    ) : Result<Nat, ()> {
        var i = from_index;
        let reversed_iter = Deiter.reverse(Deiter.range(0, i - backward_offset));
        let iter_with_limit = It.take(reversed_iter, limit);

        for (j in iter_with_limit) {
            if (is_match(bytes, j, i)) {
                return #ok(j);
            };
        };

        return #err();
    };

    func get_match_len(bytes : [Nat8], prev_index : Nat, curr_index : Nat) : Nat {
        var len = 0;

        let search_iter = It.range(prev_index, curr_index);
        let lookahead_iter = It.take(It.range(curr_index, bytes.size()), MATCH_MAX_SIZE);

        let zipped = It.zip(search_iter, lookahead_iter);

        label _loop for ((i, j) in zipped) {
            if (not is_match(bytes, i, j)) {
                break _loop;
            };

            len += 1;
        };

        len;
    };
};
