import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Random "mo:base/Random";
import Gzip "../src/Gzip";
import GzipEncoder "../src/Gzip/Encoder";
import GzipDecoder "../src/Gzip/Decoder";

actor {
    stable var _data : ?[Nat8] = null;

    public func generate_data() : async () {
        let seed : Blob = await Random.blob();
        let finite = Random.Finite(seed);

        _data := ?(Array.tabulate<Nat8>(
            1_000_000,
            func(i : Nat) : Nat8 {
                let ?byte = finite.byte() else return Random.byteFrom(seed);
                byte;
            },
        ));
    };

    func get_data() : [Nat8] {
        switch(_data) {
            case (?d) return d;
            case (_) return [];
        };
    };

    public func encode() : async () {
        let data = get_data();
        let input = Blob.fromArray(data);

        let gzip_encoder = GzipEncoder.EncoderBuilder().build();
        gzip_encoder.encode(data);
        let output = gzip_encoder.finish();
        Debug.print("Example: " # debug_show (data.size()) # " -> " # debug_show output.size() # " bytes");

        let gzip_decoder = GzipDecoder.Decoder();
        gzip_decoder.decode(output);
        let decoded = gzip_decoder.finish();

        assert (data == Buffer.toArray(decoded.buffer));
    };
};
