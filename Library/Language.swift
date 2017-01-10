/**
 Supported languages.
*/
public enum Language: String {
  case de
  case en
  case es
  case fr

  public static let allLanguages: [Language] = [.de, .en, .es, .fr]

  public init?(languageString language: String) {
    switch language.lowercased() {
    case "de":  self = .de
    case "en":  self = .en
    case "es":  self = .es
    case "fr":  self = .fr
    default:    return nil
    }
  }

  public init?(languageStrings languages: [String]) {
    guard let language = languages
      .lazy
      .map({ String($0.characters.prefix(2)) })
      .flatMap(Language.init(languageString:))
      .first else {
        return nil
    }

    self = language
  }
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
