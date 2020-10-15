/**
  Create a new array of unwrapped `.Success` values, filtering out `.Failure`s.

  This will iterate through the array of `Decoded<T>` elements and safely
  unwrap the values.

  If the element is `.Success(T)`, it will unwrap the value and add it into the
  array.

  If the element is `.Failure`, it will not be added to the new array.

  - parameter xs: An array of `Decoded<T>` values

  - returns: An array of unwrapped values of type `T`
*/
public func catDecoded<T>(_ xs: [Decoded<T>]) -> [T] {
  var accum: [T] = []
  accum.reserveCapacity(xs.count)

  for x in xs {
    switch x {
    case let .success(value): accum.append(value)
    case .failure: continue
    }
  }

  return accum
}

/**
  Create a new dictionary of unwrapped `.Success` values, filtering out
  `.Failure`s.

  This will iterate through the dictionary of `Decoded<T>` elements and safely
  unwrap the values.

  If the element is `.Success(T)`, it will unwrap the value and assign it to
  the existing key in the new dictionary.

  If the element is `.Failure`, it will not be added to the new dictionary.

  - parameter xs: A dictionary of `Decoded<T>` values assigned to `String` keys

  - returns: A dictionary of unwrapped values of type `T` assigned to `String` keys
*/
public func catDecoded<T>(_ xs: [String: Decoded<T>]) -> [String: T] {
  var accum = Dictionary<String, T>(minimumCapacity: xs.count)

  for (key, x) in xs {
    switch x {
    case let .success(value): accum[key] = value
    case .failure: continue
    }
  }

  return accum
}
