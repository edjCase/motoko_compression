# Gzip/Decoder

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



### Function `finish`
``` motoko no-repl
func finish() : Blob
```

