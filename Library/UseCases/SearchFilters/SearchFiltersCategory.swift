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
  if case .none = lhs, case .none = rhs {
    return true
  }

  if case let .rootCategory(leftCategory) = lhs,
     case let .rootCategory(rightCategory) = rhs {
    return leftCategory.id == rightCategory.id
  }

  if case let .subcategory(leftRootCategory, leftSubcategory) = lhs,
     case let .subcategory(rightRootCategory, rightSubcategory) = rhs {
    return leftRootCategory.id == rightRootCategory.id &&
      leftSubcategory.id == rightSubcategory.id
  }

  return false
}
