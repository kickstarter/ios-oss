import Apollo
import Foundation

public enum GraphQLSelectionSetStringError: Error {
  case unableToInitData
}

public extension GraphQLSelectionSet {
  init(jsonString: String) throws {
    guard let data = jsonString.data(using: .utf8) else {
      throw GraphQLSelectionSetStringError.unableToInitData
    }

    let json = try JSONSerialization.jsonObject(with: data)
    try self.init(jsonObject: json as! JSONObject)
  }
}
