import Experimentation

public extension StatsigClientUser {
  static func fromCurrentEnvironment() -> StatsigClientUser {
    guard let environment = AppEnvironment.current else {
      return StatsigClientUser(ksrUserId: nil, segmentAnonymousId: nil)
    }

    return StatsigClientUser(
      ksrUserId: environment.currentUser?.id,
      segmentAnonymousId: environment.ksrAnalytics.anonymousId
    )
  }
}
