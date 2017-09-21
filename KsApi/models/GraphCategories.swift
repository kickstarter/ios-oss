import Foundation

public struct RootCategoriesEnvelope: Swift.Decodable {
  public let rootCategories: [Category]

  public struct Category: Swift.Decodable {
    public let id: String
    public var intID: Int {
        return decompose(id: id)?.1 ?? -1
    }
    public let name: String
    public let parentId: String?
    public let subcategories: SubcategoryConnection
    public let totalProjectCount: Int?

    public struct SubcategoryConnection: Swift.Decodable {
      public let totalCount: Int
      public let nodes: [Node]

      public struct Node: Swift.Decodable {
        public let id: String
        public let name: String
        public let parentId: String
        public let totalProjectCount: Int?

        static public func buildCategory(id: String,
                                       name: String,
                                   parentId: String,
                          totalProjectCount: Int?) -> Category {
          return Category(id: id,
                        name: name,
                    parentId: parentId,
               subcategories: RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 0,
                                                                                    nodes: []),
           totalProjectCount: totalProjectCount)
        }
      }
    }

    public var isRoot: Bool {
      return self.parentId == nil
    }
  }
}

extension RootCategoriesEnvelope.Category: Equatable {
  static public func == (lhs: RootCategoriesEnvelope.Category, rhs: RootCategoriesEnvelope.Category) -> Bool {
    return lhs.id == rhs.id
  }
}

extension RootCategoriesEnvelope.Category: Hashable {
  public var hashValue: Int {
    return self.intID
  }
}

extension RootCategoriesEnvelope.Category.SubcategoryConnection.Node: Equatable {
  static public func == (lhs: RootCategoriesEnvelope.Category.SubcategoryConnection.Node,
                         rhs: RootCategoriesEnvelope.Category.SubcategoryConnection.Node) -> Bool {
    return lhs.id == rhs.id
  }
}
