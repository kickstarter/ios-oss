import Combine
import Foundation
import KsApi
import Library
import SwiftUI

public class PPOContainerViewController: PagedContainerViewController<PPOContainerViewController.Page> {
  private let viewModel = PPOContainerViewModel()

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.title = Strings.tabbar_activity()

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

    self.viewModel.navigationEvents.sink { [weak self] nav in
      switch nav {
      case .backedProjects:
        tabBarController?.switchToProfile()
      case let .editAddress(url), let .survey(url), let .backingDetails(url):
        self?.openSurvey(url)
      case let .contactCreator(messageSubject):
        self?.messageCreator(messageSubject)
      case .confirmAddress, .fix3DSChallenge, .fixPaymentMethod:
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

    public var name: String {
      switch self {
      case .projectAlerts:
        Strings.Project_alerts()
      case .activityFeed:
        Strings.discovery_accessibility_toolbar_buttons_activity_label()
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

  private func messageCreator(_ messageSubject: MessageSubject) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: messageSubject, context: .backerModal)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    vc.delegate = self
    self.present(nav, animated: true, completion: nil)
  }
}

extension PPOContainerViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage _: Message) {}
}
