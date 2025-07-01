import Apollo
import ApolloAPI
import Foundation
import KsApi

public enum GraphQLSelectionSetStringError: Error {
  case unableToInitData
  case fileNotFoundError
}

func testGraphObject<T: GraphAPI.SelectionSet>(
  data: [String: Any],
  variables: GraphQLOperation.Variables? = nil
) throws -> T {
  return try T.init(data: data, variables: variables)
}

func testGraphObject<T: GraphAPI.SelectionSet>(
  jsonString: String,
  variables: GraphQLOperation.Variables? = nil
) throws -> T {
  guard let data = jsonString.data(using: .utf8) else {
    throw GraphQLSelectionSetStringError.unableToInitData
  }

  let json = try JSONSerialization.jsonObject(with: data)
  return try T.init(data: json as! JSONObject, variables: variables)
}

func testGraphObject<T: GraphAPI.SelectionSet>(
  fromResource resource: URL,
  variables: GraphQLOperation.Variables? = nil
) throws -> T {
  let jsonData = try! Data(contentsOf: resource)
  let json = try! JSONSerialization.jsonObject(with: jsonData) as! JSONObject
  let data = json["data"]
  return try T.init(data: data as! JSONObject, variables: variables)
}
