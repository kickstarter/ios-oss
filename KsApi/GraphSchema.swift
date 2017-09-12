import Prelude

/// Base Query Types

extension Never: CustomStringConvertible {
  public var description: String {
    fatalError()
  }
}

public protocol QueryType: CustomStringConvertible, Hashable {}

extension QueryType {
  public var hashValue: Int {
    return description.hashValue
  }
}

public enum Connection<Q: QueryType> {
  case pageInfo(NonEmptySet<PageInfo>)
  case edges(NonEmptySet<Edges<Q>>)
  case nodes(NonEmptySet<Q>)
  case totalCount
}

public func == <Q: QueryType>(lhs: Q, rhs: Q) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

public func join<S: Sequence>(_ args: S, _ separator: String = " ") -> String
  where S.Iterator.Element: QueryType {
    return args.map { $0.description }.sorted().joined(separator: separator)
}

public func join<Q: QueryType>(_ nodes: NonEmptySet<Q>, _ separator: String = " ") -> String {
  return join(Array(nodes))
}

public struct RelayId {
  let id: String
}
extension RelayId: ExpressibleByStringLiteral {
  public init(unicodeScalarLiteral value: String) {
    self.init(id: value)
  }
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(id: value)
  }
  public init(stringLiteral value: String) {
    self.init(id: value)
  }
}

public enum QueryArg<T: CustomStringConvertible> {
  case after(String)
  case before(String)
  case first(Int)
  case last(Int)
  case arg(T)
}

public enum EdgesContainerBody<Q: QueryType> {
  case pageInfo(NonEmptySet<PageInfo>)
  case edges(NonEmptySet<Edges<Q>>)
}

public enum PageInfo: String {
  case endCursor
  case hasNextPage
  case hasPreviousPage
  case startCursor
}

public enum Edges<Q: QueryType> {
  case cursor
  case node(NonEmptySet<Q>)
}

public enum Nodes<Q: QueryType> {
  case nodes(NonEmptySet<Q>)
}

public struct GraphError: Error {

  let errors: [[String: Any]]
}

public enum Query {

  case project(slug: String, NonEmptySet<Project>)
  case rootCategories(NonEmptySet<Category>)

  public enum Amount {
    case amount
    case currency
  }

  public enum Category {
    public enum ProjectsConnection {
      public enum Argument {
        case state(Project.State)
      }
    }

    case id
    case name
    case parentId
    case projects(Set<QueryArg<ProjectsConnection.Argument>>, NonEmptySet<Connection<Project>>)
    case slug
    indirect case subcategories(Set<QueryArg<Never>>, NonEmptySet<Connection<Category>>)
    case totalProjectCount
    case url
  }

  public enum Conversation {
    case id
  }

  public enum Location {
    case id
    case name
  }

  public enum Project {
    case id
    case slug
    case updates(Set<QueryArg<Never>>, NonEmptySet<Connection<Project.Update>>)

    public enum State: String {
      case failed = "FAILED"
      case live = "LIVE"
      case successful = "SUCCESSFUL"
    }

    public enum Update {
      indirect case author(NonEmptySet<User>)
      case id
      case publishedAt
      case title
    }
  }

  public enum User {
    case biography
    case backedProjects(Set<QueryArg<Never>>, NonEmptySet<Connection<Project>>)
    case conversations(Set<QueryArg<Never>>, NonEmptySet<Connection<Conversation>>)
    case createdProjects(Set<QueryArg<Never>>, NonEmptySet<Connection<Project>>)
    case drop
    case email
    indirect case followers(Set<QueryArg<Never>>, NonEmptySet<Connection<User>>)
    indirect case following(Set<QueryArg<Never>>, NonEmptySet<Connection<User>>)
    case id
    case image(width: Int)
    case imageUrl(blur: Bool, width: Int)
    case isEmailVerified
    case isFollowing
    case location(NonEmptySet<Location>)
    case name
    case savedProjects(Set<QueryArg<Never>>, NonEmptySet<Connection<Project>>)
    case slug
    case url
  }
}

extension Query {
  public static func build(_ queries: NonEmptySet<Query>) -> String {
    return "{ \(join(queries)) }"
  }
}

extension Query: QueryType {
  public var description: String {
    switch self {
    case let .project(slug, fields):
      return "project(slug: \"\(slug)\") { \(join(fields)) }"
    case let .rootCategories(fields):
      return ""
    }
  }
}

