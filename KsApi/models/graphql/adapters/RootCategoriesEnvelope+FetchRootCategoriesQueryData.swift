import ReactiveSwift

extension RootCategoriesEnvelope {
  /**
   Returns a minimal `RootCategoriesEnvelope` from a `FetchRootCategoriesQuery.Data`
   */
  static func envelopeProducer(from data: GraphAPI.FetchRootCategoriesQuery
    .Data) -> SignalProducer<RootCategoriesEnvelope, ErrorEnvelope> {
    let allCategories = data.rootCategories.map { rootCategory -> Category in
      Category(
        analyticsName: rootCategory.analyticsName,
        id: rootCategory.id,
        name: rootCategory.name,
        parentCategory: nil,
        parentId: nil,
        subcategories: self.subcategoryConnection(from: rootCategory.subcategories),
        totalProjectCount: rootCategory.totalProjectCount
      )
    }

    let envelope = RootCategoriesEnvelope(rootCategories: allCategories)

    return SignalProducer(value: envelope)
  }

  private static func subcategoryConnection(from subcategories: GraphAPI.FetchRootCategoriesQuery.Data
    .RootCategory.Subcategory?) -> Category.SubcategoryConnection? {
    let subcategoryConnection: Category.SubcategoryConnection? = subcategories
      .map { subcategory -> Category.SubcategoryConnection in
        let subcategoryNodes: [GraphAPI.FetchRootCategoriesQuery.Data.RootCategory.Subcategory.Node?] =
          subcategory
            .nodes ?? []

        return Category
          .SubcategoryConnection(
            totalCount: subcategory.totalCount,
            nodes: categories(from: subcategoryNodes)
          )
      }

    return subcategoryConnection
  }

  private static func categories(from subcategoryNodes: [
    GraphAPI.FetchRootCategoriesQuery.Data.RootCategory
      .Subcategory.Node?
  ]) -> [Category] {
    let categories = subcategoryNodes.compactMap { node -> Category? in
      guard let existingNode = node else {
        return nil
      }

      return Category.category(
        from: existingNode.fragments.categoryFragment,
        parentId: existingNode.parentId,
        subcategories: nil,
        totalProjectCount: existingNode.totalProjectCount
      )
    }

    return categories
  }
}
