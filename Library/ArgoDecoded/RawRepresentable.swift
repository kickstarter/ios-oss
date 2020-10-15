/**
  Default implementation of `Decodable` for `RawRepresentable` types using
  `String` as the raw value.
*/
public extension Decodable where Self.DecodedType == Self, Self: RawRepresentable, Self.RawValue == String {
  static func decode(_ json: JSON) -> Decoded<Self> {
    switch json {
    case let .string(s):
      return self.init(rawValue: s)
        .map(pure) ?? .typeMismatch(expected: "rawValue for \(self)", actual: json)
    default:
      return .typeMismatch(expected: "String", actual: json)
    }
  }
}

/**
  Default implementation of `Decodable` for `RawRepresentable` types using
  `Int` as the raw value.
*/
public extension Decodable where Self.DecodedType == Self, Self: RawRepresentable, Self.RawValue == Int {
  static func decode(_ json: JSON) -> Decoded<Self> {
    switch json {
    case let .number(n):
      return self.init(rawValue: n.intValue)
        .map(pure) ?? .typeMismatch(expected: "rawValue for \(self)", actual: json)
    default:
      return .typeMismatch(expected: "Int", actual: json)
    }
  }
}
