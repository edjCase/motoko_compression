# Deflate/Block

## Value `NO_COMPRESSION_MAX_BLOCK_SIZE`
``` motoko no-repl
let NO_COMPRESSION_MAX_BLOCK_SIZE
```


## Type `BlockType`
``` motoko no-repl
type BlockType = {#Raw; #Fixed; #Dynamic}
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
type BlockInterface = { size : () -> Nat; append : ([Nat8]) -> (); flush : (BitBuffer<Nat16>) -> () }
```


## Function `Block`
``` motoko no-repl
func Block(block_type : BlockType, opt_lzss : ?Lzss.Encoder) : BlockInterface
```


## Class `Raw`

``` motoko no-repl
class Raw()
```


### Function `size`
``` motoko no-repl
func size() : Nat
```



### Function `append`
``` motoko no-repl
func append(bytes : [Nat8])
```



### Function `flush`
``` motoko no-repl
func flush(bitbuffer : BitBuffer<Nat16>)
```


## Class `Compress`

``` motoko no-repl
class Compress(lzss : Lzss.Encoder, huffman : Symbol.FixedHuffmanCodec)
```


### Function `size`
``` motoko no-repl
func size() : Nat
```



### Function `append`
``` motoko no-repl
func append(bytes : [Nat8])
```



### Function `flush`
``` motoko no-repl
func flush(bitbuffer : BitBuffer<Nat16>)
```

