import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Random "mo:base/Random";
import Iter "mo:base/Iter";
import Result "mo:base/Result";

import Gzip "../src/Gzip";
import GzipAsyncEncoder "../src/Gzip/AsyncEncoder";
import GzipDecoder "../src/Gzip/Decoder";

import Itertools "mo:itertools/Iter";

actor {
    type Result<A, B> = Result.Result<A, B>;

    stable var _data : ?[Nat8] = null;

    let CHUNK_SIZE = 500_000;
    public func generate_data(n : Nat) : async () {
        let seed : Blob = await Random.blob();
        let finite = Random.Finite(seed);

        _data := ?(
            Array.tabulate<Nat8>(
                n * CHUNK_SIZE,
                func(i : Nat) : Nat8 {
                    let ?byte = finite.byte() else return Random.byteFrom(seed);
                    byte;
                },
            )
        );
    };

    func get_data() : [Nat8] {
        switch (_data) {
            case (?d) return d;
            case (_) return [];
        };
    };

    var gzip_encoder = GzipAsyncEncoder
            .AsyncEncoderBuilder(0)
            .build();

    public func encode_chunk(chunk: [Nat8]) : async(){
        gzip_encoder.encode(chunk);
    };

    public func encode() : async () {
        let data = get_data();
        let chunks : Iter.Iter<[Nat8]> = Itertools.chunks<Nat8>(data.vals(), CHUNK_SIZE);
        let input = Blob.fromArray(data);

        gzip_encoder := GzipAsyncEncoder
            .AsyncEncoderBuilder(data.size())
            .build();

        for (chunk in chunks) {
            ignore encode_chunk(chunk);
        };

        gzip_encoder.finish();

        gzip_encoder.onComplete(
            func(res : Result<[Nat8], ()>) {
                switch (res) {
                    case (#ok(output)) {
                        Debug.print("Example: " # debug_show (data.size()) # " -> " # debug_show output.size() # " bytes");

                        let gzip_decoder = GzipDecoder.Decoder();
                        gzip_decoder.decode(output);
                        let decoded = gzip_decoder.finish();
                
                        assert (data == Buffer.toArray(decoded.buffer));
                    };
                    case (#err(_)) {
                        Debug.print("Example: " # debug_show (data.size()) # " -> " # debug_show "failed");
                    };
                };
            }
        );
    };
};
