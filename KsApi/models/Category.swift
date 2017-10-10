import Argo
import Curry
import Runes

public struct Category {
  public private(set) var color: Int?
  public private(set) var id: Int
  public private(set) var name: String
  // NB: To get around lack of recursive structs we package the parent category into an internal closure
  // and then expose a property that evaluates the closure.
  internal let _parent: () -> Category?
  public private(set) var parentId: Int?
  public private(set) var position: Int
  public private(set) var projectsCount: Int?
  public private(set) var slug: String

  public static let gamesId: Int = 12

  internal init(color: Int?,
                id: Int,
                name: String,
                parent: Category?,
                parentId: Int?,
                position: Int,
                projectsCount: Int?,
                slug: String) {
    self.color = color
    self.id = id
    self.name = name
    self._parent = { parent }
    self.parentId = parentId
    self.position = position
    self.projectsCount = projectsCount
    self.slug = slug
  }

  public var parent: Category? {
    return self._parent()
  }

  /// Returns the parent category if present, or returns self if we know for a fact that self is a
  /// root categeory.
  public var root: Category? {
    if let parent = self.parent {
      return parent
    } else if self.parentId == nil {
      return self
    }
    return nil
  }

  /// Returns the id of the root category. This is sometimes present in situations that `root` is not.
  public var rootId: Int? {
    return self.parentId ?? self.root?.id
  }

  public var isRoot: Bool {
    return self.parentId == nil && self.parent == nil
  }
}

extension Category: Equatable {}
public func == (lhs: Category, rhs: Category) -> Bool {
  return lhs.id == rhs.id
}

extension Category: Hashable {
  public var hashValue: Int {
    return self.id
  }
}

extension Category: Comparable {}
public func < (lhs: Category, rhs: Category) -> Bool {
  if lhs.id == rhs.id {
    return false
  }

  if lhs.isRoot && lhs.id == rhs.rootId {
    return true
  }

  if !lhs.isRoot && lhs.rootId == rhs.id {
    return false
  }

  if let lhsRootName = lhs.root?.name, let rhsRootName = rhs.root?.name {
    return lhsRootName < rhsRootName
  }

  return lhs.root == nil
}

extension Category: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return "Category(id: \(self.id), name: \(self.name))"
  }

  public var debugDescription: String {
    return self.description
  }
}

extension Category: Argo.Decodable {

  public static func decode(_ json: JSON) -> Decoded<Category> {
    let create = curry(Category.init)
    let tmp = create
      <^> json <|? "color"
      <*> json <| "id"
      <*> json <| "name"
      <*> json <|? "parent"
    return tmp
      <*> json <|? "parent_id"
      <*> json <| "position"
      <*> json <|? "projects_count"
      <*> json <| "slug"
  }
}
