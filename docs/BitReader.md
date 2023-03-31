# BitReader

## Class `BitReader<NatX>`

``` motoko no-repl
class BitReader<NatX>(natlib : NatLib<NatX>)
```


### Function `readBit`
``` motoko no-repl
func readBit() : Bool
```



### Function `readBits`
``` motoko no-repl
func readBits(n : Nat) : NatX
```



### Function `readByte`
``` motoko no-repl
func readByte() : Nat8
```



### Function `readBytes`
``` motoko no-repl
func readBytes(nbytes : Nat) : [Nat8]
```



### Function `getPosition`
``` motoko no-repl
func getPosition() : Nat
```



### Function `setPosition`
``` motoko no-repl
func setPosition(pos : Nat)
```



### Function `reset`
``` motoko no-repl
func reset()
```



### Function `clear`
``` motoko no-repl
func clear()
```



### Function `size`
``` motoko no-repl
func size() : Nat
```



### Function `sizeInBytes`
``` motoko no-repl
func sizeInBytes() : Nat
```



### Function `byteAlign`
``` motoko no-repl
func byteAlign()
```



### Function `addBytes`
``` motoko no-repl
func addBytes(bytes : [Nat8])
```


## Function `fromBytes`
``` motoko no-repl
func fromBytes<NatX>(natlib : NatLib<NatX>, bytes : [Nat8]) : BitReader<NatX>
```

