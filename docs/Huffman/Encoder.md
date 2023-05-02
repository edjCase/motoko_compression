# Huffman/Encoder

## Type `Code`
``` motoko no-repl
type Code = Common.Code
```


## Function `fromBitwidths`
``` motoko no-repl
func fromBitwidths(bitwidths : [Nat]) : Result<Encoder, Text>
```


## Function `fromFrequencies`
``` motoko no-repl
func fromFrequencies(frequencies : [Nat], bitwidth : Nat) : Result<Encoder, Text>
```


## Class `Builder`

``` motoko no-repl
class Builder(symbols_count : Nat)
```


### Function `setMapping`
``` motoko no-repl
func setMapping(symbol : Nat, code : Code) : Result<(), Text>
```



### Function `build`
``` motoko no-repl
func build() : Encoder
```


## Class `Encoder`

``` motoko no-repl
class Encoder(table : [var Code])
```


### Function `encode`
``` motoko no-repl
func encode(bitbuffer : BitBuffer, symbol : Nat)
```



### Function `lookup`
``` motoko no-repl
func lookup(symbol : Nat) : Code
```



### Function `max_symbol`
``` motoko no-repl
func max_symbol() : Nat
```

