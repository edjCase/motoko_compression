import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";

import It "mo:itertools/Iter";

import Common "Common";

module{
    type Buffer<A> = Buffer.Buffer<A>;
    type LZSSEntry = Common.LZSSEntry;

    public func decode (compressed_buffer: Buffer<LZSSEntry>): Blob {
        let compressed_data = Buffer.toArray(compressed_buffer);
        let bytes = Buffer.Buffer<Nat8>(8);

        for (entry in compressed_data.vals()) {
            switch(entry){
                case(#byte(byte)){
                    bytes.add(byte);
                };
                case(#ref((backward_offset, len))){
                    let index = bytes.size() - backward_offset;

                    for (i in It.range(index, index + len)){
                        bytes.add(bytes.get(i));
                    };
                };
            }
        };

        let array = Buffer.toArray(bytes);
        Blob.fromArray(array);
    };
}