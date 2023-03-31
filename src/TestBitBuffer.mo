import BitBuffer "mo:bitbuffer/BitBuffer";
import Dickens "../tests/data-files/dickens5";
import Debug "mo:base/Debug";

module {

    type BitBuffer = BitBuffer.BitBuffer;
    public func bitbuffer() : BitBuffer.BitBuffer = BitBuffer.fromBytes(Dickens.compressed);

    public func test(testbuffer : BitBuffer, bitbuffer : BitBuffer, n : Nat, original: Nat, msg : Text) {
        let start = bitbuffer.bitSize() - n;

        let testbits = testbuffer.getBits(start, n);
        let bits = bitbuffer.getBits(start, n);

        if (testbits != bits) {
            Debug.trap("test buffer mismatch: \n error at index " # debug_show (start) 
            # " and " # debug_show n # " bits \n msg: " # msg 
            # "\n testbits: " # debug_show testbits 
            # "\n bits: " # debug_show bits 
            # "\n original: " # debug_show original
            # "\n debug last 2 bytes: " # debug_show (BitBuffer.getBytes(testbuffer, start - (start % 8 ), 2))
            # "\n debug last 2 bytes: " # debug_show (BitBuffer.getBytes(bitbuffer, start - (start % 8 ), 2)));
        };
    };
};
