import Prelude

// MARK: - Graph Response

public struct GraphResponse<T: Decodable>: Decodable {
  let data: T
}

public struct GraphResponseErrorEnvelope: Decodable {
  let errors: [GraphResponseError]?
}

// MARK: - Base Query Types

extension Never: CustomStringConvertible {
  public var description: String {
    fatalError()
  }
}

public protocol QueryType: CustomStringConvertible, Hashable {}

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

public func join<Q: QueryType>(_ nodes: NonEmptySet<Q>, _: String = " ") -> String {
  return join(Array(nodes))
}

public func decodeBase64(_ input: String) -> String? {
  return Data(base64Encoded: input)
    .flatMap { String(data: $0, encoding: .utf8) }
}

public func decompose(id: String) -> Int? {
  return decodeBase64(id)
    .flatMap { id -> Int? in
      let pair = id.split(separator: "-", maxSplits: 1)
      return pair.last.flatMap { Int($0) }
    }
}

public struct RelayId: Swift.Decodable {
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

public struct GraphResponseError: Decodable {
  public let message: String
}

public enum GraphError: Error {
  case invalidInput
  case invalidJson(responseString: String?)
  case requestError(Error, URLResponse?)
  case emptyResponse(URLResponse?)
  case decodeError(GraphResponseError)
  case jsonDecodingError(responseString: String?, error: Error?)
}

public enum Query {
  case backing(id: String, NonEmptySet<Backing>)
  case category(id: String, NonEmptySet<Category>)
  case project(slug: String, NonEmptySet<Project>)
  case rootCategories(NonEmptySet<Category>)
  case user(NonEmptySet<User>)

  public enum Category {
    public enum ProjectsConnection {
      public enum Argument {
        case state(Project.State)
      }
    }

    case id
    case name
    case parentId
    case parentCategory
    case projects(Set<QueryArg<ProjectsConnection.Argument>>, NonEmptySet<Connection<Project>>)
    case slug
    indirect case subcategories(Set<QueryArg<Never>>, NonEmptySet<Connection<Category>>)
    case totalProjectCount
    case url
  }

  public enum Conversation {
    case id
  }

  public enum Location: String {
    case country
    case displayableName
    case id
    case name
  }

  public enum NewsletterSubscriptions: String {
    case alumniNewsletter
    case artsCultureNewsletter
    case filmNewsletter
    case gamesNewsletter
    case happeningNewsletter
    case inventNewsletter
    case promoNewsletter
    case publishingNewsletter
    case weeklyNewsletter
    case musicNewsletter
  }

  public enum Notifications: String {
    case email
    case mobile
    case topic
  }

  public indirect enum Project {
    case backing(NonEmptySet<Backing>)
    case creator(NonEmptySet<User>)
    case finalCollectionDate
    case id
    case name
    case pid
    case projectSummary(NonEmptySet<ProjectSummary>)
    case slug
    case state
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

    public enum ProjectSummary: String {
      case question
      case response
    }
  }

  public enum Reward {
    case amount(NonEmptySet<Money>)
    case backersCount
    case description
    case estimatedDeliveryOn
    case id
    case items(Set<QueryArg<Never>>, NonEmptySet<Connection<Item>>)
    case name

    public enum Item {
      case id
      case name
    }
  }

  public enum Backing {
    case amount(NonEmptySet<Money>)
    case backer(NonEmptySet<User>)
    case bankAccount(NonEmptySet<BankAccount>)
    case cancelable
    case creditCard(NonEmptySet<CreditCard>)
    case errorReason
    case id
    case location(NonEmptySet<Location>)
    case pledgedOn
    case project(NonEmptySet<Project>)
    case reward(NonEmptySet<Reward>)
    case sequence
    case shippingAmount(NonEmptySet<Money>)
    case status
  }

