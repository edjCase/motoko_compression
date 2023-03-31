# Deflate/lib

## Type `Encoder`
``` motoko no-repl
type Encoder = DeflateEncoder.Encoder
```


## Value `Encoder`
``` motoko no-repl
let Encoder : (BitBuffer<Nat16>, DeflateOptions) -> DeflateEncoder.Encoder
```


## Type `DeflateOptions`
``` motoko no-repl
type DeflateOptions = { block_size : Nat; dynamic_huffman : Bool; lzss : ?LzssEncoder }
```


## Class `Deflate`

``` motoko no-repl
class Deflate(bitbuffer : BitBuffer<Nat16>, options : DeflateOptions)
```


### Function `encode`
``` motoko no-repl
func encode(data : [Nat8])
```



### Function `flush`
``` motoko no-repl
func flush(is_final : Bool)
```



### Function `finish`
``` motoko no-repl
func finish() : BitBuffer<Nat16>
```

