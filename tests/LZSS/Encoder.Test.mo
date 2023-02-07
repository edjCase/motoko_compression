import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import ActorSpec "../utils/ActorSpec";

import LZSS "../../src/LZSS";
import Dickens "../data-files/dickens4";

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

func _size(buffer: Buffer.Buffer<LZSS.LZSSEntry>): Nat{
    var size = 0;
    for (entry in buffer.vals()){
        switch(entry){
            case (#literal(_)) {
                size += 1;
            };
            case (#ref(_, _)) {
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
            // it(
            //     "encoding",
            //     do {
            //         let bytes = Text.encodeUtf8("abracadabra");
            //         let encoded = LZSS.encode(bytes);
            //         Debug.print(debug_show Buffer.toArray(encoded));
            //         let decoded = LZSS.decode(encoded);
            //         Debug.print(debug_show Text.decodeUtf8(decoded));
            //         assertTrue(true);
            //     },
            // ),
            // describe(
            //     "encode repeated patterns",
            //     [
            //         it(
            //             "'abcaaaaad' -> 'abc<3,5>d'",
            //             do {
            //                 let bytes = Text.encodeUtf8("abcaaaaad");

            //                 let encoded = LZSS.encode(bytes);
            //                 Debug.print(debug_show Buffer.toArray(encoded));
            //                 let res = [#literal(0x61), #literal(0x62), #literal(0x63), #ref(3, 5), #literal(0x64)];
            //                 Debug.print(debug_show res);

            //                 Buffer.toArray(encoded) == res;
            //             },
            //         ),

            //         it(
            //             "'fr-en-ch-en-en-end' -> 'fr-en-ch<6,9>d'",
            //             do {
            //                 let bytes = Text.encodeUtf8("fr-en-ch-en-en-end");

            //                 let encoded = LZSS.encode(bytes);
            //                 Debug.print(debug_show Buffer.toArray(encoded));
            //                 let res = [
            //                     #literal(0x66),
            //                     #literal(0x72),
            //                     #literal(0x2d),
            //                     #literal(0x65),
            //                     #literal(0x6e),
            //                     #literal(0x2d),
            //                     #literal(0x63),
            //                     #literal(0x68),
            //                     #ref(6, 9),
            //                     #literal(0x64),
            //                 ];
            //                 Debug.print(debug_show res);

            //                 Buffer.toArray(encoded) == res;
            //             },
            //         ),

            //     ],
            // ),
            // describe("Encode Large text" , [
            //     it("dickens novels", do{
            //         let bytes = Text.encodeUtf8(Dickens.text);
            //         for (_ in Array.init<Nat>(5, 0).vals()){
            //             let encoded = LZSS.encode(bytes);
            //             // Debug.print(debug_show Buffer.toArray(encoded));
            //             let decoded = LZSS.decode(encoded);
            //             // Debug.print(debug_show Text.decodeUtf8(decoded));
            //             Debug.print("Dickens text size: " # debug_show (Dickens.text.size()));
            //             Debug.print("Dickens encoded size: " # debug_show (_size(encoded)));
            //         };

            //         assertTrue(true);
            //     }),
            // ]),

            describe("Multi Step Encoder class" , [
                it("Encoded Large text (dickens novel)", do{
                    let lzss = LZSS.Encoder();

                    let blob = Text.encodeUtf8(Dickens.text);
                    for (_ in Iter.range(1, 5)){
                        await lzss.encodeBlob(blob);
                        // Debug.print(debug_show Text.decodeUtf8(decoded));
                        Debug.print("Dickens text size: " # debug_show (lzss.inputSize()));
                        Debug.print("Dickens encoded size: " # debug_show (lzss.size()));
                    };

                    assertTrue(true);
                }),
            ]),
        ],
    ),
]);

if (success == false) {
    Debug.trap("\1b[46;41mTests failed\1b[0m");
} else {
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
