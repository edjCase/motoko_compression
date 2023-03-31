# Deflate/Symbol

## Type `Symbol`
``` motoko no-repl
type Symbol = Common.LZSSEntry or {#end_of_block}
```


## Function `lengthCode`
``` motoko no-repl
func lengthCode(symbol : Symbol) : (Nat16, Nat, Nat16)
```

Encodes the literal and length Deflate Symbol to Nat16 and returns the extra bits

## Value `MAX_DISTANCE`
``` motoko no-repl
let MAX_DISTANCE
```


## Function `distanceCode`
``` motoko no-repl
func distanceCode(symbol : Symbol) : ?(Nat, Nat, Nat16)
```


## Class `Encoder`

``` motoko no-repl
class Encoder(literal_encoder : Huffman.Encoder, distance_encoder : Huffman.Encoder)
```


### Function `encode`
``` motoko no-repl
func encode(bitbuffer : BitBuffer<Nat16>, symbol : Symbol)
```


## Type `HuffmanCodec`
``` motoko no-repl
type HuffmanCodec = { build : (Buffer<Symbol>) -> Result<Encoder, Text>; save : () -> () }
```


## Class `FixedHuffmanCodec`

``` motoko no-repl
class FixedHuffmanCodec()
```


### Function `build`
``` motoko no-repl
func build() : Result<Encoder, Text>
```



### Function `save`
``` motoko no-repl
func save()
```


## Class `DynamicHuffmanCodec`

``` motoko no-repl
class DynamicHuffmanCodec()
```


### Function `build`
``` motoko no-repl
func build(symbols : Buffer<Symbol>) : Result<Encoder, Text>
```



### Function `save`
``` motoko no-repl
func save()
```

