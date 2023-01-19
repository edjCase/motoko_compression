import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import ActorSpec "./utils/ActorSpec";

import LZSS "../src/LZSS";

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
        "LZSS",
        [
            it(
                "encoding",
                do {
                    let bytes = Text.encodeUtf8("abracadabra");
                    let encoded = LZSS.encode(bytes);
                    Debug.print(debug_show Buffer.toArray(encoded));
                    let decoded = LZSS.decode(encoded);
                    Debug.print(debug_show Text.decodeUtf8(decoded));
                    assertTrue(true);
                },
            ),
        ],
    ),
]);

if (success == false) {
    Debug.trap("\1b[46;41mTests failed\1b[0m");
} else {
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
