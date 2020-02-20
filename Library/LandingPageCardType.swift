import Foundation

public enum LandingPageCardType {

  public enum Stats {
    case successfulProjects
    case totalBackers
    case totalPledged

    public func title() -> String {
      switch self {
      case .successfulProjects:
        return "Support creators to success"
      case .totalBackers:
        return "Join a fruitful community"
      case .totalPledged:
        return "Support creative independence"
      }
    }

    public func description() -> String {
      switch self {
      case .successfulProjects:
        return "Successful projects have been created on Kickstarter."
      case .totalBackers:
        return "Backers have signed up to help Kickstarter creators bring their ideas to life."
      case .totalPledged:
        return "Total amount (USD) backers have pledged to projects."
      }
    }

    public func quantity() -> String {
      switch self {
      case .successfulProjects:
        return "177,000+"
      case .totalBackers:
        return "17 million+"
      case .totalPledged:
        return "$4 billion+"
      }
    }
  }

  public enum HowTo {
    case allOrNothing
    case discoverProjects
    case trackBackings

    public func title() -> String {
      switch self {
      case .allOrNothing:
        return "🌎 Discover creative projects"
      case .discoverProjects:
        return "👍 Join a fruitful community"
      case .trackBackings:
        return "👀 Support creative independence"
      }
    }

    public func description() -> String {
      switch self {
      case .allOrNothing:
        return "You won't be charged for backing a project unless it reaches its funding goal."
      case .discoverProjects:
        return "Explore and support latest creative ideas created by our vast global community."
      case .trackBackings:
        return "Stay updated on the projects you've backed and learn about how these creative works are produced"
      }
    }
  }
}
