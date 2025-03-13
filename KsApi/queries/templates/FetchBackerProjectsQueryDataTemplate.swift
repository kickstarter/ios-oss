import Apollo
import Foundation
@testable import KsApi

private extension Bundle {
  static var ksr_apiTestBundle: Bundle? {
    Bundle(identifier: "com.kickstarter.KsApiTests")
  }
}

public enum FetchBackerProjectsQueryDataTemplate {
  case valid

  /*
   These are very large response objects, so load them from a file instead of putting them inline here.

   To create a new response, you'll need the *entire* request structure, including expanding all the fragments -
   a working request is stored in FetchMySavedProjectsQueryRequestForTests.graphql_test and in
   FetchMySavedProjectsQueryRequestForTests.graphql_test.

   n.B. that every object in the response must also include a __typename.
   */

  var savedProjectsData: GraphAPI.FetchMySavedProjectsQuery.Data {
    switch self {
    case .valid:
      let url = Bundle.ksr_apiTestBundle?.url(forResource: "FetchMySavedProjectsQuery", withExtension: "json")
      return try! GraphAPI.FetchMySavedProjectsQuery.Data(
        fromResource: url!,
        variables: ["withStoredCards": false]
      )
    }
  }

  var backedProjectsData: GraphAPI.FetchMyBackedProjectsQuery.Data {
    switch self {
    case .valid:
      let url = Bundle.ksr_apiTestBundle?.url(
        forResource: "FetchMyBackedProjectsQuery",
        withExtension: "json"
      )
      return try! GraphAPI.FetchMyBackedProjectsQuery.Data(
        fromResource: url!,
        variables: ["withStoredCards": false]
      )
    }
  }
}