  public indirect enum User {
    case backedProjects(Set<QueryArg<Never>>, NonEmptySet<Connection<Project>>)
    case backings(status: String, Set<QueryArg<Never>>, NonEmptySet<Connection<Backing>>)
    case backingsCount
    case biography
    case chosenCurrency
    case conversations(Set<QueryArg<Never>>, NonEmptySet<Connection<Conversation>>)
    case createdProjects(Set<QueryArg<Never>>, NonEmptySet<Connection<Project>>)
    case drop
    case email
    case followers(Set<QueryArg<Never>>, NonEmptySet<Connection<User>>)
    case following(Set<QueryArg<Never>>, NonEmptySet<Connection<User>>)
    case hasPassword
    case hasUnreadMessages
    case id
    case image(alias: String, width: Int)
    case imageUrl(alias: String, blur: Bool, width: Int)
    case isAppleConnected
    case isEmailDeliverable
    case isEmailVerified
    case isFollowing
    case isSocializing
    case launchedProjects(NonEmptySet<LaunchedProjects>)
    case location(NonEmptySet<Location>)
    case membershipProjects(Set<QueryArg<Never>>, NonEmptySet<Connection<Project>>)
    case name
    case needsFreshFacebookToken
    case newletterSubscriptions(NonEmptySet<NewsletterSubscriptions>)
    case notifications(NonEmptySet<Notifications>)
    case optedOutOfRecommendations
    case showPublicProfile
    case savedProjects(Set<QueryArg<Never>>, NonEmptySet<Connection<Project>>)
    case storedCards(Set<QueryArg<Never>>, NonEmptySet<Connection<CreditCard>>)
    case slug
    case uid
    case url
    case userId

    public enum LaunchedProjects {
      case totalCount
    }
  }

  public enum CreditCard: String {
    case expirationDate
    case id
    case lastFour
    case paymentType
    case type
  }

  public enum BankAccount: String {
    case bankName
    case id
    case lastFour
  }

  public enum Money: String {
    case amount
    case currency
    case symbol
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
    case let .backing(id, fields):
      return "backing(id: \"\(id)\") { \(join(fields)) }"
    case let .category(id, fields):
      return "node(id: \"\(id)\") { ... on Category { \(join(fields)) } }"
    case let .project(slug, fields):
      return "project(slug: \"\(slug)\") { \(join(fields)) }"
    case let .rootCategories(fields):
      return "rootCategories { \(join(fields)) }"
    case let .user(fields):
      return "me { \(join(fields)) }"
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
    case .cursor: return "cursor"
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
    case let .nodes(fields): return "nodes { \(join(fields)) }"
    case let .pageInfo(pageInfo): return "pageInfo { \(join(pageInfo)) }"
    case let .edges(fields): return "edges { \(join(fields)) }"
    case .totalCount: return "totalCount"
    }
  }
}

// MARK: - Category

