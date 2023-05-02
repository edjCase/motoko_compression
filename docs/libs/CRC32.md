# libs/CRC32

## Function `checksum`
``` motoko no-repl
func checksum(data : [Nat8]) : Hash.Hash
```


## Class `CRC32`

``` motoko no-repl
class CRC32()
```


### Function `updateByte`
``` motoko no-repl
func updateByte(byte : Nat8)
```



### Function `updateIter`
``` motoko no-repl
func updateIter(iter : Iter.Iter<Nat8>)
```



### Function `update`
``` motoko no-repl
func update(data : [Nat8])
```



### Function `reset`
``` motoko no-repl
func reset()
```



### Function `finish`
``` motoko no-repl
func finish() : Hash.Hash
```

