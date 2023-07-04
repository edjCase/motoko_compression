# utils

## Value `INSTRUCTION_LIMIT`
``` motoko no-repl
let INSTRUCTION_LIMIT
```


## Function `buffer_get_last`
``` motoko no-repl
func buffer_get_last<A>(buffer : Buffer<A>) : ?A
```


## Function `send_err`
``` motoko no-repl
func send_err<A, B, Err>(a : Result<A, Err>) : Result<B, Err>
```


## Function `div_ceil`
``` motoko no-repl
func div_ceil(num : Nat, divisor : Nat) : Nat
```


## Function `nat_to_le_bytes`
``` motoko no-repl
func nat_to_le_bytes(num : Nat, nbytes : Nat) : [Nat8]
```


## Function `nat_to_bytes`
``` motoko no-repl
func nat_to_bytes(num : Nat, nbytes : Nat) : [Nat8]
```


## Function `bytes_to_nat`
``` motoko no-repl
func bytes_to_nat(bytes : [Nat8]) : Nat
```


## Function `le_bytes_to_nat`
``` motoko no-repl
func le_bytes_to_nat(bytes : [Nat8]) : Nat
```


## Function `array_equal`
``` motoko no-repl
func array_equal<A>(is_elem_equal : (A, A) -> Bool) : ([A], [A]) -> Bool
```


## Function `array_hash`
``` motoko no-repl
func array_hash<A>(elem_hash : (A) -> Hash.Hash) : ([A]) -> Hash.Hash
```


## Function `iter_hash`
``` motoko no-repl
func iter_hash<A>(elem_hash : (A) -> Hash.Hash) : (Iter<A>) -> Hash.Hash
```


## Function `list_equal`
``` motoko no-repl
func list_equal<A>(is_elem_equal : (A, A) -> Bool) : (List<A>, List<A>) -> Bool
```


## Function `list_hash`
``` motoko no-repl
func list_hash<A>(elem_hash : (A) -> Hash.Hash) : (List<A>) -> Hash.Hash
```


## Function `deque_hash`
``` motoko no-repl
func deque_hash<A>(elem_hash : (A) -> Hash.Hash) : (Deque<A>) -> Hash.Hash
```


## Function `deque_equal`
``` motoko no-repl
func deque_equal<A>(is_elem_equal : (A, A) -> Bool) : (Deque<A>, Deque<A>) -> Bool
```


## Function `nat8_to_32`
``` motoko no-repl
func nat8_to_32(n : Nat8) : Nat32
```


## Function `nat8_to_16`
``` motoko no-repl
func nat8_to_16(n : Nat8) : Nat16
```


## Function `nat8_hash`
``` motoko no-repl
func nat8_hash(n : Nat8) : Hash.Hash
```

