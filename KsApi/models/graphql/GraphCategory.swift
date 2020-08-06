import Foundation
import Prelude

// TODO: This should be reconciled with the global-scope Category
public struct GraphCategory: Swift.Decodable {
  public var id: String
  public var name: String
  public var parentCategory: ParentCategory?

  public struct ParentCategory: Swift.Decodable {
    public var id: String
    public var name: String
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