extension Query.Category: QueryType {
  public var description: String {
    switch self {
    case .id: return "id"
    case .name: return "name"
    case .parentCategory: return "parentCategory { id name }"
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

// MARK: - Project

extension Query.Project: QueryType {
  public var description: String {
    switch self {
    case let .backing(fields): return "backing { \(join(fields)) }"
    case let .creator(fields): return "creator { \(join(fields)) }"
    case .finalCollectionDate: return "finalCollectionDate"
    case .id: return "id"
    case .name: return "name"
    case .pid: return "pid"
    case let .projectSummary(fields): return "projectSummary { \(join(fields)) }"
    case .slug: return "slug"
    case .state: return "state"
    case let .updates(args, fields): return "updates\(connection(args, fields))"
    }
  }
}

// MARK: - Update

extension Query.Project.Update: QueryType {
  public var description: String {
    switch self {
    case let .author(fields): return "author { \(join(fields)) }"
    case .id: return "id"
    case .publishedAt: return "publishedAt"
    case .title: return "title"
    }
  }
}

// MARK: - User

extension Query.User: QueryType {
  public var description: String {
    switch self {
    case let .backings(status, args, fields):
      return "backings(status: \(status))\(connection(args, fields))"
    case .backingsCount: return "backingsCount"
    case .biography: return "biography"
    case let .backedProjects(args, fields): return "backedProjects\(connection(args, fields))"
    case let .conversations(args, fields): return "conversations\(connection(args, fields))"
    case .chosenCurrency: return "chosenCurrency"
    case let .createdProjects(args, fields): return "createdProjects\(connection(args, fields))"
    case .drop: return "drop"
    case .email: return "email"
    case let .followers(args, fields): return "followers\(connection(args, fields))"
    case let .following(args, fields): return "following\(connection(args, fields))"
    case .hasPassword: return "hasPassword"
    case .hasUnreadMessages: return "hasUnreadMessages"
    case .id: return "id"
    case let .image(alias, width): return "\(alias): imageUrl(width: \(width))"
    case let .imageUrl(alias, blur, width): return "\(alias): imageUrl(blur: \(blur), width: \(width))"
    case .isAppleConnected: return "isAppleConnected"
    case .isEmailDeliverable: return "isDeliverable"
    case .isEmailVerified: return "isEmailVerified"
    case .isFollowing: return "isFollowing"
    case .isSocializing: return "isSocializing"
    case let .launchedProjects(fields): return "launchedProjects { \(join(fields)) }"
    case let .location(fields): return "location { \(join(fields)) }"
    case let .membershipProjects(args, fields): return "membershipProjects\(connection(args, fields))"
    case .name: return "name"
    case .needsFreshFacebookToken: return "needsFreshFacebookToken"
    case let .newletterSubscriptions(fields): return "newslettersSubscriptions { \(join(fields)) }"
    case let .notifications(fields): return "notifications { \(join(fields)) }"
    case .optedOutOfRecommendations: return "optedOutOfRecommendations"
    case let .savedProjects(args, fields): return "savedProjects\(connection(args, fields))"
    case .showPublicProfile: return "showPublicProfile"
    case let .storedCards(args, fields): return "storedCards\(connection(args, fields))"
    case .slug: return "slug"
    case .uid: return "uid"
    case .url: return "url"
    case .userId: return "uid"
    }
  }
}

// MARK: - ProjectSummary

extension Query.Project.ProjectSummary: QueryType {
  public var description: String {
    return self.rawValue
  }
}

extension Query.CreditCard: QueryType {
  public var description: String {
    return self.rawValue
  }
}

// swiftformat:disable wrap
extension Query.Backing: QueryType {
  public var description: String {
    switch self {
    case let .amount(fields): return "amount { \(join(fields)) }"
    case let .backer(fields): return "backer { \(join(fields)) }"
    case let .bankAccount(fields): return "bankAccount: paymentSource { ... on BankAccount {  \(join(fields)) } }"
    case .cancelable: return "cancelable"
    case let .creditCard(fields): return "creditCard: paymentSource { ... on CreditCard { \(join(fields)) } }"
    case .errorReason: return "errorReason"
    case .id: return "id"
    case let .location(fields): return "location { \(join(fields)) }"
    case .pledgedOn: return "pledgedOn"
    case let .project(fields): return "project { \(join(fields)) }"
    case let .reward(fields): return "reward { \(join(fields)) }"
    case .sequence: return "sequence"
    case let .shippingAmount(fields): return "shippingAmount { \(join(fields)) }"
    case .status: return "status"
    }
  }
}

// swiftformat:enable wrap

extension Query.BankAccount: QueryType {
  public var description: String {
    return self.rawValue
  }
}

extension Query.Reward: QueryType {
  public var description: String {
    switch self {
    case let .amount(fields): return "amount { \(join(fields)) }"
    case .backersCount: return "backersCount"
    case .description: return "description"
    case .estimatedDeliveryOn: return "estimatedDeliveryOn"
    case .id: return "id"
    case let .items(args, fields): return "items" + connection(args, fields)
    case .name: return "name"
    }
  }
}

extension Query.Reward.Item: QueryType {
  public var description: String {
    switch self {
    case .id: return "id"
    case .name: return "name"
    }
  }
}

extension Query.User.LaunchedProjects: QueryType {
  public var description: String {
    switch self {
    case .totalCount: return "totalCount"
    }
  }
}

// MARK: - NewsletterSubscriptions

extension Query.NewsletterSubscriptions: QueryType {
  public var description: String {
    return self.rawValue
  }
}

// MARK: - Notifications

extension Query.Notifications: QueryType {
  public var description: String {
    return self.rawValue
  }
}

// MARK: - Location

extension Query.Location: QueryType {
  public var description: String {
    return self.rawValue
  }
}

extension Query.Money: QueryType {
  public var description: String {
    return self.rawValue
  }
}

// MARK: - Conversation

extension Query.Conversation: QueryType {
  public var description: String {
    switch self {
    case .id: return "id"
    }
  }
}

// MARK: - Helpers

private func connection<T, U>(_ args: Set<QueryArg<T>>, _ fields: NonEmptySet<Connection<U>>) -> String {
  return "\(_args(args)) { \(join(fields)) }"
}

private func _args<T>(_ args: Set<QueryArg<T>>) -> String {
  return !args.isEmpty ? "(\(join(args)))" : ""
}

// MARK: - Hashable

extension QueryType {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}

extension Query.CreditCard {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}

extension Query.Location {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}

extension Query.NewsletterSubscriptions {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}

extension PageInfo {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}

extension Query.Notifications {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}

extension Query.Project.ProjectSummary {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}
