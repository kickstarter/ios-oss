import Foundation

extension Category {
  /**
   Creates a `Category` from a `CategoryFragment`.

    - parameter categoryFragment: The `CategoryFragment` data structure.

    - returns: A Category.
   */

  static func category(
    from categoryFragment: GraphAPI.CategoryFragment,
    parentId: String?,
    subcategories: Category.SubcategoryConnection?,
    totalProjectCount: Int?
  ) -> Category? {
    var newParentCategory: ParentCategory?

    if let existingParentCategory = categoryFragment.parentCategory {
      newParentCategory = Category.parentCategory(from: existingParentCategory)
    }

    return Category(
      analyticsName: categoryFragment.analyticsName,
      id: categoryFragment.id,
      name: categoryFragment.name,
      parentCategory: newParentCategory,
      parentId: parentId,
      subcategories: subcategories,
      totalProjectCount: totalProjectCount
    )
  }

  // MARK: Helpers

  private static func parentCategory(from parentCategory: GraphAPI.CategoryFragment
    .ParentCategory) -> ParentCategory {
    ParentCategory(
      analyticsName: parentCategory.analyticsName,
      id: parentCategory.id,
      name: parentCategory.name
    )
  }
}
