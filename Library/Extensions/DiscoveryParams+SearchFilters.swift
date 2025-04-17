import KsApi

extension DiscoveryParams.State {
  public var title: String {
    switch self {
    case .all:
      Strings.Project_status_all()
    case .live:
      Strings.Project_status_live()
    case .successful:
      Strings.Project_status_successful()
    case .late_pledge:
      Strings.Project_status_late_pledges()
    case .upcoming:
      Strings.Project_status_upcoming()
    }
  }
}
