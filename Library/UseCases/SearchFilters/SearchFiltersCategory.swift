import KsApi

public enum SearchFiltersCategory: Equatable {
  case none
  case rootCategory(KsApi.Category)
  case subcategory(rootCategory: KsApi.Category, subcategory: KsApi.Category)

  public var name: String? {
    return self.category?.name
  }

  public var category: KsApi.Category? {
    switch self {
    case .none:
      return nil
    case let .rootCategory(rootCategory):
      return rootCategory
    case let .subcategory(_, subcategory):
      return subcategory
    }
  }
}

public func == (lhs: SearchFiltersCategory, rhs: SearchFiltersCategory) -> Bool {
  switch (lhs, rhs) {
  case (.none, .none):
    return true

  case let (.rootCategory(leftCategory), .rootCategory(rightCategory)):
    return leftCategory.id == rightCategory.id

  case let (
    .subcategory(leftRootCategory, leftSubcategory),
    .subcategory(rightRootCategory, rightSubcategory)
  ):
    return leftRootCategory.id == rightRootCategory.id &&
      leftSubcategory.id == rightSubcategory.id

  default:
    return false
  }
}
