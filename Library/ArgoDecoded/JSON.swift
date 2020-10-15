import Foundation

/// A type safe representation of JSON.
public enum JSON {
  case object([String: JSON])
  case array([JSON])
  case string(String)
  case number(NSNumber)
  case bool(Bool)
  case null
}

public extension JSON {
  /**
    Transform an `Any` instance into `JSON`.

    This is used to move from a loosely typed object (like those returned from
    `NSJSONSerialization`) to the strongly typed `JSON` tree structure.

    - parameter json: A loosely typed object
  */
  init(_ json: Any) {
    switch json {

    case let v as [Any]:
      self = .array(v.map(JSON.init))

    case let v as [String: Any]:
      self = .object(v.map(JSON.init))

    case let v as String:
      self = .string(v)

    case let v as NSNumber:
      if v.isBool {
        self = .bool(v.boolValue)
      } else {
        self = .number(v)
      }

    default:
      self = .null
    }
  }
}

extension JSON: Decodable {
  /**
    Decode `JSON` into `Decoded<JSON>`.

    This simply wraps the provided `JSON` in `.Success`. This is useful because
    it means we can use `JSON` values with the `<|` family of operators to pull
    out sub-keys.

    - parameter json: The `JSON` value to decode

    - returns: The provided `JSON` wrapped in `.Success`
  */
  public static func decode(_ json: JSON) -> Decoded<JSON> {
    return pure(json)
  }
}

extension JSON: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .string(v): return "String(\(v))"
    case let .number(v): return "Number(\(v))"
    case let .bool(v): return "Bool(\(v))"
    case let .array(a): return "Array(\(a.description))"
    case let .object(o): return "Object(\(o.description))"
    case .null: return "Null"
    }
  }
}

extension JSON: Equatable { }

public func == (lhs: JSON, rhs: JSON) -> Bool {
  switch (lhs, rhs) {
  case let (.string(l), .string(r)): return l == r
  case let (.number(l), .number(r)): return l == r
  case let (.bool(l), .bool(r)): return l == r
  case let (.array(l), .array(r)): return l == r
  case let (.object(l), .object(r)): return l == r
  case (.null, .null): return true
  default: return false
  }
}

/// MARK: Deprecations

extension JSON {
  @available(*, deprecated: 3.0, renamed: "init")
  static func parse(_ json: Any) -> JSON {
    return JSON(json)
  }
}
