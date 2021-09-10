import Foundation

extension Project.Category {
  /**
   Returns a minimal `Project.Category` from a `CategoryFragment`
   */
  static func category(from categoryFragment: GraphAPI.CategoryFragment) -> Project.Category? {
    guard let id = decompose(id: categoryFragment.id) else { return nil }

    return Project.Category(
      analyticsName: categoryFragment.analyticsName,
      id: id,
      name: categoryFragment.name,
      parentId: categoryFragment.parentCategory.map(\.id).flatMap(decompose(id:)),
      parentName: categoryFragment.parentCategory?.name
    )
  }
}
