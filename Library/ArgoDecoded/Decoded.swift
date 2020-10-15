/// The result of a failable decoding operation.
public enum Decoded<T> {
  case success(T)
  case failure(DecodeError)
}

public extension Decoded {
  /**
    Get the unwrapped value as an `Optional`.

    - returns: The unwrapped value if it exists, otherwise `.None`
  */
  var value: T? {
    switch self {
    case let .success(value): return value
    case .failure: return .none
    }
  }

  /**
    Get the error value as an `Optional`.

    - returns: The unwrapped error if it exists, otherwise `.None`
  */
  var error: DecodeError? {
    switch self {
    case .success: return .none
    case let .failure(error): return error
    }
  }
}

public extension Decoded {
  /**
    Convert a `Decoded` type into a `Decoded` `Optional` type.

    This is useful for when a decode operation should be allowed to fail, such
    as when decoding an optional property.

    - parameter x: A `Decoded` type

    - returns: The `Decoded` type with any failure converted to `.success(.none)`
  */
  static func optional<T>(_ x: Decoded<T>) -> Decoded<T?> {
    return .success(x.value)
  }

  /**
    Convert an `Optional` into a `Decoded` value.

    If the provided optional is `.Some`, this method extracts the value and
    wraps it in `.Success`. Otherwise, it returns a `.TypeMismatch` error.

    - returns: The provided `Optional` value transformed into a `Decoded` value
  */
  static func fromOptional<T>(_ x: T?) -> Decoded<T> {
    switch x {
    case let .some(value): return .success(value)
    case .none: return .typeMismatch(expected: ".Some(\(T.self))", actual: ".None")
    }
  }
}

public extension Decoded {
  /**
    Convenience function for creating `.TypeMismatch` errors.

    - parameter expected: A string describing the expected type
    - parameter actual: A string describing the actual type

    - returns: A `Decoded.Failure` with a `.TypeMismatch` error constructed
               from the provided `expected` and `actual` values
  */
  static func typeMismatch<T, U>(expected: String, actual: U) -> Decoded<T> {
    return .failure(.typeMismatch(expected: expected, actual: String(describing: actual)))
  }

  /**
    Convenience function for creating `.MissingKey` errors.

    - parameter name: The name of the missing key

    - returns: A `Decoded.Failure` with a `.MissingKey` error constructed from
               the provided `name` value
  */
  static func missingKey<T>(_ name: String) -> Decoded<T> {
    return .failure(.missingKey(name))
  }

  /**
    Convenience function for creating `.Custom` errors

    - parameter message: The custom error message

    - returns: A `Decoded.Failure` with a `.Custom` error constructed from the
               provided `message` value
  */
  static func customError<T>(_ message: String) -> Decoded<T> {
    return .failure(.custom(message))
  }

  /**
   Convenience function for creating `.Multiple` errors

   - parameter errors: The errors

   - returns: A `Decoded.Failure` with a `.Multiple` error constructed from the
   provided `errors` value
   */
  static func multipleErrors<T>(errors: [DecodeError]) -> Decoded<T> {
    return .failure(.multiple(errors))
  }
}

extension Decoded: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .success(value): return "Success(\(value))"
    case let .failure(error): return "Failure(\(error))"
    }
  }
}

public extension Decoded {
  /**
    Extract the `.Success` value or throw an error.

    This can be used to move from `Decoded` types into the world of `throws`.
    If the value exists, this will return it. Otherwise, it will throw the error
    information.

    - throws: `DecodeError` if `self` is `.Failure`

    - returns: The unwrapped value
  */
  func dematerialize() throws -> T {
    switch self {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }
}

/**
  Construct a `Decoded` type from a throwing function.

  This can be used to move from the world of `throws` into a `Decoded` type. If
  the function succeeds, it will wrap the returned value in a minimal context of
  `.Success`. Otherwise, it will return a custom error with the thrown error from
  the function.

  - parameter f: A function from `Void` to `T` that can `throw` an error

  - returns: A `Decoded` type representing the success or failure of the function
*/
public func materialize<T>(_ f: () throws -> T) -> Decoded<T> {
  do {
    return .success(try f())
  } catch {
    return .customError("\(error)")
  }
}
