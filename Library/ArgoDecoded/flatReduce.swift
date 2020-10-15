import Runes

/**
  Reduce a sequence with a combinator that returns a `Decoded` type, flattening
  the result.

  This function is a helper function to make it easier to deal with combinators
  that return `Decoded` types without ending up with multiple levels of nested
  `Decoded` values.

  For example, it can be used to traverse a JSON structure with an array of
  keys. See the implementations of `<|` and `<||` that take an array of keys for
  a real-world example of this use case.

  - parameter sequence: Any `SequenceType` of values
  - parameter initial: The initial value for the accumulator
  - parameter combine: The combinator, which returns a `Decoded` type

  - returns: The result of iterating the combinator over every element of the
             sequence and flattening the result
*/
public func flatReduce<S: Sequence, U>(_ sequence: S, initial: U, combine: (U, S.Iterator.Element) -> Decoded<U>) -> Decoded<U> {
  return sequence.reduce(pure(initial)) { accum, x in
    accum >>- { combine($0, x) }
  }
}
