## Deflate.mo
This is a compression library that implements the DEFLATE lossless compression algorithm for compressing data into the Gzip format. It is heavily inspired by the [libflate](https://github.com/sile/libflate) rust library.


## Usage
- Example for compressing data below the block size limit (1MB)
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
- Example for compressing data above the block size limit (1MB)
```motoko
actor {
    let gzip_encoder = GzipEncoder.EncoderBuilder().build();
    
    stable var _compressed :?GzipEncoder.EncodedResponse = null;

    public func compress_data(data : [Nat8]) : async (){
        let chunks_iter = Itertools.chunks(data.vals(), block_size);
        
        for (chunk in chunks_iter){
            await compress(chunk);
        };
        
        _compressed := ?gzip_encoder.finish(); // returns the encoded response and resets the encoder
    };

    let gzip_decoder = GzipDecoder.Decoder();

    public shared ({caller}) func decode(chunk: [Nat8]) : async () {
        assert caller == canisterId();
        gzip_decoder.decode(chunk);
    };
 
    public func decode_data() : async Gzip.DecodedResponse {
        let ?compressed = _compressed else return false;
        
        for (chunk in compressed.chunks.vals()){
            await decode(chunk);
        };

        let decoded_response =  gzip_decoder.finish(); // returns the decoded response and resets the decoder

        return decoded_response;
    };

    public shared ({caller}) func compress(chunk: [Nat8]) : async () {
        assert caller == canisterId();

        gzip_encoder.encode(chunk);
    };

    func canisterId() : Principal {
        Principal.fromActor(self);
    };

};
```

## Resources
[Deflate's RFC Standard](https://www.rfc-editor.org/rfc/rfc1951#section-1.5)

[Implementation in rust (libflate)](https://github.com/sile/libflate)

Data Compression Lectures: [Lempel-Ziv Schemes](https://www.youtube.com/watch?v=VDXBnmr8AY0&list=PLU4IQLU9e_OpnkbCS_to64F_vw5yyg4HB&index=4) and [DEFLATE (gzip)](https://www.youtube.com/watch?v=oi2lMBBjQ8s&t=4038s)

https://github.com/billbird/gzstat/blob/master/gzstat.py