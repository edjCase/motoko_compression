import It "mo:itertools/Iter";

module {
    /// An entry in the compression table
    public type LZSSEntry = {
        /// represents a single byte that wasn't matched
        #literal : Nat8;

        /// represents a reference to a previous sequence of bytes that was matched
        #pointer : (Nat, Nat);
    };

    public type CompressionLevel = {
        /// No compression.
        #none;

        /// Best speed.
        #fast;

        /// Balanced between speed and size.
        #balance;

        /// Best compression.
        #best;
    };

    /// encode LZSS entry to bytes
    public func encodeEntry(entry : LZSSEntry) : [Nat8] { [] };
};
