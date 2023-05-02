# Gzip/Decoder

## Type `DecodedResponse`
``` motoko no-repl
type DecodedResponse = { filename : Text; comment : Text; mtime : Time.Time; fields : [Header.ExtraField]; buffer : Buffer<Nat8> }
```


## Class `Decoder`

``` motoko no-repl
class Decoder()
```

Gzip Decoder class
Requires that the full header is available in the `init_bytes` array before initialization

### Function `decode`
``` motoko no-repl
func decode(bytes : [Nat8])
```



### Function `clear`
``` motoko no-repl
func clear()
```



### Function `finish`
``` motoko no-repl
func finish() : DecodedResponse
```

