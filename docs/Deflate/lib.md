# Deflate/lib

## Type `Encoder`
``` motoko no-repl
type Encoder = DeflateEncoder.Encoder
```


## Value `Encoder`
``` motoko no-repl
let Encoder : (BitBuffer, DeflateOptions) -> DeflateEncoder.Encoder
```


## Type `Decoder`
``` motoko no-repl
type Decoder = DeflateDecoder.Decoder
```


## Value `Decoder`
``` motoko no-repl
let Decoder : (BitReader, ?Buffer<Nat8>) -> DeflateDecoder.Decoder
```


## Type `DeflateOptions`
``` motoko no-repl
type DeflateOptions = { block_size : Nat; dynamic_huffman : Bool; lzss : ?LzssEncoder }
```

