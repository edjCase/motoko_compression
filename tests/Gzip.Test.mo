import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Blob "mo:base/Blob";

import ActorSpec "./utils/ActorSpec";
import Gzip "../src/Gzip";
import Dickens "./data-files/dickens7";

let {
    assertTrue;
    assertFalse;
    assertAllTrue;
    describe;
    it;
    skip;
    pending;
    run;
} = ActorSpec;

let success = run([
    describe(
        " Gzip ",
        [
            it(
                "No compression",
                do {
                    let gzip_encoder = Gzip.EncoderBuilder().noCompression().build();
                    let input = Text.encodeUtf8("Hello World");
                    let bytes = Blob.toArray(input);

                    gzip_encoder.encode(bytes);
                    let output = gzip_encoder.finish();

                    assertTrue(
                        Blob.toArray(output) == [0x1F, 0x8B, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x03, 0x01, 0x0B, 0x00, 0xF4, 0xFF, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x56, 0xB1, 0x17, 0x4A, 0x0B, 0x00, 0x00, 0x00],
                    );
                },
            ),

            describe("Compression: Fixed Huffman codes", [
                it(
                    "Compress \"Hello world\" (no back references)",
                    do {
                        let gzip_encoder = Gzip.DefaultEncoder();
                        let input = Text.encodeUtf8("Hello World");
                        let bytes = Blob.toArray(input);

                        gzip_encoder.encode(bytes);
                        let output = gzip_encoder.finish();

                        assertTrue( Blob.toArray(output) == [0x1F, 0x8B, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x03, 0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0x57, 0x08, 0xCF, 0x2F, 0xCA, 0x49, 0x01, 0x00, 0x56, 0xB1, 0x17, 0x4A, 0x0B, 0x00, 0x00, 0x00] );
                    },
                ),
                it(
                    "Compress short text",
                    do {
                        let gzip_encoder = Gzip.DefaultEncoder();
                        let text = "Literature is full of repetition. Literary writers constantly use the literary device of repeated words. I think the only type of repetition which is bad is sloppy repetition. Repetition which is unintentional, which sounds awkward.";
                        let input = Text.encodeUtf8(text);
                        let bytes = Blob.toArray(input);

                        gzip_encoder.encode(bytes);
                        let output = gzip_encoder.finish();
                        Debug.print("short text example: " # debug_show (text.size()) # " -> " # debug_show output.size() # " bytes");
                        assertTrue( true );
                    },
                ),
                it("Compression of large files with Fixed Huffman codes", do{
                    let gzip_encoder = Gzip.DefaultEncoder();
                    let input = Text.encodeUtf8(Dickens.text);
                    let bytes = Blob.toArray(input);

                    gzip_encoder.encode(bytes);
                    let output = gzip_encoder.finish();

                    Debug.print("Dickens example: " # debug_show (Dickens.text.size()) # " -> " # debug_show output.size() # " bytes");
                    assertTrue( true );
                })
            ]),

            
        ],
    )
]);

if (success == false) {
    Debug.trap("\1b[46;41mTests failed\1b[0m");
} else {
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
