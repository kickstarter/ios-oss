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
      return Strings.New_work_and_big_ideas_from_established_and()
    case .games:
      return Strings.Join_our_secret_society()
    case .happening:
      return Strings.The_zeitgeist_delivered_to_your_inbox_via_new()
    case .invent:
      return Strings.Discover_the_future_of_Design_and_Tech()
    case .promo:
      return Strings.Big_Kickstarter_news_and_events_near_you()
    case .weekly:
      return Strings.A_weekly_roundup_of_the_best_and_brightest()
    case .films:
      return Strings.Love_film_We_do_too()
    case .publishing:
      return Strings.Welcome_to_our_library_Peruse_the_stacks_with_us()
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
