# LZSS/Encoder/lib

## Type `Sink`
``` motoko no-repl
type Sink = { add : (entry : LzssEntry) -> () }
```


## Function `Default`
``` motoko no-repl
func Default() : Encoder
```


## Function `encode`
``` motoko no-repl
func encode(bytes : [Nat8]) : Buffer<LzssEntry>
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



### Function `encode_byte`
``` motoko no-repl
func encode_byte(future_byte : Nat8, sink : Sink)
```



### Function `encode`
``` motoko no-repl
func encode(bytes : [Nat8], sink : Sink)
```



### Function `flush`
``` motoko no-repl
func flush(sink : Sink)
```



### Function `finish`
``` motoko no-repl
func finish(sink : Sink)
```



### Function `clear`
``` motoko no-repl
func clear()
```



### Function `encode_v1`
``` motoko no-repl
func encode_v1(bytes : [Nat8], sink : Sink)
```

