import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

import ActorSpec "./utils/ActorSpec";
import Gzip "../src/Gzip";

let {
    assertTrue; assertFalse; assertAllTrue; 
    describe; it; skip; pending; run
} = ActorSpec;

let success = run([
    describe(" Gzip ", [
        it("encode", do {
            let gzip_encoder = Gzip.DefaultEncoder();
           assertTrue(true)
        }),
    ])
]);

if(success == false){
  Debug.trap("\1b[46;41mTests failed\1b[0m");
}else{
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};