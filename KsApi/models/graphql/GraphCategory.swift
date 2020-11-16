import Foundation
import Prelude

// TODO: This should be reconciled with the global-scope Category
struct GraphCategory: Decodable {
  var id: String
  var name: String
  var parentCategory: ParentCategory?

  struct ParentCategory: Decodable {
    var id: String
    var name: String
  }
}

/// All properties required to instantiate a `Project.Category` via a `GraphCategory`
extension GraphCategory {
  static var baseQueryProperties: NonEmptySet<Query.Project.Category> {
    return Query.Project.Category.id +| [
      .name,
      .parentCategory(.id +| [.name])
    ]
  }
}
