import Encoder "Encoder";
import Decoder "Decoder";

import Common "Common";

module {
    public type LZSSEntry = Common.LZSSEntry;

    public let encode = Encoder.encode;
    public let decode = Decoder.decode;

}