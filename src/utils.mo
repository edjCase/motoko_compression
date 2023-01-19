import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Deque "mo:base/Deque";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";

import Deiter "mo:itertools/Deiter";
import Itertools "mo:itertools/Iter";

module {

    type Deque<A> = Deque.Deque<A>;
    type Iter<A> = Iter.Iter<A>;
    type List<A> = List.List<A>;

    public func array_equal<A>(is_elem_equal : (A, A) -> Bool) : ([A], [A]) -> Bool {
        func(a : [A], b : [A]) : Bool {
            Array.equal(a, b, is_elem_equal);
        };
    };

    public func array_hash<A>(elem_hash : (A) -> Hash.Hash) : ([A]) -> Hash.Hash {
        func(arr : [A]) : Hash.Hash {

            let hashed_elements = Array.map(
                arr,
                func(a : A) : Hash.Hash {
                    elem_hash(a);
                },
            );

            hashNat8(hashed_elements);
        };
    };

    public func list_equal<A>(is_elem_equal : (A, A) -> Bool) : (List<A>, List<A>) -> Bool {
        func(a : List<A>, b : List<A>) : Bool {
            List.equal(a, b, is_elem_equal);
        };
    };

    public func list_hash<A>(elem_hash : (A) -> Hash.Hash) : (List<A>) -> Hash.Hash {
        func(list : List<A>) : Hash.Hash {

            let hashed_elements = List.map(
                list,
                func(a : A) : Hash.Hash {
                    elem_hash(a);
                },
            );

            hashNat8(List.toArray(hashed_elements));
        };
    };

    public func deque_hash<A>(elem_hash : (A) -> Hash.Hash) : (Deque<A>) -> Hash.Hash {
        func(deque : Deque<A>) : Hash.Hash {

            let iter = Iter.map(
                Deiter.fromDeque(deque),
                func(a : A) : Hash.Hash {
                    elem_hash(a);
                },
            );

            hashNat8(Iter.toArray(iter));
        };
    };

    public func deque_equal<A>(is_elem_equal : (A, A) -> Bool) : (Deque<A>, Deque<A>) -> Bool {
        func(a : Deque<A>, b : Deque<A>) : Bool {
            Itertools.equal(
                Deiter.fromDeque(a),
                Deiter.fromDeque(b),
                is_elem_equal,
            );
        };
    };

    public func nat8_hash(n : Nat8) : Hash.Hash {
        Nat32.fromNat(Nat8.toNat(n));
    };

    func hashNat8(key : [Hash.Hash]) : Hash.Hash {
        var hash : Nat32 = 0;
        for (natOfKey in key.vals()) {
            hash := hash +% natOfKey;
            hash := hash +% hash << 10;
            hash := hash ^ (hash >> 6);
        };

        hash := hash +% hash << 3;
        hash := hash ^ (hash >> 11);
        hash := hash +% hash << 15;
        return hash;
    };
};
