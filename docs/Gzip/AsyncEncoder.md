# Gzip/AsyncEncoder

## Class `AsyncEncoderBuilder`

``` motoko no-repl
class AsyncEncoderBuilder(data_size : Nat)
```


### Function `header`
``` motoko no-repl
func header(options : Header) : AsyncEncoderBuilder
```



### Function `noCompression`
``` motoko no-repl
func noCompression() : AsyncEncoderBuilder
```



### Function `dynamicHuffman`
``` motoko no-repl
func dynamicHuffman() : AsyncEncoderBuilder
```



### Function `fixedHuffman`
``` motoko no-repl
func fixedHuffman() : AsyncEncoderBuilder
```



### Function `lzss`
``` motoko no-repl
func lzss(encoder : Lzss.Encoder) : AsyncEncoderBuilder
```



### Function `blockSize`
``` motoko no-repl
func blockSize(size : Nat) : AsyncEncoderBuilder
```



### Function `build`
``` motoko no-repl
func build() : AsyncEncoder
```


## Class `AsyncEncoder`

``` motoko no-repl
class AsyncEncoder(data_size : Nat, header : Header, deflate_options : DeflateOptions)
```


### Function `encode`
``` motoko no-repl
func encode(bytes : [Nat8])
```



### Function `finish`
``` motoko no-repl
func finish()
```



### Function `onComplete`
``` motoko no-repl
func onComplete(fn : OnCompleteFn)
```

