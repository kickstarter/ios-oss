public enum Newsletter {
  case arts
  case games
  case happening
  case invent
  case promo
  case weekly

  public static var allCases: [Newsletter] = [.weekly, .promo, .happening, .games, .invent, .arts]

  public var displayableName: String {
    switch self {
    case .arts:
      return Strings.profile_settings_newsletter_arts()
    case .games:
      return Strings.profile_settings_rating_option_title_show_us_some_love()
    case .happening:
      return Strings.profile_settings_newsletter_happening()
    case .invent:
      return Strings.profile_settings_newsletter_invent()
    case .promo:
      return Strings.profile_settings_newsletter_news_event()
    case .weekly:
      return Strings.profile_settings_newsletter_weekly()
    }
  }

  public var displayableDescription: String {
    switch self {
    case .arts:
      return Strings.Stay_up_to_date_newsletter()
    case .games:
      return Strings.Stay_up_to_date_newsletter()
    case .happening:
      return Strings.Happening_newsletter()
    case .invent:
      return Strings.Stay_up_to_date_newsletter()
    case .promo:
      return Strings.News_events()
    case .weekly:
      return Strings.Sign_up_newsletter()
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
