# Huffman

## Type `Code`
``` motoko no-repl
type Code = { bitwidth : Nat; bits : Nat16 }
```


## Function `reverseCodeBits`
``` motoko no-repl
func reverseCodeBits(code : Code) : Code
```


## Function `fromBitwidths`
``` motoko no-repl
func fromBitwidths(bitwidths : [Nat8]) : Result<Encoder, Text>
```


## Function `fromFrequencies`
``` motoko no-repl
func fromFrequencies(freqs : [Nat], bitwidth : Nat) : Result<Encoder, Text>
```


## Class `Builder`

``` motoko no-repl
class Builder(symbols_count : Nat)
```


### Function `restore_huffman_codes`
``` motoko no-repl
func restore_huffman_codes(bitwidth_arr : [Nat8]) : Result<Encoder, Text>
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
func encode(bitbuffer : BitBuffer<Nat16>, symbol : Nat)
```



### Function `lookup`
``` motoko no-repl
func lookup(symbol : Nat) : Code
```

