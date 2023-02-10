import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import LZSSEncoder "Encoder";
import Decoder "Decoder";

import Common "Common";
import LinearScanEncoder "Encoder/LinearScanEncoder";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    public type LZSSEntry = Common.LZSSEntry;

    public func encode(blob: Blob) : Buffer<LZSSEntry> = LZSSEncoder.encode(blob);
    public let decode = Decoder.decode;
    
    public let PrefixTableEncoder = LZSSEncoder.PrefixTableEncoder;
    public let LinearScanEncoder = LZSSEncoder.LinearScanEncoder;

}