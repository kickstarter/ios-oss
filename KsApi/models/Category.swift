import Foundation
public struct ParentCategory: Swift.Codable {
  public let analyticsName: String?
  public let id: String
  public let name: String

  public var categoryType: Category {
    return Category(analyticsName: self.analyticsName, id: self.id, name: self.name)
  }
}

private let unrecognizedCategoryId: Int = -1

public struct Category: Swift.Codable {
  public static let gamesId: Int = 12
  public var analyticsName: String?
  public var id: String
  public var name: String
  internal let _parent: ParentCategory?
  public var parentId: String?
  public var subcategories: SubcategoryConnection?
  public var totalProjectCount: Int?

  public init(
    analyticsName: String?,
    id: String,
    name: String,
    parentCategory: ParentCategory? = nil,
    parentId: String? = nil,
    subcategories: SubcategoryConnection? = nil,
    totalProjectCount: Int? = nil
  ) {
    self.analyticsName = analyticsName
    self.id = id
    self.name = name
    self.parentId = parentId
    self._parent = parentCategory
    self.subcategories = subcategories
    self.totalProjectCount = totalProjectCount
  }

  public var intID: Int? {
    return decompose(id: self.id)
  }

  /*
   This is a work around that fixes the incompatibility between the types of category id returned by
   the server (Int) and the type we need to send when requesting category by id
   through GraphQL (base64 encoded String). This will be removed once we start consuming GraphQL to fetch
   Discovery projects.
   */
  public static func decode(id: String) -> String {
    return "Category-\(id)"
  }

  public var parent: Category? {
    return self._parent?.categoryType
  }

  public struct SubcategoryConnection: Swift.Codable {
    public let totalCount: Int
    public let nodes: [Category]
  }

  public var isRoot: Bool {
    return self.parentId == nil
  }

  /// Returns the parent category if present, or returns self if we know for a fact that self is a
  /// root category.
  public var root: Category? {
    if let parent = self._parent {
      return parent.categoryType
    } else if self.parentId == nil {
      return self
    }
    return nil
  }

  /// Returns the id of the root category.
  public var rootId: Int? {
    if let parentId = self.parentId {
      return decompose(id: parentId)
    }
    return self.root?.intID
  }
}

extension Category {
  private enum CodingKeys: String, CodingKey {
    case analyticsName, id, name, parentId, _parent = "parentCategory", subcategories, totalProjectCount
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.analyticsName = try values.decodeIfPresent(String.self, forKey: .analyticsName)
    self.id = try values.decode(String.self, forKey: .id)
    self.name = try values.decode(String.self, forKey: .name)
    self.parentId = try? values.decode(String.self, forKey: .parentId)
    self._parent = try? values.decode(ParentCategory.self, forKey: ._parent)
    self.subcategories = try? values.decode(SubcategoryConnection.self, forKey: .subcategories)
    self.totalProjectCount = try? values.decode(Int.self, forKey: .totalProjectCount)
  }
}

extension ParentCategory: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.categoryType.intID ?? unrecognizedCategoryId)
  }
}

extension ParentCategory: Equatable {
  public static func == (lhs: ParentCategory, rhs: ParentCategory) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Category: Comparable {}
public func < (lhs: Category, rhs: Category) -> Bool {
  if lhs.id == rhs.id {
    return false
  }

  if lhs.isRoot, lhs.id == rhs.parent?.id {
    return true
  }

  if !lhs.isRoot, lhs.parent?.id == rhs.id {
    return false
  }

  if let lhsRootName = lhs.parent?.name, let rhsRootName = rhs.parent?.name {
    return lhsRootName < rhsRootName
  }

  return lhs.parent == nil
}

extension Category: Equatable {
  public static func == (lhs: Category, rhs: Category) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Category: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.intID ?? unrecognizedCategoryId)
  }
}

extension Category: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return "GraphCategory(id: \(self.id), name: \(self.name))"
  }

  public var debugDescription: String {
    return self.description
  }
}
