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

  init(categoryId: Int) {
    self = RootCategory(rawValue: categoryId) ?? .unrecognized
  }
}
