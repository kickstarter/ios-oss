import Foundation
public struct ParentCategory: Swift.Decodable {
  public let id: String
  public let name: String

  public var categoryType: Category {
      return Category(id: id, name: name)
  }
}

private let unrecognizedCategoryId: Int = -1

public struct Category: Swift.Decodable {
  public static let gamesId: Int = 12
  public fileprivate(set) var id: String
  public fileprivate(set) var name: String
  internal let _parent: ParentCategory?
  public fileprivate(set) var parentId: String?
  public fileprivate(set) var subcategories: SubcategoryConnection?
  public fileprivate(set) var totalProjectCount: Int?

  public init(id: String,
              name: String,
              parentCategory: ParentCategory? = nil,
              parentId: String? = nil,
              subcategories: SubcategoryConnection? = nil,
              totalProjectCount: Int? = nil) {
    self.id = id
    self.name = name
    self.parentId = parentId
    self._parent = parentCategory
    self.subcategories = subcategories
    self.totalProjectCount = totalProjectCount
  }

  public var intID: Int? {
    return decompose(id: id)
  }

  /*
   This is a work around that fixes the incompatibility between the types of category id returned by
   the server (Int) and the type we need to send when requesting category by id
   through GraphQL (base64 encoded String). This will be removed once we start consuming GraphQL to fetch
   Discovery projects.
   */
  public var decodedID: String {
    return "Category-\(id)"
  }

  public var parent: Category? {
    return _parent?.categoryType
  }

  public struct SubcategoryConnection: Swift.Decodable {
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
    case id, name, parentId, _parent = "parentCategory", subcategories, totalProjectCount
  }

  private init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try values.decode(String.self, forKey: .id)
    self.name = try values.decode(String.self, forKey: .name)
    self.parentId = try? values.decode(String.self, forKey: .parentId)
    self._parent = try? values.decode(ParentCategory.self, forKey: ._parent)
    self.subcategories = try? values.decode(SubcategoryConnection.self, forKey: .subcategories)
    self.totalProjectCount = try? values.decode(Int.self, forKey: .totalProjectCount)
  }
}

extension ParentCategory: Hashable {
  public var hashValue: Int {
    return self.categoryType.intID ?? unrecognizedCategoryId
  }
}

extension ParentCategory: Equatable {
  static public func == (lhs: ParentCategory, rhs: ParentCategory) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Category: Comparable {}
public func < (lhs: Category, rhs: Category) -> Bool {
  if lhs.id == rhs.id {
    return false
  }

  if lhs.isRoot && lhs.id == rhs.parent?.id {
    return true
  }

  if !lhs.isRoot && lhs.parent?.id == rhs.id {
    return false
  }

  if let lhsRootName = lhs.parent?.name, let rhsRootName = rhs.parent?.name {
    return lhsRootName < rhsRootName
  }

  return lhs.parent == nil
}

extension Category: Equatable {
  static public func == (lhs: Category, rhs: Category) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Category: Hashable {
  public var hashValue: Int {
    return self.intID ?? unrecognizedCategoryId
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
