/**
  Return the unwrapped value of the `Decoded` value on the left if it is
  `.Success`, otherwise return the default on the right.

  - If the left hand side is `.Success`, this will return the unwrapped value
    from the left hand side argument.
  - If the left hand side is `.Failure`, this will return the default value on
    the right hand side.

  - parameter lhs: A value of type `Decoded<T>`
  - parameter rhs: An autoclosure returning a value of type `T`

  - returns: A value of type `T`
*/
public func ?? <T>(lhs: Decoded<T>, rhs: @autoclosure () -> T) -> T {
  switch lhs {
  case let .success(x): return x
  case .failure: return rhs()
  }
}
