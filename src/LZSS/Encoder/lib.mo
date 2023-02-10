import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Deque "mo:base/Deque";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";

import It "mo:itertools/Iter";
import Deiter "mo:itertools/Deiter";
import CircularBuffer "mo:CircularBuffer";

import Common "../Common";
import Utils "../../utils";
import PrefixTableEncoderModule "PrefixTableEncoder";
import LinearScanEncoderModule "LinearScanEncoder";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type CircularBuffer<A> = CircularBuffer.CircularBuffer<A>;
    type Deque<A> = Deque.Deque<A>;
    type Iter<A> = Iter.Iter<A>;

    type LZSSEntry = Common.LZSSEntry;
    type Result<Ok, Err> = Result.Result<Ok, Err>;

    public let PrefixTableEncoder = PrefixTableEncoderModule.PrefixTableEncoder;
    public let LinearScanEncoder = LinearScanEncoderModule.LinearScanEncoder;

    public func encode(blob : Blob) : Buffer<LZSSEntry> {
        let encoder = PrefixTableEncoder();
        encoder.encodeBlob(blob);
        encoder.getCompressedBytes()
    };
};
