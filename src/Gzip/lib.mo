import GzipEncoder "Encoder";
import GzipDecoder "Decoder";
import Header "Header";

import Deflate "../Deflate";

module {
    public type HeaderOptions = Header.HeaderOptions;
    public type DeflateOptions = Deflate.DeflateOptions;
    
    public type Encoder = GzipEncoder.Encoder;
    public type EncoderBuilder = GzipEncoder.EncoderBuilder;

    public let Encoder : (Header.HeaderOptions, Deflate.DeflateOptions) ->  GzipEncoder.Encoder = GzipEncoder.Encoder;
    public let EncoderBuilder : () -> GzipEncoder.EncoderBuilder = GzipEncoder.EncoderBuilder;
    public let DefaultEncoder : () -> GzipEncoder.Encoder = GzipEncoder.DefaultEncoder;

    public let Decoder : () -> GzipDecoder.Decoder = GzipDecoder.Decoder;
}