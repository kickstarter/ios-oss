public enum RootCategory: Int {
  case art = 1
  case comics = 3
  case crafts = 26
  case dance = 6
  case design = 7
  case fashion = 9
  case food = 10
  case film = 11
  case games = 12
  case journalism = 13
  case music = 14
  case photography = 15
  case publishing = 18
  case tech = 16
  case theater = 17
  case unrecognized = -1

  public init(categoryId: Int) {
    self = RootCategory(rawValue: categoryId) ?? .unrecognized
  }
}

// swiftlint:disable cyclomatic_complexity
public extension RootCategory {
  public func allProjectsString() -> String {
    switch self {
    case .art:          return Strings.all_art_projects()
    case .comics:       return Strings.all_comics_projects()
    case .dance:        return Strings.all_dance_projects()
    case .design:       return Strings.all_design_projects()
    case .fashion:      return Strings.all_fashion_projects()
    case .food:         return Strings.all_food_projects()
    case .film:         return Strings.all_film_projects()
    case .games:        return Strings.all_games_projects()
    case .journalism:   return Strings.all_journalism_projects()
    case .music:        return Strings.all_music_projects()
    case .photography:  return Strings.all_photography_projects()
    case .tech:         return Strings.all_tech_projects()
    case .theater:      return Strings.all_theater_projects()
    case .publishing:   return Strings.all_publishing_projects()
    case .crafts:       return Strings.all_crafts_projects()
    case .unrecognized: return ""
    }
  }
}
// swiftlint:enable cyclomatic_complexity
