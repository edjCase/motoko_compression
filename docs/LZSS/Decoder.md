# LZSS/Decoder

## Function `decode`
``` motoko no-repl
func decode(lzss_buffer : Buffer<LzssEntry>) : Buffer<Nat8>
```


## Class `Decoder`

``` motoko no-repl
class Decoder()
```


### Function `decodeEntry`
``` motoko no-repl
func decodeEntry(output_buffer : Buffer<Nat8>, entry : LzssEntry)
```



### Function `decodeIter`
``` motoko no-repl
func decodeIter(output_buffer : Buffer<Nat8>, lzss_iter : Iter.Iter<LzssEntry>)
```



### Function `decode`
``` motoko no-repl
func decode(output_buffer : Buffer<Nat8>, lzss_buffer : Buffer<LzssEntry>)
```

