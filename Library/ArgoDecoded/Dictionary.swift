import Runes

// pure merge for Dictionaries
func + <T, U>(lhs: [T: U], rhs: [T: U]) -> [T: U] {
  var merged = lhs
  for (key, val) in rhs {
    merged[key] = val
  }

  return merged
}

extension Dictionary {
  func map<T>(_ f: (Value) -> T) -> [Key: T] {
    var accum = Dictionary<Key, T>(minimumCapacity: self.count)

    for (key, value) in self {
      accum[key] = f(value)
    }

    return accum
  }
}

func <^> <T, U, V>(f: (T) -> U, x: [V: T]) -> [V: U] {
  return x.map(f)
}
