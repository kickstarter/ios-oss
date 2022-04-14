import Apollo
import Foundation
@testable import KsApi

public enum FetchRootCategoriesQueryTemplate {
  case valid
  case errored

  var data: GraphAPI.FetchRootCategoriesQuery.Data {
    switch self {
    case .valid:
      return GraphAPI.FetchRootCategoriesQuery.Data(unsafeResultMap: self.validResultMap)
    case .errored:
      return GraphAPI.FetchRootCategoriesQuery.Data(unsafeResultMap: self.erroredResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
    let json = """
    {
       "rootCategories":[
          {
             "analyticsName":"Art",
             "id":"Q2F0ZWdvcnktMQ==",
             "name":"Art",
             "subcategories":{
                "nodes":[
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":3,
                      "id":"Q2F0ZWdvcnktMjg3",
                      "name":"Ceramics",
                      "analyticsName":"Ceramics",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":7,
                      "id":"Q2F0ZWdvcnktMjA=",
                      "name":"Conceptual Art",
                      "analyticsName":"Conceptual Art",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":26,
                      "id":"Q2F0ZWdvcnktMjE=",
                      "name":"Digital Art",
                      "analyticsName":"Digital Art",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":103,
                      "id":"Q2F0ZWdvcnktMjI=",
                      "name":"Illustration",
                      "analyticsName":"Illustration",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":1,
                      "id":"Q2F0ZWdvcnktMjg4",
                      "name":"Installations",
                      "analyticsName":"Installations",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":19,
                      "id":"Q2F0ZWdvcnktNTQ=",
                      "name":"Mixed Media",
                      "analyticsName":"Mixed Media",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":16,
                      "id":"Q2F0ZWdvcnktMjM=",
                      "name":"Painting",
                      "analyticsName":"Painting",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":1,
                      "id":"Q2F0ZWdvcnktMjQ=",
                      "name":"Performance Art",
                      "analyticsName":"Performance Art",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":11,
                      "id":"Q2F0ZWdvcnktNTM=",
                      "name":"Public Art",
                      "analyticsName":"Public Art",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":2,
                      "id":"Q2F0ZWdvcnktMjU=",
                      "name":"Sculpture",
                      "analyticsName":"Sculpture",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":4,
                      "id":"Q2F0ZWdvcnktMzk1",
                      "name":"Social Practice",
                      "analyticsName":"Social Practice",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":11,
                      "id":"Q2F0ZWdvcnktMjg5",
                      "name":"Textiles",
                      "analyticsName":"Textiles",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMQ==",
                      "totalProjectCount":2,
                      "id":"Q2F0ZWdvcnktMjkw",
                      "name":"Video Art",
                      "analyticsName":"Video Art",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMQ==",
                         "name":"Art",
                         "analyticsName":"Art"
                      }
                   }
                ],
                "totalCount":13
             },
             "totalProjectCount":348
          },
          {
             "analyticsName":"Comics",
             "id":"Q2F0ZWdvcnktMw==",
             "name":"Comics",
             "subcategories":{
                "nodes":[
                   {
                      "parentId":"Q2F0ZWdvcnktMw==",
                      "totalProjectCount":23,
                      "id":"Q2F0ZWdvcnktMjQ5",
                      "name":"Anthologies",
                      "analyticsName":"Anthologies",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMw==",
                         "name":"Comics",
                         "analyticsName":"Comics"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMw==",
                      "totalProjectCount":149,
                      "id":"Q2F0ZWdvcnktMjUw",
                      "name":"Comic Books",
                      "analyticsName":"Comic Books",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMw==",
                         "name":"Comics",
                         "analyticsName":"Comics"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMw==",
                      "totalProjectCount":0,
                      "id":"Q2F0ZWdvcnktMjUx",
                      "name":"Events",
                      "analyticsName":"Events",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMw==",
                         "name":"Comics",
                         "analyticsName":"Comics"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMw==",
                      "totalProjectCount":86,
                      "id":"Q2F0ZWdvcnktMjUy",
                      "name":"Graphic Novels",
                      "analyticsName":"Graphic Novels",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMw==",
                         "name":"Comics",
                         "analyticsName":"Comics"
                      }
                   },
                   {
                      "parentId":"Q2F0ZWdvcnktMw==",
                      "totalProjectCount":12,
                      "id":"Q2F0ZWdvcnktMjUz",
                      "name":"Webcomics",
                      "analyticsName":"Webcomics",
                      "parentCategory":{
                         "id":"Q2F0ZWdvcnktMw==",
                         "name":"Comics",
                         "analyticsName":"Comics"
                      }
                   }
                ],
                "totalCount":5
             },
             "totalProjectCount":306
          }
       ]
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
