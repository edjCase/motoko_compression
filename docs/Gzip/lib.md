# Gzip/lib

## Type `Header`
``` motoko no-repl
type Header = Header.Header
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
let Encoder : (Header.Header, Deflate.DeflateOptions) -> GzipEncoder.Encoder
```


## Value `EncoderBuilder`
``` motoko no-repl
let EncoderBuilder : () -> GzipEncoder.EncoderBuilder
```


## Type `Decoder`
``` motoko no-repl
type Decoder = GzipDecoder.Decoder
```


## Value `Decoder`
``` motoko no-repl
let Decoder : () -> GzipDecoder.Decoder
```

