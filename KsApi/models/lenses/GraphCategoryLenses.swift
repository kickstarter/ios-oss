import Foundation
import Prelude

extension Category {
  public enum lens {
    public static let analyticsName = Lens<Category, String?>(
      view: { $0.analyticsName },
      set: { Category(
        analyticsName: $0,
        id: $1.id,
        name: $1.name,
        parentCategory: $1._parent,
        parentId: $1.parentId,
        subcategories: $1.subcategories,
        totalProjectCount: $1.totalProjectCount
      ) }
    )

    public static let id = Lens<Category, String>(
      view: { $0.id },
      set: { Category(
        analyticsName: $1.analyticsName,
        id: $0,
        name: $1.name,
        parentCategory: $1._parent,
        parentId: $1.parentId,
        subcategories: $1.subcategories,
        totalProjectCount: $1.totalProjectCount
      ) }
    )

    public static let name = Lens<Category, String>(
      view: { $0.name },
      set: { Category(
        analyticsName: $1.analyticsName,
        id: $1.id,
        name: $0,
        parentCategory: $1._parent,
        parentId: $1.parentId,
        subcategories: $1.subcategories,
        totalProjectCount: $1.totalProjectCount
      ) }
    )

    public static let parent = Lens<Category, ParentCategory?>(
      view: { $0._parent },
      set: { Category(
        analyticsName: $1.analyticsName,
        id: $1.id,
        name: $1.name,
        parentCategory: $0,
        parentId: $1.parentId,
        subcategories: $1.subcategories,
        totalProjectCount: $1.totalProjectCount
      ) }
    )

    public static let parentId = Lens<Category, String?>(
      view: { $0.parentId },
      set: { Category(
        analyticsName: $1.analyticsName,
        id: $1.id,
        name: $1.name,
        parentCategory: $1._parent,
        parentId: $0,
        subcategories: $1.subcategories,
        totalProjectCount: $1.totalProjectCount
      ) }
    )

    public static let subcategories = Lens<
      Category,
      Category.SubcategoryConnection?
    >(
      view: { $0.subcategories },
      set: { Category(
        analyticsName: $1.analyticsName,
        id: $1.id,
        name: $1.name,
        parentCategory: $1._parent,
        parentId: $1.parentId,
        subcategories: $0,
        totalProjectCount: $1.totalProjectCount
      ) }
    )

    public static let totalProjectCount = Lens<Category, Int?>(
      view: { $0.totalProjectCount },
      set: { Category(
        analyticsName: $1.analyticsName,
        id: $1.id,
        name: $1.name,
        parentCategory: $1._parent,
        parentId: $1.parentId,
        subcategories: $1.subcategories,
        totalProjectCount: $0
      ) }
    )
  }
}
