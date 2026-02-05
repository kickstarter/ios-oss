import Foundation
import GraphAPI

extension Project.Category {
  /**
   Returns a minimal `Project.Category` from a `CategoryFragment`
   */
  static func category(from categoryFragment: GraphAPI.CategoryFragment) -> Project.Category? {
    guard let id = decompose(id: categoryFragment.id) else { return nil }

    var parentCategoryId: Int? = nil
    var parentCategoryName: String? = nil
    var parentCategoryAnalyticsName: String? = nil

    if let parentCategoryFragment = categoryFragment.parentCategory {
      parentCategoryId = decompose(id: parentCategoryFragment.id)
      parentCategoryName = parentCategoryFragment.name
      parentCategoryAnalyticsName = parentCategoryFragment.analyticsName
    }

    return Project.Category(
      analyticsName: categoryFragment.analyticsName,
      id: id,
      name: categoryFragment.name,
      parentAnalyticsName: parentCategoryAnalyticsName,
      parentId: parentCategoryId,
      parentName: parentCategoryName
    )
  }
}
