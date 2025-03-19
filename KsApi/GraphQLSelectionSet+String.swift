import Apollo
import Foundation

public enum GraphQLSelectionSetStringError: Error {
  case unableToInitData
  case fileNotFoundError
}

public extension GraphQLSelectionSet {
  init(jsonString: String, variables: GraphQLMap? = nil) throws {
    guard let data = jsonString.data(using: .utf8) else {
      throw GraphQLSelectionSetStringError.unableToInitData
    }

    let json = try JSONSerialization.jsonObject(with: data)
    try self.init(jsonObject: json as! JSONObject, variables: variables)
  }

  init(fromResource resource: URL, variables: GraphQLMap? = nil) throws {
    let jsonData = try! Data(contentsOf: resource)
    let json = try! JSONSerialization.jsonObject(with: jsonData) as! JSONObject
    let data = json["data"]
    try self.init(jsonObject: data as! JSONObject, variables: variables)
  }
}
