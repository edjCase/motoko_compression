# LZSS/Encoder/PrefixTable/lib

## Class `PrefixTable`

``` motoko no-repl
class PrefixTable()
```


### Function `insert_triple`
``` motoko no-repl
func insert_triple(index : Nat) : ?Nat
```



### Function `insert`
``` motoko no-repl
func insert(bytes : [Nat8], start : Nat, len : Nat, index : Nat) : ?Nat
```

Inserts a new prefix of 3 bytes into the table and returns the index of the previous match if it exists.


### Function `clear`
``` motoko no-repl
func clear()
```

