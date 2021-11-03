import Foundation

extension Project.Category {
  /**
   Returns a minimal `Project.Category` from a `CategoryFragment`
   */
  static func category(from categoryFragment: GraphAPI.CategoryFragment) -> Project.Category? {
    guard let id = decompose(id: categoryFragment.fragments.baseCategoryFragment.id) else { return nil }

    var parentCategoryId: Int?
    var parentCategoryName: String?

    if let parentCategoryFragment = categoryFragment.parentCategory?.fragments.baseCategoryFragment {
      parentCategoryId = decompose(id: parentCategoryFragment.id)
      parentCategoryName = parentCategoryFragment.name
    }

    return Project.Category(
      analyticsName: categoryFragment.analyticsName,
      id: id,
      name: categoryFragment.fragments.baseCategoryFragment.name,
      parentId: parentCategoryId,
      parentName: parentCategoryName
    )
  }
}
