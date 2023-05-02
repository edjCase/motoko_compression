## Deflate.mo
This is a compression library that implements the DEFLATE lossless compression algorithm for compressing data into the Gzip format. It is heavily inspired by the [libflate](https://github.com/sile/libflate) rust library.


## Usage
```motoko
import Blob "mo:base/Blob";
import Text "mo:base/Text";

import Gzip "mo:deflate/Gzip";

let data = Blob.toArray(Text.encodeUtf8("Hello, world!"));

let gzip_encoder = Gzip.EncoderBuilder().build();
gzip_encoder.encode(data);
let compressed = gzip_encoder.finish();

let gzip_decoder = Gzip.Decoder();
gzip_decoder.decode(compressed);
let decompressed = gzip_decoder.finish();

assert (decompressed.bytes == data);
```

## Resources
[Deflate's RFC Standard](https://www.rfc-editor.org/rfc/rfc1951#section-1.5)

[Implementation in rust (libflate)](https://github.com/sile/libflate)

Data Compression Lectures: [Lempel-Ziv Schemes](https://www.youtube.com/watch?v=VDXBnmr8AY0&list=PLU4IQLU9e_OpnkbCS_to64F_vw5yyg4HB&index=4) and [DEFLATE (gzip)](https://www.youtube.com/watch?v=oi2lMBBjQ8s&t=4038s)

https://github.com/billbird/gzstat/blob/master/gzstat.py