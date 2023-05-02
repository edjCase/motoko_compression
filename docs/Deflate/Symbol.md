# Deflate/Symbol

## Type `Symbol`
``` motoko no-repl
type Symbol = Common.LzssEntry or {#EndOfBlock}
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
class Encoder(literal_encoder : HuffmanEncoder.Encoder, distance_encoder : HuffmanEncoder.Encoder)
```


### Value `literal`
``` motoko no-repl
let literal
```



### Value `distance`
``` motoko no-repl
let distance
```



### Function `encode`
``` motoko no-repl
func encode(bitbuffer : BitBuffer, symbol : Symbol)
```


## Class `Decoder`

``` motoko no-repl
class Decoder(literal_decoder : HuffmanDecoder.Decoder, distance_decoder : HuffmanDecoder.Decoder)
```


### Function `decode`
``` motoko no-repl
func decode(reader : BitReader) : Result<Symbol, Text>
```


## Type `HuffmanCodec`
``` motoko no-repl
type HuffmanCodec = { build : (Iter<Symbol>) -> Result<Encoder, Text>; save : (BitBuffer, Encoder) -> Result<(), Text>; load : (BitReader) -> Result<Decoder, Text> }
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
func save() : Result<(), Text>
```



### Function `load`
``` motoko no-repl
func load(reader : BitReader) : Result<Decoder, Text>
```


## Class `DynamicHuffmanCodec`

``` motoko no-repl
class DynamicHuffmanCodec()
```


### Function `build`
``` motoko no-repl
func build(symbols_iter : Iter<Symbol>) : Result<Encoder, Text>
```



### Function `save`
``` motoko no-repl
func save(bitbuffer : BitBuffer, codec : Encoder) : Result<(), Text>
```



### Function `load`
``` motoko no-repl
func load(reader : BitReader) : Result<Decoder, Text>
```