extension QueryArg: QueryType {
  public var description: String {
    switch self {
    case let .after(cursor):
      return "after: \"\(cursor)\""
    case let .before(cursor):
      return "before: \"\(cursor)\""
    case let .first(count):
      return "first: \(count)"
    case let .last(count):
      return "last: \(count)"
    case let .arg(arg):
      return arg.description
    }
  }
}

extension EdgesContainerBody: QueryType {
  public var description: String {
    switch self {
    case let .edges(fields):
      return "edges { \(join(fields)) }"
    case let .pageInfo(pageInfo):
      return "pageInfo { \(join(pageInfo)) }"
    }
  }
}

extension Edges: QueryType {
  public var description: String {
    switch self {
    case .cursor:           return "cursor"
    case let .node(fields): return "node { \(join(fields)) }"
    }
  }
}

extension Nodes: QueryType {
  public var description: String {
    switch self {
    case let .nodes(fields):
      return "nodes { \(join(fields)) }"
    }
  }
}

extension PageInfo: QueryType {
  public var description: String {
    return rawValue
  }

  public static var all: NonEmptySet<PageInfo> {
    return .endCursor +| [
      .hasNextPage,
      .hasPreviousPage,
      .startCursor
    ]
  }
}

extension Connection: QueryType {
  public var description: String {
    switch self {
    case let .nodes(fields):      return "nodes { \(join(fields)) }"
    case let .pageInfo(pageInfo): return "pageInfo { \(join(pageInfo)) }"
    case let .edges(fields):      return "edges { \(join(fields)) }"
    case .totalCount:             return "totalCount"
    }
  }
}

/// Category

extension Query.Category: QueryType {
  public var description: String {
    switch self {
    case .id: return "id"
    case .name: return "name"
    case .parentId: return "parentId"
    case let .projects(args, fields): return "projects" + connection(args, fields)
    case .slug: return "slug"
    case let .subcategories(args, fields): return "subcategories" + connection(args, fields)
    case .totalProjectCount: return "totalProjectCount"
    case .url: return "url"
    }
  }
}

extension Query.Category.ProjectsConnection.Argument: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .state(state): return "state: \(state.rawValue)"
    }
  }
}

/// Project

extension Query.Project: QueryType {
  public var description: String {
    switch self {
    case .id:                        return "id"
    case .slug:                      return "slug"
    case let .updates(args, fields): return "updates\(connection(args, fields))"
    }
  }
}

/// Update

extension Query.Project.Update: QueryType {
  public var description: String {
    switch self {
    case let .author(fields): return "author { \(join(fields)) }"
    case .id:                 return "id"
    case .publishedAt:        return "publishedAt"
    case .title:              return "title"
    }
  }
}

/// User

extension Query.User: QueryType {
  public var description: String {
    switch self {
    case .biography:                         return "biography"
    case let .backedProjects(args, fields):  return "backedProjects\(connection(args, fields))"
    case let .conversations(args, fields):   return "conversations\(connection(args, fields))"
    case let .createdProjects(args, fields): return "createdProjects\(connection(args, fields))"
    case .drop:                              return "drop"
    case .email:                             return "email"
    case let .followers(args, fields):       return "followers\(connection(args, fields))"
    case let .following(args, fields):       return "following\(connection(args, fields))"
    case .id:                                return "id"
    case let .image(width):                  return "image(width: \(width))"
    case let .imageUrl(blur, width):         return "imageUrl(blur: \(blur), width: \(width))"
    case .isEmailVerified:                   return "isEmailVerified"
    case .isFollowing:                       return "isFollowing"
    case let .location(fields):              return "location { \(join(fields)) }"
    case .name:                              return "name"
    case let .savedProjects(args, fields):   return "savedProjects\(connection(args, fields))"
    case .slug:                              return "slug"
    case .url:                               return "url"
    }
  }
}

/// Location

extension Query.Location: QueryType {
  public var description: String {
    switch self {
    case .id:   return "id"
    case .name: return "name"
    }
  }
}

extension Query.Amount: QueryType {
  public var description: String {
    switch self {
    case .amount:   return "amount"
    case .currency: return "currency"
    }
  }
}

/// Conversation

extension Query.Conversation: QueryType {
  public var description: String {
    switch self {
    case .id: return "id"
    }
  }
}

/// Helpers

private func connection<T, U>(_ args: Set<QueryArg<T>>, _ fields: NonEmptySet<Connection<U>>) -> String {
  return "\(_args(args)) { \(join(fields)) }"
}

private func _args<T>(_ args: Set<QueryArg<T>>) -> String {
  return !args.isEmpty ? "(\(join(args)))" : ""
}
