# Deflate/Decoder

## Class `Decoder`

``` motoko no-repl
class Decoder(bitreader : BitReader, output_buffer : ?Buffer.Buffer<Nat8>)
```


### Function `decode`
``` motoko no-repl
func decode() : Result<(), Text>
```



### Function `finish`
``` motoko no-repl
func finish() : Result<(), Text>
```

