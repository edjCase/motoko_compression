import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";

import BitBuffer "mo:bitbuffer/BitBuffer";
import BitReader "../BitReader";

import Block "Block";
import Symbol "Symbol";
import DeflateEncoder "Encoder";
import DeflateDecoder "Decoder";
import LZSS "../LZSS";
import LzssEncoder "../LZSS/Encoder";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type BitBuffer = BitBuffer.BitBuffer;
    type BitReader = BitReader.BitReader;

    type Iter<A> = Iter.Iter<A>;
    type LzssEntry = LZSS.LzssEntry;
    type LzssEncoder = LzssEncoder.Encoder;
    type Symbol = Symbol.Symbol;

    public type Encoder = DeflateEncoder.Encoder;
    public let Encoder : (BitBuffer, DeflateOptions) -> DeflateEncoder.Encoder = DeflateEncoder.Encoder;

    public type Decoder = DeflateDecoder.Decoder;
    public let Decoder : (BitReader, ?Buffer<Nat8>) -> DeflateDecoder.Decoder = DeflateDecoder.Decoder;

    public type DeflateOptions = {
        block_size: Nat;
        dynamic_huffman: Bool;
        lzss: ?LzssEncoder;
    };

};