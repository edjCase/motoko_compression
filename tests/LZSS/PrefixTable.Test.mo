import Debug "mo:base@0/Debug";
import Iter "mo:base@0/Iter";

import ActorSpec "../utils/ActorSpec";
import PrefixTable "../../src/LZSS/Encoder/PrefixTable";

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
    "Prefix Table",
    [
      it(
        "insert()",
        do {
          let table = PrefixTable.PrefixTable();

          let bytes : [Nat8] = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5];

          assertAllTrue([
            table.insert(bytes, 0, 3, 0) == null, // [1, 2, 3]
            table.insert(bytes, 1, 3, 1) == null, // [2, 3, 4]
            table.insert(bytes, 2, 3, 2) == null, // [3, 4, 5]

            table.insert(bytes, 5, 3, 5) == ?0,
            table.insert(bytes, 6, 3, 6) == ?1,
            table.insert(bytes, 7, 3, 7) == ?2,

            table.insert(bytes, 10, 3, 10) == ?5,
            table.insert(bytes, 11, 3, 11) == ?6,
            table.insert(bytes, 12, 3, 12) == ?7,
          ]);
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
