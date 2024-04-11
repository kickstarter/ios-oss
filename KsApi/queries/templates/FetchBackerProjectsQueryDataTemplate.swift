import Apollo
import Foundation
@testable import KsApi

public enum FetchBackerProjectsQueryDataTemplate {
  case valid

  var savedProjectsData: GraphAPI.FetchMySavedProjectsQuery.Data {
    switch self {
    case .valid:
      let json = self.resultsMap(fromFile: "FetchMySavedProjectsQuery")
      return try! GraphAPI.FetchMySavedProjectsQuery.Data(
        jsonObject: json as JSONObject,
        variables: ["withStoredCards": false]
      )
    }
  }

  var backedProjectsData: GraphAPI.FetchMyBackedProjectsQuery.Data {
    switch self {
    case .valid:
      let json = self.resultsMap(fromFile: "FetchMyBackedProjectsQuery")
      return try! GraphAPI.FetchMyBackedProjectsQuery.Data(
        jsonObject: json as JSONObject,
        variables: ["withStoredCards": false]
      )
    }
  }

  private func resultsMap(fromFile resource: String) -> [String: Any?] {
    /*
     These are very large response object, so load it from a file instead of putting it inline here.

     To create a new response, you'll need the *entire* request structure, including expanding all the fragments -
     a working request is stored in FetchMySavedProjectsQueryRequestForTests.graphql_test and in
     FetchMySavedProjectsQueryRequestForTests.graphql_test.

     n.B. that every object in the response must also include a __typename.
     */
    guard let testBundle = Bundle(identifier: "com.kickstarter.KsApiTests"),
          let jsonStringURL = testBundle.url(forResource: resource, withExtension: "json")
    else {
      return [:]
    }

    let jsonData = try! Data(contentsOf: jsonStringURL)
    let json = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any?]

    return json["data"] as! [String: Any?]
  }
}
