import Apollo
import Foundation

public enum GraphQLSelectionSetStringError: Error {
  case unableToInitData
  case fileNotFoundError
}

func testGraphObject<T: GraphQLSelectionSet>(data: [String: Any?]) -> T {
  return T.init(unsafeResultMap: data)
}

func testGraphObject<T: GraphQLSelectionSet>(
  jsonObject: [String: Any],
  variables: GraphQLMap? = nil
) throws -> T {
  return try T.init(jsonObject: jsonObject, variables: variables)
}

func testGraphObject<T: GraphQLSelectionSet>(jsonString: String, variables: GraphQLMap? = nil) throws -> T {
  guard let data = jsonString.data(using: .utf8) else {
    throw GraphQLSelectionSetStringError.unableToInitData
  }

  let json = try JSONSerialization.jsonObject(with: data)
  return try T.init(jsonObject: json as! JSONObject, variables: variables)
}

func testGraphObject<T: GraphQLSelectionSet>(
  fromResource resource: URL,
  variables: GraphQLMap? = nil
) throws -> T {
  let jsonData = try! Data(contentsOf: resource)
  let json = try! JSONSerialization.jsonObject(with: jsonData) as! JSONObject
  let data = json["data"]
  return try T.init(jsonObject: data as! JSONObject, variables: variables)
}
