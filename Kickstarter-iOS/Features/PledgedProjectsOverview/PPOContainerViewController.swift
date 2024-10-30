import Combine
import Foundation
import Library
import SwiftUI

public class PPOContainerViewController: PagedContainerViewController<PPOContainerViewController.Page> {
  private let viewModel = PPOContainerViewModel()

  public override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: Translate these strings (MBL-1558)
    self.title = "Activity"

    let ppoView = PPOView(
      onCountChange: { [weak self] count in
        self?.viewModel.projectAlertsCountChanged(count)
      },
      onNavigate: { [weak self] event in
        self?.viewModel.handle(navigationEvent: event)
      }
    )
    let ppoViewController = UIHostingController(rootView: ppoView)
    ppoViewController.title = Page.projectAlerts(.none).name

    let activitiesViewController = ActivitiesViewController.instantiate()
    activitiesViewController.title = Page.activityFeed(.none).name

    self.setPagedViewControllers([
      (.projectAlerts(.none), ppoViewController),
      (.activityFeed(.none), activitiesViewController)
    ])

    let tabBarController = self.tabBarController as? RootTabBarViewController

    // Update badges in the paging tab bar at the top of the view
    Publishers.CombineLatest(
      self.viewModel.projectAlertsBadge,
      self.viewModel.activityBadge
    )
    .map { projectAlerts, activity in
      let projectAlerts = Page.projectAlerts(projectAlerts)
      let activityFeed = Page.activityFeed(activity)
      return (projectAlerts, activityFeed)
    }
    .sink { [weak self, weak ppoViewController, weak activitiesViewController] projectAlerts, activityFeed in
      guard let self, let ppoViewController, let activitiesViewController else {
        return
      }
      ppoViewController.title = projectAlerts.name
      activitiesViewController.title = activityFeed.name
      self.setPagedViewControllers([
        (projectAlerts, ppoViewController),
        (activityFeed, activitiesViewController)
      ])
    }
    .store(in: &self.subscriptions)

    self.viewModel.navigationEvents.sink { nav in
      switch nav {
      case .backedProjects:
        tabBarController?.switchToProfile()
      case .editAddress, .confirmAddress, .contactCreator, .fix3DSChallenge, .fixPaymentMethod, .survey,
           .showProject:
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
        Strings.Project_alerts()
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
