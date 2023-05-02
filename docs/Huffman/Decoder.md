# Huffman/Decoder

## Type `DecoderOptions`
``` motoko no-repl
type DecoderOptions = { max_bitwidth : Nat }
```


## Class `Builder`

``` motoko no-repl
class Builder(max_bitwidth : Nat)
```


### Function `setMapping`
``` motoko no-repl
func setMapping(symbol : Nat, code : Code) : Result<(), Text>
```



### Function `build`
``` motoko no-repl
func build() : Decoder
```


## Function `fromBitwidths`
``` motoko no-repl
func fromBitwidths(bitwidths : [Nat]) : Result<Decoder, Text>
```


## Class `Decoder`

``` motoko no-repl
class Decoder(table : [var Nat], max_bitwidth : Nat)
```


### Function `decode`
``` motoko no-repl
func decode(reader : BitReader) : Result<Nat, Text>
```

