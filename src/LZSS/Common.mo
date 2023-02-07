import It "mo:itertools/Iter";

module {
    /// An entry in the compression table
    public type LZSSEntry = {
        /// represents a single byte that wasn't matched
        #literal : Nat8;

        /// represents a reference to a previous sequence of bytes that was matched
        #ref : (Nat, Nat);
    };

    /// encode LZSS entry to bytes
    public func encodeEntry(entry : LZSSEntry) : [Nat8] {
        []
    };
}