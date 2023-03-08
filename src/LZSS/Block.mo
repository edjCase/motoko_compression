import Debug "mo:base/Debug";

module {
    public type BlockType = {
        #Raw;
        #Fixed;
        #Dynamic;
    };

    public func blockTypeToByte(blockType : BlockType) : Nat8 {
        switch blockType {
            case (#Raw) 0;
            case (#Fixed) 1;
            case (#Dynamic) 2;
        };
    };

    public func byteToBlockType(byte : Nat8) : BlockType {
        switch byte {
            case 0 (#Raw);
            case 1 (#Fixed);
            case 2 (#Dynamic);
            case _ Debug.trap("Invalid block type");
        };
    };
};
