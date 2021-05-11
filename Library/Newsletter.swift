public enum Newsletter: CaseIterable {
  case promo
  case weekly
  case happening
  case games
  case invent
  case arts
  case films
  case music
  case publishing
  case alumni

  public var displayableName: String {
    switch self {
    case .arts:
      return Strings.Kickstarter_Arts()
    case .games:
      return Strings.Kickstarter_Games()
    case .happening:
      return Strings.profile_settings_newsletter_happening()
    case .invent:
      return Strings.Kickstarter_Invent()
    case .promo:
      return Strings.Announcements()
    case .weekly:
      return Strings.profile_settings_newsletter_weekly()
    case .films:
      return Strings.Kickstarter_on_Film()
    case .publishing:
      return Strings.profile_settings_newsletter_publishing()
    case .alumni:
      return Strings.Working_on_it()
    case .music:
      return Strings.Kickstarter_Music()
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
      return Strings.A_monthly_pep_talk_to_boost_your_creative_practice_for_creators_of_all_types()
    case .music:
      return Strings.Its_like_the_radio_but_nothing_sucks_and_also_its_a_newsletter()
    }
  }

  public var trackingString: String {
    switch self {
    case .arts: return "arts"
    case .games: return "games"
    case .happening: return "happening"
    case .invent: return "invent"
    case .promo: return "promo"
    case .weekly: return "weekly"
    case .films: return "films"
    case .publishing: return "publishing"
    case .alumni: return "alumni"
    case .music: return "music"
    }
  }
}
