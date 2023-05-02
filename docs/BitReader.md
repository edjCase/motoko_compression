# BitReader

## Class `BitReader`

``` motoko no-repl
class BitReader()
```


### Function `peekBit`
``` motoko no-repl
func peekBit() : Bool
```



### Function `readBit`
``` motoko no-repl
func readBit() : Bool
```



### Function `peekBits`
``` motoko no-repl
func peekBits(n : Nat) : Nat
```



### Function `skipBits`
``` motoko no-repl
func skipBits(n : Nat)
```



### Function `readBits`
``` motoko no-repl
func readBits(n : Nat) : Nat
```



### Function `peekByte`
``` motoko no-repl
func peekByte() : Nat8
```



### Function `readByte`
``` motoko no-repl
func readByte() : Nat8
```



### Function `peekBytes`
``` motoko no-repl
func peekBytes(nbytes : Nat) : [Nat8]
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



### Function `clearRead`
``` motoko no-repl
func clearRead()
```



### Function `clear`
``` motoko no-repl
func clear()
```



### Function `bitSize`
``` motoko no-repl
func bitSize() : Nat
```



### Function `byteSizeExact`
``` motoko no-repl
func byteSizeExact() : Nat
```



### Function `byteSize`
``` motoko no-repl
func byteSize() : Nat
```



### Function `byteAlign`
``` motoko no-repl
func byteAlign()
```



### Function `addBytes`
``` motoko no-repl
func addBytes(bytes : [Nat8])
```



### Function `hideTailBits`
``` motoko no-repl
func hideTailBits(n : Nat)
```



### Function `hiddenTailBits`
``` motoko no-repl
func hiddenTailBits() : Nat
```



### Function `showTailBits`
``` motoko no-repl
func showTailBits()
```


## Function `fromBytes`
``` motoko no-repl
func fromBytes(bytes : [Nat8]) : BitReader
```

