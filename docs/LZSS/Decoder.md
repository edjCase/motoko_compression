# LZSS/Decoder

## Function `decode`
``` motoko no-repl
func decode(compressed_buffer : Buffer<LZSSEntry>) : Blob
```


## Class `Decoder`

``` motoko no-repl
class Decoder(output_buffer : ?Buffer<Nat8>)
```


### Function `decodeEntry`
``` motoko no-repl
func decodeEntry(entry : LZSSEntry)
```



### Function `decode`
``` motoko no-repl
func decode(compressed_buffer : Buffer<LZSSEntry>)
```



### Function `getBuffer`
``` motoko no-repl
func getBuffer() : Buffer<Nat8>
```

