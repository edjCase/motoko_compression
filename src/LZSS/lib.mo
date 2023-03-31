import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import LZSSEncoder "Encoder";
import LzssDecoder "Decoder";

import Common "Common";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    public type LZSSEntry = Common.LZSSEntry;

    public func encode(blob: Blob) : Buffer<LZSSEntry> = LZSSEncoder.encode(blob);

    public type Encoder = LZSSEncoder.Encoder;
    public let Encoder = LZSSEncoder.Encoder;

    public let decode = LzssDecoder.decode;

    public type Decoder = LzssDecoder.Decoder;
    public let Decoder = LzssDecoder.Decoder;
};