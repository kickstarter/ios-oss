public enum LandingPageCardType {
  case allOrNothing
  case discoverProjects
  case successfulProjects
  case totalBackers
  case totalPledged
  case trackBackings

  public static var statsCards: [LandingPageCardType] {
    return [.totalPledged, .successfulProjects, .totalBackers]
  }

  public static var howToCards: [LandingPageCardType] {
    return [.discoverProjects, .allOrNothing, .trackBackings]
  }

  public var title: String {
    switch self {
    case .allOrNothing:
      return "👍 " + Strings.All_or_nothing()
    case .discoverProjects:
      return "🌎 " + Strings.Discover_creative_projects()
    case .successfulProjects:
      return Strings.Guide_creators_to_success()
    case .totalBackers:
      return Strings.Join_a_fruitful_community()
    case .totalPledged:
      return Strings.Support_creative_independence()
    case .trackBackings:
      return "👀 " + Strings.Track_your_backings()
    }
  }

  public var description: String {
    switch self {
    case .allOrNothing:
      return Strings.You_wont_be_charged_for_backing_a_project()
    case .discoverProjects:
      return Strings.Explore_and_support_the_latest_creative_ideas()
    case .successfulProjects:
      return Strings.Successful_projects_have_been_created_on_kickstarter()
    case .totalBackers:
      return Strings.Backers_have_signed_up_to_help_kickstarter_creators_bring_their_ideas_to_life()
    case .totalPledged:
      return Strings.Total_amount_backers_have_pledged_to_projects()
    case .trackBackings:
      // swiftformat:disable wrap
      return Strings.Stay_updated_on_the_projects_youve_backed_and_learn_about_how_these_creative_works_are_produced()
      // swiftformat:enable wrap
    }
  }

  public var quantity: String? {
    switch self {
    case .successfulProjects:
      return Strings.Total_plus(total: Format.wholeNumber(177_000))
    case .totalBackers:
      return Strings.Million_plus(total_amount: "17")
    case .totalPledged:
      let total = Format.currency(4, country: .us)
      return Strings.Total_amount_billion_plus(total_amount: total)
    case .allOrNothing, .discoverProjects, .trackBackings:
      return nil
    }
  }
}
