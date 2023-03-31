# LZSS/Encoder/lib

## Type `Sink`
``` motoko no-repl
type Sink = { consume : (entry : LZSSEntry) -> () }
```


## Function `Default`
``` motoko no-repl
func Default() : Encoder
```


## Function `encode`
``` motoko no-repl
func encode(blob : Blob) : Buffer<LZSSEntry>
```


## Class `Encoder`

``` motoko no-repl
class Encoder(opt_window_size : ?Nat)
```


### Function `size`
``` motoko no-repl
func size() : Nat
```



### Function `windowSize`
``` motoko no-repl
func windowSize() : Nat
```



### Function `encodeBlob`
``` motoko no-repl
func encodeBlob(blob : Blob, sink : Sink)
```



### Function `encode`
``` motoko no-repl
func encode(bytes : [Nat8], sink : Sink)
```



### Function `clear`
``` motoko no-repl
func clear()
```

