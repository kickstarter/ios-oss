extension DecodingError.Context {
  var keypath: String {
    return self.codingPath.map { $0.stringValue }.joined(separator: ".")
  }
}

extension DecodingError {
  var prettyDescription: String {
    switch self {
    case let .valueNotFound(_, context):
      return "JSON decoding failed: missing value for \"\(context.keypath)\""
    case let .keyNotFound(key, _):
      return "JSON decoding failed: missing key \"\(key.stringValue)\""
    case let .typeMismatch(_, context):
      return "JSON decoding failed: type mismatch for \"\(context.keypath)\""
    case .dataCorrupted:
      return "JSON decoding failed: data was corrupted"
    @unknown default:
      return "JSON decoding failed: unknown decoding error"
    }
  }
}
