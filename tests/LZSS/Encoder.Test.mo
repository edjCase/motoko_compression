import Array "mo:base@0/Array";
import Blob "mo:base@0/Blob";
import Buffer "mo:base@0/Buffer";
import Debug "mo:base@0/Debug";
import Iter "mo:base@0/Iter";
import Nat "mo:base@0/Nat";
import Text "mo:base@0/Text";

import It "mo:itertools@0/Iter";

import ActorSpec "../utils/ActorSpec";

import Lzss "../../src/LZSS";
import Example "../data-files/dickens5";

type LzssEntry = Lzss.LzssEntry;

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

func _size(buffer : Buffer.Buffer<Lzss.LzssEntry>) : Nat {
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
    "Lzss Encoding",
    [
      // it(
      //     "encoding",
      //     do {
      //         let blob = Text.encodeUtf8("abracadabra");
      //         let bytes = Blob.toArray(blob);

      //         let encoded = Lzss.encode(bytes);
      //         let decoded = Lzss.decode(encoded);
      //         assertTrue(bytes == Buffer.toArray(decoded));
      //     },
      // ),
      describe(
        "encode repeated patterns",
        [
          // it(
          //     "'abcaaaaad' -> 'abc<3,5>d'",
          //     do {
          //         let bytes = Text.encodeUtf8("abcaaaaad");
          //         let encoded = Lzss.encode(bytes);

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
          //         let encoded = Lzss.encode(bytes);

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
        "Class Encoder",
        [
          // it(
          //     "encoding",
          //     do {
          //         let blob = Text.encodeUtf8("abracadabra");
          //         let bytes = Blob.toArray(blob);
          //         let lzss = Lzss.Encoder(null);
          //         let buffer = Buffer.Buffer<LzssEntry>(8);

          //         lzss.encode(bytes, buffer);
          //         let decoded = Lzss.decode(buffer);
          //         Debug.print(debug_show (bytes.size(), decoded.size()));
          //         assertTrue(bytes == Buffer.toArray(decoded));
          //     },
          // ),
          it(
            "Prefix Encoder",
            do {
              var j = 0;
              for (i in It.range(0, 2)) {

                let lzss = Lzss.Encoder(null);
                let blob = Text.encodeUtf8(Example.text);
                let bytes = Blob.toArray(blob);

                let buffer = Buffer.Buffer<LzssEntry>(8);
                let buffer2 = Buffer.Buffer<LzssEntry>(8);

                lzss.encode_v1(bytes, buffer2);
                lzss.clear();

                label l for (byte in bytes.vals()) {
                  lzss.encode_byte(byte, buffer);

                  if (buffer.size() == 0) continue l;

                  let i = buffer.size() - 1 : Nat;

                  let b = buffer.get(i);
                  let a = buffer2.get(i);

                  if (i != j) {
                    Debug.print("i = " # debug_show i # " -> " #debug_show (a, b));
                    j := i;
                  };

                  assert a == b;
                };

                // lzss.encode(bytes, buffer);
                lzss.finish(buffer);

                let decoded = Lzss.decode(buffer);
                assert Buffer.toArray(decoded) == bytes;
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
