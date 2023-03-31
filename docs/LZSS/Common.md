# LZSS/Common

## Type `LZSSEntry`
``` motoko no-repl
type LZSSEntry = {#literal : Nat8; #pointer : (Nat, Nat)}
```

An entry in the compression table

## Type `CompressionLevel`
``` motoko no-repl
type CompressionLevel = {#none; #fast; #balance; #best}
```


## Value `MATCH_WINDOW_SIZE`
``` motoko no-repl
let MATCH_WINDOW_SIZE
```


## Value `MATCH_MAX_SIZE`
``` motoko no-repl
let MATCH_MAX_SIZE
```

