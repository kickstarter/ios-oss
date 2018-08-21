public enum Newsletter {
  case arts
  case games
  case happening
  case invent
  case promo
  case weekly
  case films
  case publishing
  case alumni

  public static var allCases: [Newsletter] = [.weekly,
                                              .happening,
                                              .promo,
                                              .games,
                                              .invent,
                                              .arts,
                                              .films,
                                              .publishing,
                                              .alumni]

  public var displayableName: String {
    switch self {
    case .arts:
      return Strings.profile_settings_newsletter_arts_news()
    case .games:
      return Strings.profile_settings_newsletter_games()
    case .happening:
      return Strings.profile_settings_newsletter_happening()
    case .invent:
      return Strings.profile_settings_newsletter_invent()
    case .promo:
      return Strings.profile_settings_newsletter_news_event()
    case .weekly:
      return Strings.profile_settings_newsletter_weekly()
    case .films:
      return Strings.profile_settings_newsletter_film()
    case .publishing:
      return Strings.profile_settings_newsletter_publishing()
    case .alumni:
      return Strings.profile_settings_newsletter_alumni()
    }
  }

  public var displayableDescription: String {
    switch self {
    case .arts:
      return Strings.profile_settings_newsletter_arts_news_newsletter()
    case .games:
      return Strings.Games_newsletter()
    case .happening:
      return Strings.Happening_newsletter()
    case .invent:
      return Strings.Discover_arts_news()
    case .promo:
      return Strings.News_events()
    case .weekly:
      return Strings.Sign_up_newsletter()
    case .films:
      return Strings.profile_settings_newsletter_films_newsletter()
    case .publishing:
      return Strings.profile_settings_newsletter_publishing_newsletter()
    case .alumni:
      return Strings.profile_settings_newsletter_alumni_newsletter()
    }
  }

  public var trackingString: String {
    switch self {
    case .arts:               return "arts"
    case .games:              return "games"
    case .happening:          return "happening"
    case .invent:             return "invent"
    case .promo:              return "promo"
    case .weekly:             return "weekly"
    case .films:              return "films"
    case .publishing:         return "publishing"
    case .alumni:             return "alumni"
    }
  }
}
