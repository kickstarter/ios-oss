import Foundation
import Library
import SwiftUI

public class PPOContainerViewController: PagedContainerViewController<PPOContainerViewController.Page> {
  public override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: Translate these strings (MBL-1558)
    self.title = "Activity"

    let tabBarController = self.tabBarController as? RootTabBarViewController
    let ppoViewController = UIHostingController(rootView: PPOView(tabBarController: tabBarController))
    ppoViewController.title = "Project Alerts"

    let activitiesViewController = ActivitiesViewController.instantiate()
    activitiesViewController.title = "Activity Feed"

    self.setPagedViewControllers([
      (.projectAlerts(badge: 5), ppoViewController),
      (.activityFeed(badge: nil), activitiesViewController)
    ])
  }

  public enum Page: TabBarPage {
    case projectAlerts(badge: Int?)
    case activityFeed(badge: Int?)

    // TODO: Localize
    public var name: String {
      switch self {
      case .projectAlerts:
        "Project alerts"
      case .activityFeed:
        "Activity feed"
      }
    }

    public var badgeCount: Int? {
      switch self {
      case let .projectAlerts(badge):
        badge
      case let .activityFeed(badge):
        badge
      }
    }

    public var id: String {
      self.name
    }
  }
}
