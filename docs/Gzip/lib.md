# Gzip/lib

## Type `HeaderOptions`
``` motoko no-repl
type HeaderOptions = Header.HeaderOptions
```


## Type `DeflateOptions`
``` motoko no-repl
type DeflateOptions = Deflate.DeflateOptions
```


## Type `Encoder`
``` motoko no-repl
type Encoder = GzipEncoder.Encoder
```


## Type `EncoderBuilder`
``` motoko no-repl
type EncoderBuilder = GzipEncoder.EncoderBuilder
```


## Value `Encoder`
``` motoko no-repl
let Encoder : (Header.HeaderOptions, Deflate.DeflateOptions) -> GzipEncoder.Encoder
```


## Value `EncoderBuilder`
``` motoko no-repl
let EncoderBuilder : () -> GzipEncoder.EncoderBuilder
```


## Value `DefaultEncoder`
``` motoko no-repl
let DefaultEncoder : () -> GzipEncoder.Encoder
```


## Value `Decoder`
``` motoko no-repl
let Decoder : () -> GzipDecoder.Decoder
```

