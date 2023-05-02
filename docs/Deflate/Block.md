# Deflate/Block

## Value `NO_COMPRESSION_MAX_BLOCK_SIZE`
``` motoko no-repl
let NO_COMPRESSION_MAX_BLOCK_SIZE
```


## Type `BlockType`
``` motoko no-repl
type BlockType = {#Raw; #Fixed : { lzss : Lzss.Encoder; block_limit : Nat }; #Dynamic : { lzss : Lzss.Encoder; block_limit : Nat }}
```


## Function `blockToNat`
``` motoko no-repl
func blockToNat(blockType : BlockType) : Nat
```


## Function `natToBlock`
``` motoko no-repl
func natToBlock(byte : Nat) : BlockType
```


## Type `BlockInterface`
``` motoko no-repl
type BlockInterface = { size : () -> Nat; append : ([Nat8]) -> (); add : (Nat8) -> (); flush : (BitBuffer) -> (); clear : () -> () }
```


## Function `Block`
``` motoko no-repl
func Block(block_type : BlockType) : BlockInterface
```


## Class `Raw`

``` motoko no-repl
class Raw()
```


### Function `size`
``` motoko no-repl
func size() : Nat
```



### Function `add`
``` motoko no-repl
func add(byte : Nat8)
```



### Function `append`
``` motoko no-repl
func append(bytes : [Nat8])
```



### Function `flush`
``` motoko no-repl
func flush(bitbuffer : BitBuffer)
```



### Function `clear`
``` motoko no-repl
func clear()
```


## Class `Compress`

``` motoko no-repl
class Compress(lzss : Lzss.Encoder, huffman : Symbol.HuffmanCodec, limit : Nat)
```


### Function `size`
``` motoko no-repl
func size() : Nat
```



### Function `add`
``` motoko no-repl
func add(byte : Nat8) : ()
```



### Function `append`
``` motoko no-repl
func append(bytes : [Nat8])
```



### Function `clear`
``` motoko no-repl
func clear()
```



### Function `flush`
``` motoko no-repl
func flush(bitbuffer : BitBuffer)
```

