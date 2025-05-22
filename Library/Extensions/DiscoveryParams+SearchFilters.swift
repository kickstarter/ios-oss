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
      Strings.Project_status_late_pledge()
    case .upcoming:
      Strings.Project_status_upcoming()
    }
  }
}

// FIXME: MBL-2464 Add translated strings
extension DiscoveryParams.PercentRaisedBucket {
  public var title: String {
    switch self {
    case .bucket_0:
      return "Under 75%"
    case .bucket_1:
      return "75% to 100%"
    case .bucket_2:
      return "More than 100%"
    }
  }
}
