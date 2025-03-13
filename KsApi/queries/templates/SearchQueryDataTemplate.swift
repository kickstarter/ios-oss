import Foundation
import KsApi

private extension Bundle {
  static var ksr_libraryTestBundle: Bundle? {
    Bundle(identifier: "com.Library-iOSTests")
  }
}

public extension GraphAPI.SearchQuery.Data {
  static var fiveResults: GraphAPI.SearchQuery.Data {
    let url = Bundle.ksr_libraryTestBundle?.url(forResource: "SearchQuery_FiveResults", withExtension: "json")
    return try! Self(fromResource: url!)
  }

  static var differentFiveResults: GraphAPI.SearchQuery.Data {
    let url = Bundle.ksr_libraryTestBundle?.url(
      forResource: "SearchQuery_AnotherFiveResults",
      withExtension: "json"
    )
    return try! Self(fromResource: url!)
  }

  static var emptyResults: GraphAPI.SearchQuery.Data {
    let url = Bundle.ksr_libraryTestBundle?.url(
      forResource: "SearchQuery_EmptyResults",
      withExtension: "json"
    )
    return try! Self(fromResource: url!)
  }
}
