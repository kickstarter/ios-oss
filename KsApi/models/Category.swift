import Foundation
public struct ParentCategory: Swift.Decodable {
  public let id: String
  public let name: String

  public var categoryType: Category {
    return Category(id: self.id, name: self.name)
  }
}

private let unrecognizedCategoryId: Int = -1

public struct Category: Swift.Decodable {
  public static let gamesId: Int = 12
  public var id: String
  public var name: String
  internal let _parent: ParentCategory?
  public var parentId: String?
  public var subcategories: SubcategoryConnection?
  public var totalProjectCount: Int?

  public init(
    id: String,
    name: String,
    parentCategory: ParentCategory? = nil,
    parentId: String? = nil,
    subcategories: SubcategoryConnection? = nil,
    totalProjectCount: Int? = nil
  ) {
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
    return "\(Category.modelName)-\(id)"
  }

  public var parent: Category? {
    return self._parent?.categoryType
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

  public static var modelName: String = "Category"
}

extension Category {
  private enum CodingKeys: String, CodingKey {
    case id, name, parentId, _parent = "parentCategory", subcategories, totalProjectCount
  }

  private enum v1CodingKeys: String, CodingKey {
    case parentId = "parent_id"
    case parentName = "parent_name"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try stringOrInt(in: values, for: .id)
    self.name = try values.decode(String.self, forKey: .name)
    self.parentId = try? Category.tryParentId(decoder)
    self._parent = try? Category.tryParentCategory(decoder)
    self.subcategories = try? values.decode(SubcategoryConnection.self, forKey: .subcategories)
    self.totalProjectCount = try? values.decode(Int.self, forKey: .totalProjectCount)
  }

  /* Tries to decode the parent category from the expected GraphQL structure
   * failing which tries to decode it from the v1 API structure.
   * Returns nil if both fail to decode.
   */
  private static func tryParentCategory(
    _ decoder: Decoder
  ) throws -> ParentCategory? {
    // First try to decode as GraphQL ParentCategory from parentCategory key
    if let category = try? decoder
      .container(keyedBy: CodingKeys.self)
      .decode(ParentCategory.self, forKey: ._parent) {
      return category
    }

    let container = try decoder.container(keyedBy: v1CodingKeys.self)

    // Next try to decode from v1 flat structure
    let parentId = try? container.decode(Int?.self, forKey: .parentId)
      .flatMap(String.init)
      .flatMap(toGraphCategoryID)

    let parentName = try? container.decode(String.self, forKey: .parentName)

    guard let id = parentId, let name = parentName else { return nil }

    return ParentCategory(id: id, name: name)
  }

  private static func tryParentId(_ decoder: Decoder) throws -> String? {
    // First try to decode as GraphQL id from parentId key
    if let id = try? decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .parentId) {
      return id
    }

    // Next try to decode from v1 flat structure
    return try? decoder.container(keyedBy: v1CodingKeys.self)
      .decode(Int?.self, forKey: .parentId)
      .flatMap(String.init)
      .flatMap(toGraphCategoryID)
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

private func stringOrInt<K>(
  in container: KeyedDecodingContainer<K>,
  for key: KeyedDecodingContainer<K>.Key
) throws -> String {
  if let id = try? container.decode(String.self, forKey: key) {
    return id
  }

  guard let id = toGraphCategoryID(String(try container.decode(Int.self, forKey: key))) else {
    throw DecodingError.dataCorruptedError(
      forKey: key,
      in: container,
      debugDescription: "Unable to decode Category ID"
    )
  }

  return id
}

private func toGraphCategoryID(_ id: String) -> String? {
  return "\(Category.modelName)-\(id)"
    .data(using: .utf8)?
    .base64EncodedString()
}
