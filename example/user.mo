import Timer "mo:base/Timer";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Gzip "../src/Gzip";
import GzipEncoder "../src/Gzip/Encoder";
import GzipDecoder "../src/Gzip/Decoder";

import GzipCanister "gzip-canister";

import ArrayMod "mo:array/Array";

actor {
    type Buffer<A> = Buffer.Buffer<A>;
    type Result<A, B> = Result.Result<A, B>;

    stable var _data : ?[Nat8] = null;

    public func generate_data() : async () {
        let seed : Blob = await Random.blob();
        let finite = Random.Finite(seed);

        _data := ?(Array.tabulate<Nat8>(
            3_000_000,
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

    let gzip_canister : GzipCanister.GzipCanister = actor("bw4dl-smaaa-aaaaa-qaacq-cai");
    
    let compressed_chunks = Buffer.Buffer<[Nat8]>(8);


    public func encode_data() : async () {
        compressed_chunks.clear();
        
        let data = get_data();
        let #ok(details) = await gzip_canister.start_task(data.size()) else Debug.trap("Failed to start task");
        
        let { id; total_chunks; block_size } = details;

        var chunk_index = 0;
        while (chunk_index < total_chunks){
            let chunk = ArrayMod.slice(data, chunk_index * block_size, (chunk_index + 1) * block_size);
            let #ok(compressed) = await gzip_canister.compress(id, chunk) else Debug.trap("Failed to encode");
            compressed_chunks.add(compressed);
            Debug.print("Compressed chunks: " # debug_show compressed_chunks.size());
        };
    };

    var task_details : ?gzip_canister.StartTaskResponse = null;

    public func start() : async gzip_canister.StartTaskResponse {
        let data = get_data();

        let #ok(details) = await gzip_canister.start_task(data.size()) else Debug.trap("Failed to start task");
        task_details := ?details;
        details;
    };

    public func compress(chunk_index: Nat) : async () {

        ignore do ? {
            let { id; total_chunks; block_size } = task_details!;

            let data = get_data();

            let chunk = ArrayMod.slice(data, chunk_index * block_size, (chunk_index + 1) * block_size);
            let #ok(compressed) = await gzip_canister.compress(id, chunk) else Debug.trap("Failed to encode");
            compressed_chunks.add(compressed);
        };  
        
    };

    public func decode_data() : async Bool {
        let gzip_decoder = GzipDecoder.Decoder();

        for (chunk in compressed_chunks.vals()){
            gzip_decoder.decode(chunk);
        };

        let res = gzip_decoder.finish();
        Buffer.toArray(res.buffer) == get_data();
    };
};
