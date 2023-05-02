# Huffman/Common

## Value `MAX_BITWIDTH`
``` motoko no-repl
let MAX_BITWIDTH : Nat
```


## Type `Code`
``` motoko no-repl
type Code = { bitwidth : Nat; bits : Nat16 }
```


## Function `reverseCodeBits`
``` motoko no-repl
func reverseCodeBits(code : Code) : Code
```


## Type `BuilderInterface`
``` motoko no-repl
type BuilderInterface<A> = { setMapping : (Nat, Code) -> Result<(), Text>; build : () -> A }
```


## Function `restore_huffman_codes`
``` motoko no-repl
func restore_huffman_codes<A>(builder : BuilderInterface<A>, bitwidth_arr : [Nat]) : Result<A, Text>
```

