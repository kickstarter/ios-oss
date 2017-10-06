import Foundation

public struct ParentCategory: Swift.Decodable {
  var id: String
  var name: String
}

public struct RootCategoriesEnvelope: Swift.Decodable {
  public let rootCategories: [Category]

  public struct Category: Swift.Decodable {

    public let id: String
    public var intID: Int {
        return decompose(id: id) ?? -1
    }
    public let name: String
    public let parentCategory: ParentCategory?
    public let parentId: String?
    public let subcategories: SubcategoryConnection
    public let totalProjectCount: Int?

    public init(id: String,
                  name: String,
                  parentCategory: ParentCategory?,
                  parentId: String?,
                  subcategories: SubcategoryConnection,
                  totalProjectCount: Int?) {
      self.id = id
      self.name = name
      self.parentCategory = parentCategory
      self.parentId = parentId
      self.subcategories = subcategories
      self.totalProjectCount = totalProjectCount
    }

    public struct SubcategoryConnection: Swift.Decodable {
      public let totalCount: Int
      public let nodes: [Node]

      public struct Node: Swift.Decodable {

        public let id: String
        public let name: String
        public let parentCategory: ParentCategory
        public let totalProjectCount: Int?
        public var category: Category? {
          return Category(id: self.id,
                          name: self.name,
                          parentCategory: self.parentCategory,
                          parentId: self.parentCategory.id,
                          subcategories: RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 0,
                                                                                               nodes: []),
                          totalProjectCount: self.totalProjectCount)
        }

        public init(id: String,
                    name: String,
                    parentCategory: ParentCategory,
                    totalProjectCount: Int?) {
          self.id = id
          self.name = name
          self.parentCategory = parentCategory
          self.totalProjectCount = totalProjectCount

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
