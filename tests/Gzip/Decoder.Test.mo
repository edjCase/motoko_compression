import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

import ActorSpec "../utils/ActorSpec";
import Gzip "../../src/Gzip";
import Example "../data-files/dickens5";

let {
    assertTrue; assertFalse; assertAllTrue; 
    describe; it; skip; pending; run
} = ActorSpec;

let success = run([
    describe("Gzip Decoder", [
        it("Non compressed blocks", do {
            let compressed_bytes : [Nat8] = [0x1F, 0x8B, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x03, 0x01, 0x0B, 0x00, 0xF4, 0xFF, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x56, 0xB1, 0x17, 0x4A, 0x0B, 0x00, 0x00, 0x00];
            let gzip_decoder = Gzip.Decoder();

            gzip_decoder.decode(compressed_bytes);
            let res = gzip_decoder.finish();
            let decoded = Blob.fromArray(Buffer.toArray(res.buffer));

            assertTrue(
                decoded == "Hello World",
            );
        }),
        it("Fixed Compression", do{
            let compressed_bytes : [Nat8] = [0x1F, 0x8B, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x03, 0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0x57, 0x08, 0xCF, 0x2F, 0xCA, 0x49, 0x01, 0x00, 0x56, 0xB1, 0x17, 0x4A, 0x0B, 0x00, 0x00, 0x00];
            let gzip_decoder = Gzip.Decoder();
            
            gzip_decoder.decode(compressed_bytes);
            let res = gzip_decoder.finish();
            let decoded = Blob.fromArray(Buffer.toArray(res.buffer));

            assertTrue(
                decoded == "Hello World",
            );
        }),

        it("Fixed Compression: short example", do {
            let compressed_bytes : [Nat8] = [0x1F, 0x8B, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x03, 0xF3, 0xC9, 0x2C, 0x49, 0x2D, 0x4A, 0x2C, 0x29, 0x2D, 0x4A, 0x55, 0xC8, 0x2C, 0x56, 0x48, 0x2B, 0xCD, 0xC9, 0x51, 0xC8, 0x4F, 0x53, 0x28, 0x4A, 0x2D, 0x48, 0x2D, 0xC9, 0x2C, 0xC9, 0xCC, 0xCF, 0xD3, 0x53, 0x80, 0xA8, 0x28, 0xAA, 0x54, 0x28, 0x2F, 0x02, 0xB1, 0x8A, 0x15, 0x92, 0xF3, 0xF3, 0x8A, 0x4B, 0x12, 0xF3, 0x4A, 0x72, 0x2A, 0x15, 0x4A, 0x8B, 0x53, 0x15, 0x4A, 0x32, 0x52, 0x15, 0x72, 0x40, 0x32, 0x20, 0x35, 0x29, 0xA9, 0x65, 0x99, 0xC9, 0xA9, 0x30, 0x23, 0x12, 0x4B, 0x52, 0x53, 0x14, 0xCA, 0xF3, 0x8B, 0x52, 0x8A, 0xF5, 0x14, 0x3C, 0x81, 0x0A, 0x33, 0xF3, 0xB2, 0x81, 0x24, 0x50, 0x3A, 0x0F, 0xA8, 0xB7, 0xA4, 0xB2, 0x00, 0xC8, 0x82, 0x28, 0x84, 0xD8, 0xA5, 0x50, 0x9E, 0x91, 0x99, 0x9C, 0x01, 0x72, 0x47, 0x52, 0x62, 0x0A, 0x88, 0x2A, 0xCE, 0xC9, 0x2F, 0x28, 0xA8, 0x44, 0x52, 0xA1, 0xA7, 0x10, 0x04, 0x67, 0x23, 0x54, 0x97, 0xE6, 0x65, 0xE6, 0x95, 0xA4, 0xE6, 0x81, 0x04, 0x13, 0x73, 0x74, 0xA0, 0xE2, 0xC5, 0xF9, 0xA5, 0x79, 0x29, 0xC5, 0x0A, 0x89, 0xE5, 0xD9, 0xE5, 0x89, 0x45, 0x29, 0x7A, 0x00, 0x7E, 0x9C, 0xB5, 0x21, 0xE8, 0x00, 0x00, 0x00];
            let gzip_decoder = Gzip.Decoder();
            
            gzip_decoder.decode(compressed_bytes);
            let res = gzip_decoder.finish();
            let decoded = Blob.fromArray(Buffer.toArray(res.buffer));

            assertTrue(
                decoded == "Literature is full of repetition. Literary writers constantly use the literary device of repeated words. I think the only type of repetition which is bad is sloppy repetition. Repetition which is unintentional, which sounds awkward.",
            );
        }),
        it("Fixed Compression: long example", do{
            let blob = Example.fixed_code_compression;
            let compressed_bytes : [Nat8] = Blob.toArray(blob);
            let gzip_decoder = Gzip.Decoder();
            
            gzip_decoder.decode(compressed_bytes);
            let res = gzip_decoder.finish();
            let decoded = Blob.fromArray(Buffer.toArray(res.buffer));

            assertTrue(
                decoded == Text.encodeUtf8(Example.text),
            );
        }),
        it("Dynamic Compression: short example", do{
            let blob : Blob = "\1f\8b\08\00\00\00\00\00\00\03\6d\8e\d1\09\c3\30\0c\44\57\d1\00\25\7b\14\f2\d5\0d\d4\58\21\22\46\32\92\5c\e3\ed\1b\87\e6\23\d0\2f\1d\c7\bb\d3\cd\1c\64\18\d5\08\d8\61\ad\39\83\ae\60\54\28\38\58\65\82\f9\24\ac\43\b3\a1\1c\16\15\0f\94\c8\1d\aa\13\c4\46\90\2f\26\d1\87\17\ba\2a\30\28\41\53\4b\3e\c1\f3\00\59\f6\13\57\39\b2\d1\0b\dd\7f\41\db\78\d9\c6\8e\37\a6\71\3c\6b\29\fd\b6\e6\f5\87\ae\c2\12\24\c3\c4\fc\f8\f9\ae\55\92\03\b6\bd\a1\a5\e9\0b\7e\9c\b5\21\e8\00\00\00";
            let compressed_bytes = Blob.toArray(blob);

            let gzip_decoder = Gzip.Decoder();
            gzip_decoder.decode(compressed_bytes);
            let res = gzip_decoder.finish();
            let decoded = Blob.fromArray(Buffer.toArray(res.buffer));
            
            assertTrue(
                decoded == "Literature is full of repetition. Literary writers constantly use the literary device of repeated words. I think the only type of repetition which is bad is sloppy repetition. Repetition which is unintentional, which sounds awkward.",
            )
        }),

        it("Dynamic Compression: long example", do{
            let blob : Blob = Example.dynamic_code_compression;
            let compressed_bytes = Blob.toArray(blob);

            let gzip_decoder = Gzip.Decoder();
            gzip_decoder.decode(compressed_bytes);
            let res = gzip_decoder.finish();
            let decoded = Blob.fromArray(Buffer.toArray(res.buffer));
            
            assertTrue(
                decoded == Text.encodeUtf8(Example.text),
            )
        
        }),
    ])
]);

if(success == false){
  Debug.trap("\1b[46;41mTests failed\1b[0m");
}else{
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};