import Foundation

extension Project.Category {
  /**
   Returns a minimal `Project.Category` from a `GraphCategory`
   */
  static func category(from graphCategory: GraphCategory) -> Project.Category? {
    guard let id = decompose(id: graphCategory.id) else { return nil }

    return Project.Category(
      id: id,
      name: graphCategory.name,
      parentId: graphCategory.parentCategory.map(\.id).flatMap(decompose(id:)),
      parentName: graphCategory.parentCategory?.name
    )
  }
}
