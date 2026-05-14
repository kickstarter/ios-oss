import Experimentation
import KsApi

public extension Environment {
  /// Identifies a Kickstarter user for both Segment and Statsig.
  func identify(user: User?) {
    self.ksrAnalytics.identify(newUser: user)

    let statsigUser = StatsigClientUser(
      ksrUserId: user?.id,
      segmentAnonymousId: self.ksrAnalytics.anonymousId
    )

    self.statsigClient?.reload(withUser: statsigUser)
  }

  func statsigUser() -> StatsigClientUser {
    StatsigClientUser(
      ksrUserId: self.currentUser?.id,
      segmentAnonymousId: self.ksrAnalytics.anonymousId
    )
  }
}
