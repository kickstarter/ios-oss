import Combine
import Foundation
import Library
import SwiftUI

public class PPOContainerViewController: PagedContainerViewController<PPOContainerViewController.Page> {
  private let viewModel = PPOContainerViewModel()
  private var ppoViewModel = PPOViewModel()

  public override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: Translate these strings (MBL-1558)
    self.title = "Activity"

    let ppoView = PPOView(viewModel: self.ppoViewModel)
    let ppoViewController = UIHostingController(rootView: ppoView)
    ppoViewController.title = "Project Alerts"

    let activitiesViewController = ActivitiesViewController.instantiate()
    activitiesViewController.title = "Activity Feed"

    self.setPagedViewControllers([
      (.projectAlerts(.count(5)), ppoViewController),
      (.activityFeed(.dot), activitiesViewController)
    ])

    let tabBarController = self.tabBarController as? RootTabBarViewController

    let projectAlertsBadge = self.ppoViewModel.$results
      .map { results -> TabBarBadge in
        results.total.flatMap { count in .count(count) } ?? .none
      }

    Publishers.CombineLatest(projectAlertsBadge, self.viewModel.activityBadge)
      .sink { [weak self] projectAlerts, activity in
        self?.setPagedViewControllers([
          (.projectAlerts(projectAlerts), ppoViewController),
          (.activityFeed(activity), activitiesViewController)
        ])
      }
      .store(in: &self.subscriptions)

    ppoView.viewModel.navigationEvents.sink { nav in
      switch nav {
      case .backingPage:
        tabBarController?.switchToProfile()
      case .confirmAddress, .contactCreator, .fix3DSChallenge, .fixPaymentMethod, .survey:
        // TODO: MBL-1451
        break
      }
    }.store(in: &self.subscriptions)
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.viewWillAppear()
  }

  public enum Page: TabBarPage {
    case projectAlerts(TabBarBadge)
    case activityFeed(TabBarBadge)

    // TODO: Localize
    public var name: String {
      switch self {
      case .projectAlerts:
        "Project alerts"
      case .activityFeed:
        "Activity feed"
      }
    }

    public var badge: TabBarBadge {
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

  private var subscriptions = Set<AnyCancellable>()
}
