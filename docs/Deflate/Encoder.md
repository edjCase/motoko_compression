# Deflate/Encoder

## Type `DeflateOptions`
``` motoko no-repl
type DeflateOptions = { block_size : Nat; dynamic_huffman : Bool; lzss : ?LzssEncoder }
```


## Class `Encoder`

``` motoko no-repl
class Encoder(bitbuffer : BitBuffer<Nat16>, options : DeflateOptions)
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

