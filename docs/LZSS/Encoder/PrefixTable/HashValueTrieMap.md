# LZSS/Encoder/PrefixTable/HashValueTrieMap

## Class `HashValueTrieMap<K, V>`

``` motoko no-repl
class HashValueTrieMap<K, V>(hashOf : K -> Hash.Hash)
```


### Function `size`
``` motoko no-repl
func size() : Nat
```



### Function `put`
``` motoko no-repl
func put(key : K, value : V)
```



### Function `replace`
``` motoko no-repl
func replace(key : K, value : V) : ?V
```



### Function `get`
``` motoko no-repl
func get(key : K) : ?V
```



### Function `delete`
``` motoko no-repl
func delete(key : K)
```



### Function `remove`
``` motoko no-repl
func remove(key : K) : ?V
```



### Function `keys`
``` motoko no-repl
func keys() : I.Iter<Hash>
```



### Function `vals`
``` motoko no-repl
func vals() : I.Iter<V>
```



### Function `entries`
``` motoko no-repl
func entries() : I.Iter<(Hash, V)>
```


## Function `fromEntries`
``` motoko no-repl
func fromEntries<K, V>(entries : I.Iter<(K, V)>, keyHash : K -> Hash.Hash) : HashValueTrieMap<K, V>
```

