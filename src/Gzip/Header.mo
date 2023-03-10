import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Int "mo:base/Int";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";

import BitBuffer "mo:bitbuffer/BitBuffer";
import NatX "mo:xtended-numbers/NatX";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type Time = Time.Time;

    public type ExtraField = {
        ids : (Nat8, Nat8);

        /// The data of the extra field.
        /// If the data is a number, it has to be stored with the least significant byte first.
        data : [Nat8];
    };

    public type CompressionLevel = {
        #Fastest;
        #Slowest;
        #Unknown;
    };

    public type Os = {
        /// FAT filesystem (MS-DOS, OS/2, NT/Win32)
        #FatFs;

        ///Amiga
        #Amiga;

        /// VMS (or OpenVMS)
        #Vms;

        /// Unix
        #Unix;

        /// VM/CMS
        #VmCms;

        /// Atari TOS
        #AtariTos;

        /// HPFS filesystem (OS/2, NT)
        #Hpfs;

        /// Macintosh
        #Macintosh;

        /// Z-System
        #ZSystem;

        /// CP/M
        #CpM;

        /// TOPS-20
        #Tops20;

        /// NTFS filesystem (NT)
        #Ntfs;

        /// QDOS
        #Qdos;

        /// Acorn RISCOS
        #AcornRiscos;

        /// unknown
        #Unknown;
    };

    public type HeaderOptions = {
        is_text : Bool;
        is_verified : Bool;
        extra_fields : [ExtraField];
        filename : ?Text;
        comment : ?Text;
        modification_time : ?Time;
        compression_level: CompressionLevel;
        os : Os;
    };

    public func compressionLevelToByte(compression_level : CompressionLevel) : Nat8 {
        switch (compression_level) {
            case (#Unknown) { 0x00 };
            case (#Slowest) { 0x02 };
            case (#Fastest) { 0x04 };
        };
    };

    public func byteToCompressionLevel(byte : Nat8) : CompressionLevel {
        switch (byte) {
            case (0x02) { #Slowest };
            case (0x04) { #Fastest };
            case (_) { #Unknown };
        };
    };

    public func osToByte(os : Os) : Nat8 = switch (os) {
        case (#FatFs) { 0x00 };
        case (#Amiga) { 0x01 };
        case (#Vms) { 0x02 };
        case (#Unix) { 0x03 };
        case (#VmCms) { 0x04 };
        case (#AtariTos) { 0x05 };
        case (#Hpfs) { 0x06 };
        case (#Macintosh) { 0x07 };
        case (#ZSystem) { 0x08 };
        case (#CpM) { 0x09 };
        case (#Tops20) { 0x0a };
        case (#Ntfs) { 0x0b };
        case (#Qdos) { 0x0c };
        case (#AcornRiscos) { 0x0d };
        case (#Unknown) { 0xff };
    };

    public func byteToOs(byte : Nat8) : Os = switch (byte) {
        case (0x00) { #FatFs };
        case (0x01) { #Amiga };
        case (0x02) { #Vms };
        case (0x03) { #Unix };
        case (0x04) { #VmCms };
        case (0x05) { #AtariTos };
        case (0x06) { #Hpfs };
        case (0x07) { #Macintosh };
        case (0x08) { #ZSystem };
        case (0x09) { #CpM };
        case (0x0a) { #Tops20 };
        case (0x0b) { #Ntfs };
        case (0x0c) { #Qdos };
        case (0x0d) { #AcornRiscos };
        case (_) { #Unknown };
    };

};
