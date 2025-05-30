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

extension DiscoveryParams.PercentRaisedBucket {
  public var title: String {
    switch self {
    case .bucket_0:
      return Strings.Percentage_raised_bucket_0()
    case .bucket_1:
      return Strings.Percentage_raised_bucket_1()
    case .bucket_2:
      return Strings.Percentage_raised_bucket_2()
    }
  }
}
