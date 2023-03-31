# LZSS/Encoder/PrefixTable/HashValueTrie

## Type `Trie`
``` motoko no-repl
type Trie<V> = {#empty; #leaf : Leaf<V>; #branch : Branch<V>}
```


## Type `Leaf`
``` motoko no-repl
type Leaf<V> = { size : Nat; keyvals : AssocList<Hash, V> }
```


## Type `Branch`
``` motoko no-repl
type Branch<V> = { size : Nat; left : Trie<V>; right : Trie<V> }
```


## Type `AssocList`
``` motoko no-repl
type AssocList<H, V> = AssocList.AssocList<H, V>
```


## Function `equal_hash`
``` motoko no-repl
func equal_hash(h1 : Hash, h2 : Hash) : Bool
```


## Function `empty`
``` motoko no-repl
func empty<V>() : Trie<V>
```


## Function `size`
``` motoko no-repl
func size<V>(t : Trie<V>) : Nat
```


## Function `branch`
``` motoko no-repl
func branch<V>(l : Trie<V>, r : Trie<V>) : Trie<V>
```


## Function `leaf`
``` motoko no-repl
func leaf<V>(kvs : AssocList<Hash, V>, bitpos : Nat) : Trie<V>
```


## Function `fromList`
``` motoko no-repl
func fromList<V>(kvc : ?Nat, kvs : AssocList<Hash, V>, bitpos : Nat) : Trie<V>
```


## Function `replace`
``` motoko no-repl
func replace<V>(t : Trie<V>, hash : Hash, v : ?V) : (Trie<V>, ?V)
```


## Function `put`
``` motoko no-repl
func put<V>(t : Trie<V>, hash : Hash, v : V) : (Trie<V>, ?V)
```


## Function `find`
``` motoko no-repl
func find<V>(t : Trie<V>, hash : Hash) : ?V
```


## Function `remove`
``` motoko no-repl
func remove<V>(t : Trie<V>, hash : Hash) : (Trie<V>, ?V)
```

