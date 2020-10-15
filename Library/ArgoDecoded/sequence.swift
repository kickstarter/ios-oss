/**
  Convert an `Array` of `Decoded<T>` values to a `Decoded` `Array` of unwrapped
  `T` values.

  This performs an all-or-nothing transformation on the array. If every element
  is `.Success`, then this function will return `.Success` along with the array
  of unwrapped `T` values.

  However, if _any_ of the elements are `.Failure`, this function will also
  return `.Failure`, and no array will be returned.

  - parameter xs: An `Array` of `Decoded<T>` values
  - returns: A `Decoded` `Array` of unwrapped `T` values
*/
public func sequence<T>(_ xs: [Decoded<T>]) -> Decoded<[T]> {
  var accum: [T] = []
  accum.reserveCapacity(xs.count)

  for x in xs {
    switch x {
    case let .success(value): accum.append(value)
    case let .failure(error): return .failure(error)
    }
  }

  return pure(accum)
}

/**
  Convert a `Dictionary` with `Decoded<T>` values to a `Decoded` `Dictionary`
  with unwrapped `T` values.

  This performs an all-or-nothing transformation on the dictionary. If every
  key is associated with a `.Success` value, then this function will return
  `.Success` along with the dictionary of unwrapped `T` values associated with
  their original keys.

  However, if _any_ of the keys are associated with a `.Failure` value, this
  function will also return `.Failure`, and no dictionary will be returned.

  - parameter xs: A `Dictionary` of arbitrary keys and `Decoded<T>` values
  - returns: A `Decoded` `Dictionary` of unwrapped `T` values assigned to their
             original keys
*/
public func sequence<Key, Value>(_ xs: [Key: Decoded<Value>]) -> Decoded<[Key: Value]> {
  var accum = Dictionary<Key, Value>(minimumCapacity: xs.count)

  for (key, x) in xs {
    switch x {
    case let .success(value): accum[key] = value
    case let .failure(error): return .failure(error)
    }
  }

  return pure(accum)
}
