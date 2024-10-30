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
    ppoViewController.title = "Project Alerts"

    let activitiesViewController = ActivitiesViewController.instantiate()
    activitiesViewController.title = "Activity Feed"

    self.setPagedViewControllers([
      (.projectAlerts(.none), ppoViewController),
      (.activityFeed(.none), activitiesViewController)
    ])

    let tabBarController = self.tabBarController as? RootTabBarViewController

    Publishers.CombineLatest(
      self.viewModel.projectAlertsBadge,
      self.viewModel.activityBadge
    )
    .sink { [weak self] projectAlerts, activity in
      self?.setPagedViewControllers([
        (.projectAlerts(projectAlerts), ppoViewController),
        (.activityFeed(activity), activitiesViewController)
      ])
    }
    .store(in: &self.subscriptions)

    self.viewModel.navigationEvents.sink { [weak self] nav in
      switch nav {
      case .backedProjects:
        tabBarController?.switchToProfile()
      case let .editAddress(url), let .survey(url), let .backingDetails(url):
        self?.openSurvey(url)
      case .confirmAddress, .contactCreator, .fix3DSChallenge, .fixPaymentMethod:
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

  // MARK: - Navigation Helpers

  private func openSurvey(_ url: String) {
    let vc = SurveyResponseViewController.configuredWith(surveyUrl: url)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }
}
