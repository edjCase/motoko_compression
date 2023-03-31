# Gzip/Header

## Type `ExtraField`
``` motoko no-repl
type ExtraField = { ids : (Nat8, Nat8); data : [Nat8] }
```


## Type `CompressionLevel`
``` motoko no-repl
type CompressionLevel = {#Fastest; #Slowest; #Unknown}
```


## Type `Os`
``` motoko no-repl
type Os = {#FatFs; #Amiga; #Vms; #Unix; #VmCms; #AtariTos; #Hpfs; #Macintosh; #ZSystem; #CpM; #Tops20; #Ntfs; #Qdos; #AcornRiscos; #Unknown}
```


## Type `HeaderOptions`
``` motoko no-repl
type HeaderOptions = { is_text : Bool; is_verified : Bool; extra_fields : [ExtraField]; filename : ?Text; comment : ?Text; modification_time : ?Time; compression_level : CompressionLevel; os : Os }
```


## Function `compressionLevelToByte`
``` motoko no-repl
func compressionLevelToByte(compression_level : CompressionLevel) : Nat8
```


## Function `byteToCompressionLevel`
``` motoko no-repl
func byteToCompressionLevel(byte : Nat8) : CompressionLevel
```


## Function `osToByte`
``` motoko no-repl
func osToByte(os : Os) : Nat8
```


## Function `byteToOs`
``` motoko no-repl
func byteToOs(byte : Nat8) : Os
```

