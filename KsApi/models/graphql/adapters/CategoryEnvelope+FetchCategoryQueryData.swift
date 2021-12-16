import ReactiveSwift

extension CategoryEnvelope {
  /**
   Returns a minimal `CategoryEnvelope` from a `FetchCategoryQuery.Data`
   */
  static func envelopeProducer(from data: GraphAPI.FetchCategoryQuery
    .Data) -> SignalProducer<CategoryEnvelope, ErrorEnvelope> {
    guard let categoryNode = data.node?.asCategory else {
      return .empty
    }

    let category = Category(
      analyticsName: categoryNode.analyticsName,
      id: categoryNode.id,
      name: categoryNode.name,
      parentCategory: nil,
      parentId: nil,
      subcategories: self.subcategoryConnection(from: categoryNode.subcategories),
      totalProjectCount: categoryNode.totalProjectCount
    )

    let envelope = CategoryEnvelope(node: category)

    return SignalProducer(value: envelope)
  }

  private static func subcategoryConnection(from subcategories: GraphAPI.FetchCategoryQuery.Data.Node
    .AsCategory.Subcategory?) -> Category.SubcategoryConnection? {
    let subcategoryConnection: Category.SubcategoryConnection? = subcategories
      .map { subcategory -> Category.SubcategoryConnection in
        let subcategoryNodes: [GraphAPI.FetchCategoryQuery.Data.Node.AsCategory.Subcategory.Node?] =
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
    GraphAPI.FetchCategoryQuery.Data.Node.AsCategory
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
