import Apollo
import Foundation
@testable import KsApi

public enum FetchCategoryQueryTemplate {
  case valid
  case errored

  var data: GraphAPI.FetchCategoryQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchCategoryQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchCategoryQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
    let json = """
    {
        "node": {
          "__typename": "Category",
          "analyticsName": "Comics",
          "id": "Q2F0ZWdvcnktMw==",
          "name": "Comics",
          "subcategories": {
            "__typename": "CategorySubcategoriesConnection",
            "nodes": [
              {
                "__typename": "Category",
                "parentId": "Q2F0ZWdvcnktMw==",
                "totalProjectCount": 23,
                "id": "Q2F0ZWdvcnktMjQ5",
                "name": "Anthologies",
                "analyticsName": "Anthologies",
                "parentCategory": {
                  "__typename": "Category",
                  "id": "Q2F0ZWdvcnktMw==",
                  "name": "Comics",
                  "analyticsName": "Comics"
                }
              },
              {
                "__typename": "Category",
                "parentId": "Q2F0ZWdvcnktMw==",
                "totalProjectCount": 149,
                "id": "Q2F0ZWdvcnktMjUw",
                "name": "Comic Books",
                "analyticsName": "Comic Books",
                "parentCategory": {
                  "__typename": "Category",
                  "id": "Q2F0ZWdvcnktMw==",
                  "name": "Comics",
                  "analyticsName": "Comics"
                }
              },
              {
                "__typename": "Category",
                "parentId": "Q2F0ZWdvcnktMw==",
                "totalProjectCount": 0,
                "id": "Q2F0ZWdvcnktMjUx",
                "name": "Events",
                "analyticsName": "Events",
                "parentCategory": {
                  "__typename": "Category",
                  "id": "Q2F0ZWdvcnktMw==",
                  "name": "Comics",
                  "analyticsName": "Comics"
                }
              },
              {
                "__typename": "Category",
                "parentId": "Q2F0ZWdvcnktMw==",
                "totalProjectCount": 86,
                "id": "Q2F0ZWdvcnktMjUy",
                "name": "Graphic Novels",
                "analyticsName": "Graphic Novels",
                "parentCategory": {
                  "__typename": "Category",
                  "id": "Q2F0ZWdvcnktMw==",
                  "name": "Comics",
                  "analyticsName": "Comics"
                }
              },
              {
                "__typename": "Category",
                "parentId": "Q2F0ZWdvcnktMw==",
                "totalProjectCount": 12,
                "id": "Q2F0ZWdvcnktMjUz",
                "name": "Webcomics",
                "analyticsName": "Webcomics",
                "parentCategory": {
                  "__typename": "Category",
                  "id": "Q2F0ZWdvcnktMw==",
                  "name": "Comics",
                  "analyticsName": "Comics"
                }
              }
            ],
            "totalCount": 5
          },
          "totalProjectCount": 306
        }
      }
    """

    let data = Data(json.utf8)
    var resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    return resultMap
  }

  private var erroredResultMap: [String: Any?] {
    return [:]
  }
}
