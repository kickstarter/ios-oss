/**
 Supported languages.
*/
public enum Language: String {
  case de
  case en
  case es
  case fr

  public static let allLanguages: [Language] = [.de, .en, .es, .fr]
}

extension Language: Equatable {}
public func == (lhs: Language, rhs: Language) -> Bool {
  switch (lhs, rhs) {
  case (.en, .en), (.es, .es), (.fr, .fr), (.de, .de):
    return true
  default:
    return false
  }
}
