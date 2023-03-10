import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Deque "mo:base/Deque";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";

import Deiter "mo:itertools/Deiter";
import Itertools "mo:itertools/Iter";

module {

    type Deque<A> = Deque.Deque<A>;
    type Iter<A> = Iter.Iter<A>;
    type Hash = Hash.Hash;
    type List<A> = List.List<A>;
    
    public func nat_to_le_bytes(num : Nat, nbytes: Nat): [Nat8] {
        var n = num;

        Array.tabulate(
            nbytes,
            func (_: Nat) : Nat8 {
                if ( n == 0) {
                    return 0;
                };

                let byte = Nat8.fromNat(n % 256);
                n /= 256;
                byte
            }
        )
    };

    public func nat_to_bytes(num : Nat, nbytes: Nat): [Nat8] {
        Array.reverse(nat_to_bytes(num, nbytes));
    };

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

    public func iter_hash<A>(elem_hash : (A) -> Hash.Hash) : (Iter<A>) -> Hash.Hash {
        func(iter : Iter<A>) : Hash.Hash {

            var hash : Nat32 = 0;

            hashNat8Iter(
                Iter.map(
                    iter,
                    func(a : A) : Hash.Hash {
                        elem_hash(a);
                    },
                )
            )
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

    public func nat8_to_32(n: Nat8): Nat32 {
        Nat32.fromNat(Nat8.toNat(n));
    };

    public func nat8_to_16(n: Nat8): Nat16 {
        Nat16.fromNat(Nat8.toNat(n));
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

    func hashNat8Iter(iter: Iter<Hash>) : Hash{
        var hash : Nat32 = 0;
        for (natOfKey in iter) {
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
