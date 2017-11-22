import Prelude
import Foundation

extension RootCategoriesEnvelope.Category {

  public enum lens {
    public static let id = Lens<RootCategoriesEnvelope.Category, String>(
      view: { $0.id },
      set: { RootCategoriesEnvelope.Category(id: $0,
                                             name: $1.name,
                                             parentCategory: $1._parent,
                                             parentId: $1.parentId,
                                             subcategories: $1.subcategories,
                                             totalProjectCount: $1.totalProjectCount) }
    )

    public static let name = Lens<RootCategoriesEnvelope.Category, String>(
      view: { $0.name },
      set: { RootCategoriesEnvelope.Category(id: $1.id,
                                             name: $0,
                                             parentCategory: $1._parent,
                                             parentId: $1.parentId,
                                             subcategories: $1.subcategories,
                                             totalProjectCount: $1.totalProjectCount) }
    )

    public static let parent = Lens<RootCategoriesEnvelope.Category, ParentCategory?>(
      view: { $0._parent },
      set: { RootCategoriesEnvelope.Category(id: $1.id,
                                             name: $1.name,
                                             parentCategory: $0,
                                             parentId: $1.parentId,
                                             subcategories: $1.subcategories,
                                             totalProjectCount: $1.totalProjectCount) }
    )

    public static let parentId = Lens<RootCategoriesEnvelope.Category, String?>(
      view: { $0.parentId },
      set: { RootCategoriesEnvelope.Category(id: $1.id,
                                             name: $1.name,
                                             parentCategory: $1._parent,
                                             parentId: $0,
                                             subcategories: $1.subcategories,
                                             totalProjectCount: $1.totalProjectCount) }
    )

    public static let subcategories = Lens<RootCategoriesEnvelope.Category,
                                           RootCategoriesEnvelope.Category.SubcategoryConnection?>(
      view: { $0.subcategories },
      set: { RootCategoriesEnvelope.Category(id: $1.id,
                                             name: $1.name,
                                             parentCategory: $1._parent,
                                             parentId: $1.parentId,
                                             subcategories: $0,
                                             totalProjectCount: $1.totalProjectCount) }
    )

    public static let totalProjectCount = Lens<RootCategoriesEnvelope.Category, Int?>(
      view: { $0.totalProjectCount },
      set: { RootCategoriesEnvelope.Category(id: $1.id,
                                             name: $1.name,
                                             parentCategory: $1._parent,
                                             parentId: $1.parentId,
                                             subcategories: $1.subcategories,
                                             totalProjectCount: $0) }
    )
  }
}
