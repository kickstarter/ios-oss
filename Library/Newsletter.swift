public enum Newsletter {
  case arts
  case games
  case happening
  case invent
  case promo
  case weekly

  public var displayableName: String {
    switch self {
    case .arts:
      return "Arts & Culture News"
    case .games:
      return Strings.profile_settings_newsletter_games()
    case .happening:
      return Strings.profile_settings_newsletter_happening()
    case .invent:
      return "Invent"
    case .promo:
      return Strings.profile_settings_newsletter_promo()
    case .weekly:
      return Strings.profile_settings_newsletter_weekly()
    }
  }

  public var trackingString: String {
    switch self {
    case .arts:       return "arts"
    case .games:      return "games"
    case .happening:  return "happening"
    case .invent:     return "invent"
    case .promo:      return "promo"
    case .weekly:     return "weekly"
    }
  }
}
