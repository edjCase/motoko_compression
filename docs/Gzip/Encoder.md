# Gzip/Encoder

## Type `EncodedResponse`
``` motoko no-repl
type EncodedResponse = { chunks : [[Nat8]]; total_size : Nat }
```


## Class `EncoderBuilder`

``` motoko no-repl
class EncoderBuilder()
```

Configure the header and deflate options for a Gzip Encoder

### Function `header`
``` motoko no-repl
func header(options : Header) : EncoderBuilder
```

Configure the header options for a Gzip Encoder


### Function `noCompression`
``` motoko no-repl
func noCompression() : EncoderBuilder
```



### Function `dynamicHuffman`
``` motoko no-repl
func dynamicHuffman() : EncoderBuilder
```

Set the huffman encoding to dynamic


### Function `fixedHuffman`
``` motoko no-repl
func fixedHuffman() : EncoderBuilder
```

Set the huffman encoding to fixed


### Function `lzss`
``` motoko no-repl
func lzss(lzss_encoder : Lzss.Encoder) : EncoderBuilder
```

Set the lzss encoder


### Function `blockSize`
``` motoko no-repl
func blockSize(size : Nat) : EncoderBuilder
```

Set the block size for the encoder


### Function `build`
``` motoko no-repl
func build() : Encoder
```

Returns the configured Gzip Encoder

## Class `Encoder`

``` motoko no-repl
class Encoder(header : Header, deflate_options : DeflateOptions)
```

Gzip Encoder

### Inputs
- `header` : [Header]() - the header options for the encoder
- `deflate_options` : [DeflateOptions]() - options for the deflate aglorithms


### Value `bitbuffer`
``` motoko no-repl
let bitbuffer
```



### Function `block_size`
``` motoko no-repl
func block_size() : Nat
```

Returns the block size for the encoder


### Function `encode`
``` motoko no-repl
func encode(bytes : [Nat8])
```

Compresses a byte array and adds it to the internal buffer


### Function `encodeText`
``` motoko no-repl
func encodeText(text : Text)
```

Compresses text and adds it to the internal buffer


### Function `encodeBlob`
``` motoko no-repl
func encodeBlob(blob : Blob)
```

Compresses a Blob and adds it to the internal buffer


### Function `encodeBuffer`
``` motoko no-repl
func encodeBuffer(buffer : Buffer<Nat8>)
```

Compresses data in a Buffer and adds it to the internal buffer


### Function `clear`
``` motoko no-repl
func clear()
```

Clears the internal state of the encoder


### Function `finish`
``` motoko no-repl
func finish() : EncodedResponse
```

Returns the compressed data as a byte array and clears the internal state
