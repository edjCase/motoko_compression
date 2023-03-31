# BufferDeque
A Buffer that with an amortized time of O(1) additions at both ends

## Class `BufferDeque<A>`

``` motoko no-repl
class BufferDeque<A>(init_capacity : Nat)
```


### Function `size`
``` motoko no-repl
func size() : Nat
```

Returns the number of items in the buffer


### Function `capacity`
``` motoko no-repl
func capacity() : Nat
```

Returns the capacity of the deque.


### Function `get`
``` motoko no-repl
func get(i : Nat) : A
```

Retrieves the element at the given index. 
Traps if the index is out of bounds.


### Function `getOpt`
``` motoko no-repl
func getOpt(i : Nat) : ?A
```

Retrieves an element at the given index, if it exists.
If not it returns `null`.


### Function `put`
``` motoko no-repl
func put(i : Nat, elem : A)
```

Overwrites the element at the given index.


### Function `reserve`
``` motoko no-repl
func reserve(capacity : Nat)
```

Changes the capacity to `capacity`. Traps if `capacity` < `size`.

```motoko include=initialize

buffer.reserve(4);
buffer.add(10);
buffer.add(11);
buffer.capacity(); // => 4
```

Runtime: O(capacity)

Space: O(capacity)

> Adapted from the base implementation of the `Buffer` class


### Function `pushFront`
``` motoko no-repl
func pushFront(elem : A)
```

Adds an element to the start of the buffer.


### Function `pushBack`
``` motoko no-repl
func pushBack(elem : A)
```

Adds an element to the end of the buffer


### Function `popFront`
``` motoko no-repl
func popFront() : ?A
```

Removes an element from the start of the buffer and returns it if it exists.
If the buffer is empty, it returns `null`.


### Function `popBack`
``` motoko no-repl
func popBack() : ?A
```



### Function `clear`
``` motoko no-repl
func clear()
```



### Function `range`
``` motoko no-repl
func range(start : Nat, end : Nat) : Iter.Iter<A>
```

Returns an iterator over the elements of the buffer.

Note: The values in the iterator will change if the buffer is modified before the iterator is consumed.


### Function `vals`
``` motoko no-repl
func vals() : Iter.Iter<A>
```


## Function `new`
``` motoko no-repl
func new<A>() : BufferDeque<A>
```


## Function `init`
``` motoko no-repl
func init<A>(capacity : Nat, val : A) : BufferDeque<A>
```


## Function `tabulate`
``` motoko no-repl
func tabulate<A>(capacity : Nat, f : Nat -> A) : BufferDeque<A>
```


## Function `peekFront`
``` motoko no-repl
func peekFront<A>(buffer : BufferDeque<A>) : ?A
```


## Function `peekBack`
``` motoko no-repl
func peekBack<A>(buffer : BufferDeque<A>) : ?A
```

