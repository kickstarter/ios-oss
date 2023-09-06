public enum ShortcutItem {
  case projectsWeLove
  case recommendedForYou
  case search

  public init?(typeString: String) {
    switch typeString {
    case "projects_we_love":
      self = .projectsWeLove
    case "recommended_for_you":
      self = .recommendedForYou
    case "search":
      self = .search
    default:
      return nil
    }
  }

  public var typeString: String {
    switch self {
    case .projectsWeLove:
      return "projects_we_love"
    case .recommendedForYou:
      return "recommended_for_you"
    case .search:
      return "search"
    }
  }
}

extension ShortcutItem: Equatable {}
public func == (lhs: ShortcutItem, rhs: ShortcutItem) -> Bool {
  switch (lhs, rhs) {
  case (.projectsWeLove, .projectsWeLove),
       (.recommendedForYou, .recommendedForYou),
       (.search, .search):
    return true
  default:
    return false
  }
}
