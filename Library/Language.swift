/**
 Supported languages.
*/
public enum Language: String {
  case de
  case en
  case es
  case fr
  case ja

  public static let allLanguages: [Language] = [.de, .en, .es, .fr, .ja]

  public init?(languageString language: String) {
    switch language.lowercased() {
    case "de":  self = .de
    case "en":  self = .en
    case "es":  self = .es
    case "fr":  self = .fr
    case "ja":  self = .ja
    default:    return nil
    }
  }

  public init?(languageStrings languages: [String]) {
    guard let language = languages
      .lazy
      .map({ String($0.prefix(2)) })
      .flatMap(Language.init(languageString:))
      .first else {
        return nil
    }

    self = language
  }

  public var displayString: String {
    switch self {
    case .de: return "German"
    case .en: return "English"
    case .es: return "Spanish"
    case .fr: return "French"
    case .ja: return "Japanese"
    }
  }
}

extension Language: Equatable {}
public func == (lhs: Language, rhs: Language) -> Bool {
  switch (lhs, rhs) {
  case (.en, .en), (.es, .es), (.fr, .fr), (.de, .de), (.ja, .ja):
    return true
  default:
    return false
  }
}
