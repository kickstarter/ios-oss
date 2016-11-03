public enum Newsletter {
  case games
  case happening
  case promo
  case weekly

  public var displayableName: String {
    switch self {
    case .games:
      return Strings.profile_settings_newsletter_games()
    case .happening:
      return Strings.profile_settings_newsletter_happening()
    case .promo:
      return Strings.profile_settings_newsletter_promo()
    case .weekly:
      return Strings.profile_settings_newsletter_weekly()
    }
  }

  public var trackingString: String {
    switch self {
    case .games:      return "games"
    case .happening:  return "happening"
    case .promo:      return "promo"
    case .weekly:     return "weekly"
    }
  }
}
