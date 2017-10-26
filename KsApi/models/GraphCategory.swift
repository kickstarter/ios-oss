import Foundation

public struct ParentCategory: Swift.Decodable {
  public let id: String
  public let name: String

  public var categoryType: RootCategoriesEnvelope.Category {
      return RootCategoriesEnvelope.Category(
        id: id,
        name: name
    )
  }
}

public struct RootCategoriesEnvelope: Swift.Decodable {
  public let rootCategories: [Category]

  public struct Category: Swift.Decodable {
    public let id: String
    public var intID: Int? {
        return decompose(id: id)
    }

    public static let gamesId: Int = 12

    public let name: String
    public let parentId: String?
    internal let parentCategory: ParentCategory?
    public var _parent: RootCategoriesEnvelope.Category? {
      return parentCategory?.categoryType
    }
    public let subcategories: SubcategoryConnection?
    public let totalProjectCount: Int?

    public init(id: String,
                name: String,
                parentCategory: ParentCategory? = nil,
                parentId: String? = nil,
                subcategories: SubcategoryConnection? = nil,
                totalProjectCount: Int? = nil) {
      self.id = id
      self.name = name
      self.parentId = parentId
      self.parentCategory = parentCategory
      self.subcategories = subcategories
      self.totalProjectCount = totalProjectCount
    }

    public struct SubcategoryConnection: Swift.Decodable {
      public let totalCount: Int
      public let nodes: [Category]
    }

    public var isRoot: Bool {
      return self.parentId == nil
    }

    /// Returns the parent category if present, or returns self if we know for a fact that self is a
    /// root categeory.
    public var root: RootCategoriesEnvelope.Category? {
      if let parent = self.parentCategory {
        return parent.categoryType
      } else if self.parentId == nil {
        return self
      }
      return nil
    }

    /// Returns the id of the root category. This is sometimes present in situations that `root` is not.
    public var rootId: Int? {
      if let parentId = self.parentId {
        return decompose(id: parentId)
      }
      return self.root?.intID
    }
  }
}

extension ParentCategory: Hashable {
  public var hashValue: Int {
    return self.categoryType.intID ?? -1
  }
}

extension ParentCategory: Equatable {
  static public func == (lhs: ParentCategory, rhs: ParentCategory) -> Bool {
    return lhs.id == rhs.id
  }
}

extension RootCategoriesEnvelope.Category: Comparable {}
public func < (lhs: RootCategoriesEnvelope.Category, rhs: RootCategoriesEnvelope.Category) -> Bool {
  if lhs.id == rhs.id {
    return false
  }

  if lhs.isRoot && lhs.id == rhs._parent?.id {
    return true
  }

  if !lhs.isRoot && lhs._parent?.id == rhs.id {
    return false
  }

  if let lhsRootName = lhs._parent?.name, let rhsRootName = rhs._parent?.name {
    return lhsRootName < rhsRootName
  }

  return lhs._parent == nil
}

extension RootCategoriesEnvelope.Category: Equatable {
  static public func == (lhs: RootCategoriesEnvelope.Category, rhs: RootCategoriesEnvelope.Category) -> Bool {
    return lhs.id == rhs.id
  }
}

extension RootCategoriesEnvelope.Category: Hashable {
  public var hashValue: Int {
    return self.intID ?? -1
  }
}

extension RootCategoriesEnvelope.Category: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return "GraphCategory(id: \(self.id), name: \(self.name))"
  }

  public var debugDescription: String {
    return self.description
  }
}
