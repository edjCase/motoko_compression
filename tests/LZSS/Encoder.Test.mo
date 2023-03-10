import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import It "mo:itertools/Iter";

import ActorSpec "../utils/ActorSpec";

import LZSS "../../src/LZSS";
import Dickens "../data-files/dickens5";

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

func _size(buffer : Buffer.Buffer<LZSS.LZSSEntry>) : Nat {
    var size = 0;
    for (entry in buffer.vals()) {
        switch (entry) {
            case (#literal(_)) {
                size += 1;
            };
            case (#pointer(_, _)) {
                size += 2;
            };
        };
    };

    size;
};

let success = run([
    describe(
        "LZSS Encoding",
        [
            it(
                "encoding",
                do {
                    let bytes = Text.encodeUtf8("abracadabra");
                    let encoded = LZSS.encode(bytes);
                    let decoded = LZSS.decode(encoded);
                    assertTrue(bytes == decoded);
                },
            ),
            describe(
                "encode repeated patterns",
                [
                    // it(
                    //     "'abcaaaaad' -> 'abc<3,5>d'",
                    //     do {
                    //         let bytes = Text.encodeUtf8("abcaaaaad");
                    //         let encoded = LZSS.encode(bytes);

                    //         Buffer.toArray(encoded) == [
                    //             #literal(0x61 : Nat8),
                    //             #literal(0x62 : Nat8),
                    //             #literal(0x63 : Nat8),
                    //             #pointer(3, 5),
                    //             #literal(0x64 : Nat8),
                    //         ];
                    //     },
                    // ),

                    // it(
                    //     "'fr-en-ch-en-en-end' -> 'fr-en-ch<6,9>d'",
                    //     do {
                    //         let bytes = Text.encodeUtf8("fr-en-ch-en-en-end");
                    //         let encoded = LZSS.encode(bytes);

                    //         Buffer.toArray(encoded) == [
                    //             #literal(0x66 : Nat8),
                    //             #literal(0x72 : Nat8),
                    //             #literal(0x2d : Nat8),
                    //             #literal(0x65 : Nat8),
                    //             #literal(0x6e : Nat8),
                    //             #literal(0x2d : Nat8),
                    //             #literal(0x63 : Nat8),
                    //             #literal(0x68 : Nat8),
                    //             #pointer(6, 9),
                    //             #literal(0x64 : Nat8),
                    //         ];
                    //     },
                    // ),

                ],
            ),
            describe(
                "Multi Step Encoder class",
                [
                    it(
                        "encoding",
                        do {
                            let bytes = Text.encodeUtf8("abracadabra");
                            let lzss = LZSS.Encoder(null);
                            let buffer = Buffer.Buffer<LZSS.LZSSEntry>(8);

                            lzss.encodeBlob(bytes, buffer);

                            let decoded = LZSS.decode(buffer);
                            assertTrue(bytes == decoded);
                        },
                    ),
                    it(
                        "Prefix Encoder",
                        do {
                            for (i in It.range(0, 2)) {

                                let lzss = LZSS.Encoder(null);
                                let blob = Text.encodeUtf8(Dickens.text);
                                let buffer = Buffer.Buffer<LZSS.LZSSEntry>(8);
                                lzss.encodeBlob(blob, buffer);

                                Debug.print("No: " # debug_show (i + 1));
                                Debug.print("Dickens text size: " # debug_show (lzss.size()));

                                let decoded = LZSS.decode(buffer);
                                assert decoded == blob;
                            };
                            Debug.print("Prefix Encoder: Success!");
                            assertTrue(true);
                        },
                    ),
                ],
            ),
        ],
    ),
]);

if (success == false) {
    Debug.trap("\1b[46;41mTests failed\1b[0m");
} else {
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
