import Apollo
import Foundation
@testable import KsApi

public enum FetchBackerProjectsQueryDataTemplate {
  case valid

  var data: GraphAPI.FetchBackerProjectsQuery.Data {
    switch self {
    case .valid:
      let json = self.fetchBackerProjectsSuccessResultMap
      return try! GraphAPI.FetchBackerProjectsQuery.Data(
        jsonObject: json as JSONObject,
        variables: ["starred": false, "backed": true, "first": nil, "after": nil, "withStoredCards": false]
      )
    }
  }

  private var fetchBackerProjectsSuccessResultMap: [String: Any?] {
    /*
     This is a very large response object, so load it from a file instead of putting it inline here.

     To create a new response, you'll need the *entire* request structure, including expanding all the fragments -
     a working request is stored in FetchBackerProjectsQueryRequestForTests.graphql_test.

     n.B. that every object in the response must also include a __typename.
     */
    guard let testBundle = Bundle(identifier: "com.kickstarter.KsApiTests"),
          let jsonStringURL = testBundle.url(forResource: "FetchBackerProjectsQuery", withExtension: "json")
    else {
      return [:]
    }

    let jsonData = try! Data(contentsOf: jsonStringURL)
    let json = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any?]

    return json["data"] as! [String: Any?]
  }
}
