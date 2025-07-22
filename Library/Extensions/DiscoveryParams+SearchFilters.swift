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

  public var pillTitle: String {
    switch self {
    case .bucket_0:
      return Strings.Percentage_raised_pill_bucket_0()
    case .bucket_1:
      return Strings.Percentage_raised_pill_bucket_1()
    case .bucket_2:
      return Strings.Percentage_raised_pill_bucket_2()
    }
  }
}

extension DiscoveryParams.AmountRaisedBucket {
  public var title: String {
    switch self {
    case .bucket_0:
      return Strings.Amount_raised_bucket_0()
    case .bucket_1:
      return Strings.Amount_raised_bucket_1()
    case .bucket_2:
      return Strings.Amount_raised_bucket_2()
    case .bucket_3:
      return Strings.Amount_raised_bucket_3()
    case .bucket_4:
      return Strings.Amount_raised_bucket_4()
    }
  }

  public var pillTitle: String {
    switch self {
    case .bucket_0:
      return Strings.Amount_raised_pill_bucket_0()
    case .bucket_1:
      return Strings.Amount_raised_pill_bucket_1()
    case .bucket_2:
      return Strings.Amount_raised_pill_bucket_2()
    case .bucket_3:
      return Strings.Amount_raised_pill_bucket_3()
    case .bucket_4:
      return Strings.Amount_raised_pill_bucket_4()
    }
  }
}

extension DiscoveryParams.GoalBucket {
  public var title: String {
    switch self {
    case .bucket_0:
      return Strings.Goal_bucket_0()
    case .bucket_1:
      return Strings.Goal_bucket_1()
    case .bucket_2:
      return Strings.Goal_bucket_2()
    case .bucket_3:
      return Strings.Goal_bucket_3()
    case .bucket_4:
      return Strings.Goal_bucket_4()
    }
  }

  public var pillTitle: String {
    switch self {
    case .bucket_0:
      return Strings.Goal_pill_bucket_0()
    case .bucket_1:
      return Strings.Goal_pill_bucket_1()
    case .bucket_2:
      return Strings.Goal_pill_bucket_2()
    case .bucket_3:
      return Strings.Goal_pill_bucket_3()
    case .bucket_4:
      return Strings.Goal_pill_bucket_4()
    }
  }
}
