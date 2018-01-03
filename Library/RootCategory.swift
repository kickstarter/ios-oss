public enum RootCategory: String, RawRepresentable {
  case art = "Q2F0ZWdvcnktMQ=="
  case comics = "Q2F0ZWdvcnktMw=="
  case crafts = "Q2F0ZWdvcnktMjY="
  case dance = "Q2F0ZWdvcnktNg=="
  case design = "Q2F0ZWdvcnktNw=="
  case fashion = "Q2F0ZWdvcnktOQ=="
  case food = "Q2F0ZWdvcnktMTA="
  case film = "Q2F0ZWdvcnktMTE="
  case games = "Q2F0ZWdvcnktMTI="
  case journalism = "Q2F0ZWdvcnktMTM="
  case music = "Q2F0ZWdvcnktMTQ="
  case photography = "Q2F0ZWdvcnktMTU="
  case publishing = "Q2F0ZWdvcnktMTg="
  case tech = "Q2F0ZWdvcnktMTY="
  case theater = "Q2F0ZWdvcnktMTc="
  case unrecognized = "-1"

  public init(categoryId: String) {
    self = RootCategory(rawValue: categoryId) ?? .unrecognized
  }
}

// swiftlint:disable cyclomatic_complexity
public extension RootCategory {
  public func allProjectsString() -> String {
    switch self {
    case .art:          return Strings.All_Art_Projects()
    case .comics:       return Strings.All_Comics_Projects()
    case .dance:        return Strings.All_Dance_Projects()
    case .design:       return Strings.All_Design_Projects()
    case .fashion:      return Strings.All_Fashion_Projects()
    case .food:         return Strings.All_Food_Projects()
    case .film:         return Strings.All_Film_Projects()
    case .games:        return Strings.All_Games_Projects()
    case .journalism:   return Strings.All_Journalism_Projects()
    case .music:        return Strings.All_Music_Projects()
    case .photography:  return Strings.All_Photography_Projects()
    case .tech:         return Strings.All_Tech_Projects()
    case .theater:      return Strings.All_Theater_Projects()
    case .publishing:   return Strings.All_Publishing_Projects()
    case .crafts:       return Strings.All_Crafts_Projects()
    case .unrecognized: return ""
    }
  }
}
// swiftlint:enable cyclomatic_complexity
