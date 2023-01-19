import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";

import It "mo:itertools/Iter";
import Deiter "mo:itertools/Deiter";

import Common "Common";
import Utils "../utils"

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type LZSSEntry = Common.LZSSEntry;
    type Result<Ok, Err> = Result.Result<Ok, Err>;

    let MATCH_WINDOW_SIZE = 32_768;
    let MATCH_MAX_SIZE = 258;

    public func encode(blob : Blob) : Buffer<LZSSEntry> {
        let bytes = Blob.toArray(blob);
        let buffer = Buffer.Buffer<LZSSEntry>(8);
        let bytes_iter = bytes.vals();
        let iter = It.peekable(It.enumerate(bytes_iter));

        var char_index = 0;

        while (char_index < bytes.size()){
            switch (find_longest_match(bytes, char_index)) {
                case (#ok(pointer)) {
                    let forward_match_len = pointer.1;
                    Debug.print("forward_match_len: " # debug_show (forward_match_len));

                    if (forward_match_len == 1) {
                        let byte = bytes[char_index];
                        buffer.add(#byte(byte));
                    }else{
                        buffer.add(#ref(pointer));
                    };

                    char_index += forward_match_len;
                };
                case (#err()) {
                    let byte = bytes[char_index];
                    buffer.add(#byte(byte));

                    char_index += 1;
                };
            };
        };

        buffer;
    };

    func find_longest_match(bytes: [Nat8], from_index: Nat) : Result<(Nat, Nat), ()> {
        let i = from_index;

        var limit = MATCH_WINDOW_SIZE;
        var longest_match: ?(Nat, Nat) = null;
        var len = 0;

        var backward_offset = 0; 

        func find_match(): Result<Nat, ()> {
            find_match_from_offset(bytes, i, backward_offset, limit - backward_offset);
        };

        while (backward_offset < limit and backward_offset < i){
            switch(find_match()){
                case(#ok(match_index)) {
                    let match_len = get_match_len(bytes, match_index, i);
                    Debug.print("match_len: " # debug_show(match_len) # " match_index: " # debug_show(match_index) # " i: " # debug_show(i) # " bo: " # debug_show(backward_offset));
                    backward_offset := (i - match_index) : Nat;
                    
                    if (match_len > len) {
                        longest_match := ?(backward_offset, match_len);

                        len := match_len;
                    } else {
                        backward_offset+= 1;
                    };

                    Debug.print(debug_show (longest_match));
                };

                case(#err()) return #err();
            };
        };

        switch(longest_match){
            case(?longest) return #ok(longest);
            case(null) return #err();
        };
    };

    func is_match(bytes: [Nat8], prev_index : Nat, forward_index: Nat) : Bool{
        let prev_byte = bytes[prev_index];
        let forward_byte = bytes[forward_index];

        prev_byte == forward_byte;
    };

    func find_match_from_offset(
        bytes: [Nat8], 
        from_index: Nat, 
        backward_offset: Nat, 
        limit: Nat
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

    func get_match_len(bytes: [Nat8], match_index: Nat, char_index: Nat) : Nat {
        var len = 0;

        let search_iter = It.range(match_index, char_index);
        let lookahead_iter = It.take(It.range(char_index, bytes.size()), MATCH_MAX_SIZE);
        
        let zipped = It.zip(search_iter, lookahead_iter);

        for ((i, j) in zipped){
            if (not is_match(bytes, i, j)) {
                Debug.print("\tis_not_match: " # debug_show(i) # " " # debug_show(j));
                return len;
            };

            Debug.print("\tis_match: " # debug_show(i) # " " # debug_show(j));

            len+= 1;
        };
        
        len;
    };
};
