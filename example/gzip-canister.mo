import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Random "mo:base/Random";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";

import Gzip "../src/Gzip";
import GzipAsyncEncoder "../src/Gzip/AsyncEncoder";
import GzipDecoder "../src/Gzip/Decoder";

import Itertools "mo:itertools/Iter";
import BitBuffer "mo:bitbuffer/BitBuffer";

shared (install) actor class GzipCanister() = gzip_canister {
    type Buffer<A> = Buffer.Buffer<A>;
    type Result<A, B> = Result.Result<A, B>;
    type GzipAsyncEncoder = GzipAsyncEncoder.AsyncEncoder;
    type BitBuffer = BitBuffer.BitBuffer;

    type GzipDetails = {
        encoder : Gzip.Encoder;
        size : Nat;
        var current_chunk : Nat;
        total_chunks : Nat;
    };

    public type Response = {
        block_size : Nat;
        expected_chunk: Nat;
    };

    public type StartTaskResponse = {
        id : Nat;
        block_size : Nat;
        total_chunks : Nat;
    };

    let map = TrieMap.TrieMap<Nat, GzipDetails>(Nat.equal, Nat32.fromNat);
    var task_id = 0;

    func div_ceil(a: Nat, b: Nat): Nat {
        (a + b - 1) / b
    };

    public func start_task(size: Nat): async Result<StartTaskResponse, ()> {
        Debug.print("creating task to compress size = " # debug_show size);

        let id = task_id;
        task_id += 1;

        let encoder = Gzip
            .EncoderBuilder()
            .blockSize(500_000)
            .build();

        let gzip_details = {
            encoder;
            size;
            var current_chunk = 0;
            total_chunks = div_ceil(size, encoder.block_size());
        };

        map.put(id, gzip_details);

        let res = {
            id;
            total_chunks = gzip_details.total_chunks;
            block_size = encoder.block_size();
        };

        Debug.print("assigned task id = " # debug_show id);

        #ok(res);
    };

    type Status = {
        #in_progress : Nat;
        #done : Nat;
    };

    func bitbuffer_to_bytes(bitbuffer: BitBuffer): [Nat8] {
        let nbytes = bitbuffer.bitSize() / 8;
        Debug.print("taking nbytes = " # debug_show nbytes );

        let res = Array.tabulate(
            nbytes,
            func(i: Nat): Nat8{
                let byte = BitBuffer.getByte(bitbuffer, 0);
                BitBuffer.dropByte(bitbuffer);
                byte;
            }
        );

        Debug.print("finished bitbuffer_to_bytes");
        res
    };

    public func compress(id: Nat, data: [Nat8]) : async Result<[Nat8], ?Response> {
        let ?details = map.get(id) else return #err(null);
        let {encoder; size; total_chunks} = details;

        if (data.size() > encoder.block_size()) {
            let res = {
                expected_chunk = details.current_chunk;
                block_size = encoder.block_size();
            };

            return #err(?res);
        };

        encoder.encode(data);

        details.current_chunk += 1;

        if (details.current_chunk == total_chunks){
            let bytes =  encoder.finish();
            map.delete(id);
            return #ok(bytes);
        };

        let bitbuffer = encoder.bitbuffer;
        let bytes = bitbuffer_to_bytes(bitbuffer);
        bitbuffer.clear();

        #ok(bytes);
    };
};