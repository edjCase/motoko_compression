# Deflate/Encoder

## Type `DeflateOptions`
``` motoko no-repl
type DeflateOptions = { block_size : Nat; dynamic_huffman : Bool; lzss : ?LzssEncoder }
```


## Class `Encoder`

``` motoko no-repl
class Encoder(bitbuffer : BitBuffer, options : DeflateOptions)
```


### Function `encode_byte`
``` motoko no-repl
func encode_byte(byte : Nat8)
```



### Function `encode`
``` motoko no-repl
func encode(data : [Nat8])
```



### Function `set_new_block_event_handler`
``` motoko no-repl
func set_new_block_event_handler(fn : BlockEventHandler)
```



### Function `flush`
``` motoko no-repl
func flush(is_final : Bool)
```



### Function `clear`
``` motoko no-repl
func clear()
```



### Function `finish`
``` motoko no-repl
func finish() : BitBuffer
```

