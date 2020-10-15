import Runes

/**
  Conditionally map a function over a `Decoded` value, flattening the result.

  - If the value is `.Failure`, the function will not be evaluated and this
    will return `.Failure`.
  - If the value is `.Success`, the function will be applied to the unwrapped
    value.

  - parameter x: A value of type `Decoded<T>`
  - parameter f: A transformation function from type `T` to type `Decoded<U>`

  - returns: A value of type `Decoded<U>`
*/
public func >>- <T, U>(x: Decoded<T>, f: (T) -> Decoded<U>) -> Decoded<U> {
  return x.flatMap(f)
}

/**
  Conditionally map a function over a `Decoded` value, flattening the result.

  - If the value is `.Failure`, the function will not be evaluated and this
    will return `.Failure`.
  - If the value is `.Success`, the function will be applied to the unwrapped
    value.

  - parameter f: A transformation function from type `T` to type `Decoded<U>`
  - parameter x: A value of type `Decoded<T>`

  - returns: A value of type `Decoded<U>`
*/
public func -<< <T, U>(f: (T) -> Decoded<U>, x: Decoded<T>) -> Decoded<U> {
  return x.flatMap(f)
}

public extension Decoded {
  /**
    Conditionally map a function over `self`, flattening the result.

    - If `self` is `.Failure`, the function will not be evaluated and this will
      return `.Failure`.
    - If `self` is `.Success`, the function will be applied to the unwrapped
      value.

    - parameter f: A transformation function from type `T` to type `Decoded<U>`

    - returns: A value of type `Decoded<U>`
  */
  func flatMap<U>(_ f: (T) -> Decoded<U>) -> Decoded<U> {
    switch self {
    case let .success(value): return f(value)
    case let .failure(error): return .failure(error)
    }
  }
}
