# Gzip/Encoder

## Class `EncoderBuilder`

``` motoko no-repl
class EncoderBuilder()
```


### Function `header`
``` motoko no-repl
func header(options : HeaderOptions) : EncoderBuilder
```



### Function `noCompression`
``` motoko no-repl
func noCompression() : EncoderBuilder
```



### Function `lzss`
``` motoko no-repl
func lzss(encoder : Lzss.Encoder) : EncoderBuilder
```



### Function `blockSize`
``` motoko no-repl
func blockSize(size : Nat) : EncoderBuilder
```



### Function `build`
``` motoko no-repl
func build() : Encoder
```


## Function `DefaultEncoder`
``` motoko no-repl
func DefaultEncoder() : Encoder
```


## Class `Encoder`

``` motoko no-repl
class Encoder(header_options : HeaderOptions, deflate_options : DeflateOptions)
```


### Function `encode`
``` motoko no-repl
func encode(bytes : [Nat8])
```



### Function `finish`
``` motoko no-repl
func finish() : Blob
```

