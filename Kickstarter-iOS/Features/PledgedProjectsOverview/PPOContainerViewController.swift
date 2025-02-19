import Combine
import Foundation
import KsApi
import Library
import Stripe
import SwiftUI

public class PPOContainerViewController: PagedContainerViewController<PPOContainerViewController.Page>,
  MessageBannerViewControllerPresenting {
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

    // On the first 3DS challenge, set up the Stripe SDK
    self.viewModel.stripeConfiguration
      .first()
      .sink { publishableKey, merchantIdentifier in
        STPAPIClient.shared.publishableKey = publishableKey
        STPAPIClient.shared.configuration.appleMerchantIdentifier = merchantIdentifier
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
      case let .fixPaymentMethod(projectId, backingId):
        self?.fixPayment(projectId: projectId, backingId: backingId)
      case let .fix3DSChallenge(clientSecret, onProgress):
        self?.handle3DSChallenge(clientSecret: clientSecret, onProgress: onProgress)
      case let .confirmAddress(backingId, addressId, address, onProgress):
        self?.confirmAddress(
          backingId: backingId,
          addressId: addressId,
          address: address,
          onProgress: onProgress
        )
      }
    }.store(in: &self.subscriptions)

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.viewModel.showBanner
      // This delay is due to a nuance about SwiftUI, where the List we use is backed by a
      // UITableView which is inserted into the UIView hierarchy at a different level than
      // the hosting view. If we run this notification immediately, the table view will
      // update right after, which will push the table view above the message banner in
      // the view hierarchy, causing the banner to be displayed below the table, leading
      // to clipping. This delay causes the banner to not show until after the table's
      // animation has already fired, preventing the reordering issue.
      .delay(for: 0.1, scheduler: RunLoop.main)
      .sink { [weak self] configuration in
        guard let self, let messageBannerViewController = self.messageBannerViewController else { return }
        messageBannerViewController.showBanner(with: configuration.type, message: configuration.message)

        // Determine feedback type based on banner type
        switch configuration.type {
        case .success, .info:
          generateNotificationSuccessFeedback()
        case .error:
          generateNotificationWarningFeedback()
        }
      }
      .store(in: &self.subscriptions)
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

  public var messageBannerViewController: MessageBannerViewController?

  private var subscriptions = Set<AnyCancellable>()

  // MARK: - Navigation Helpers

  private func fixPayment(projectId: Int, backingId: Int) {
    let data = (projectParam: Param.id(projectId), backingParam: Param.id(backingId))
    let vc = ManagePledgeViewController.controller(with: data, delegate: nil)
    self.present(vc, animated: true)
  }

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

  private func confirmAddress(
    backingId: String,
    addressId: String,
    address: String,
    onProgress: @escaping (PPOActionState) -> Void
  ) {
    onProgress(.processing)

    let alert = UIAlertController(
      title: Strings.Confirm_your_address(),
      message: address,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(
      title: Strings.Cancel(),
      style: .cancel,
      handler: { _ in onProgress(.cancelled) }
    ))
    alert.addAction(UIAlertAction(
      title: Strings.Confirm(),
      style: .default,
      handler: { [weak self] _ in
        self?.viewModel.confirmAddress(addressId: addressId, backingId: backingId, onProgress: onProgress)
      }
    ))
    self.present(alert, animated: true, completion: nil)
  }

  #if DEBUG
    private var test3DSError = true
  #endif

  private func handle3DSChallenge(
    clientSecret: String,
    onProgress: @escaping (PPOActionState) -> Void
  ) {
    if clientSecret.hasPrefix("seti_") {
      onProgress(.processing)

      let confirmParams = STPSetupIntentConfirmParams(clientSecret: clientSecret)
      self.handle3DSSetupIntent(confirmParams: confirmParams, onProgress: onProgress)
    } else if clientSecret.hasPrefix("pi_") {
      onProgress(.processing)

      let paymentParams = STPPaymentIntentParams(clientSecret: clientSecret)
      self.handle3DSPaymentIntent(paymentParams: paymentParams, onProgress: onProgress)
    } else {
      onProgress(.failed)
    }
  }

  private func handle3DSSetupIntent(
    confirmParams: STPSetupIntentConfirmParams,
    onProgress: @escaping (PPOActionState) -> Void
  ) {
    STPPaymentHandler.shared().confirmSetupIntent(
      confirmParams,
      with: self,
      completion: { [weak self] status, _, _ in
        switch status {
        case .succeeded:
          self?.viewModel.process3DSAuthentication(state: .succeeded)
          onProgress(.succeeded)
        case .canceled:
          onProgress(.cancelled)
        case .failed:
          self?.viewModel.process3DSAuthentication(state: .failed)
          onProgress(.failed)
        }
      }
    )
  }

  private func handle3DSPaymentIntent(
    paymentParams: STPPaymentIntentParams,
    onProgress: @escaping (PPOActionState) -> Void
  ) {
    STPPaymentHandler.shared().confirmPayment(
      paymentParams,
      with: self,
      completion: { [weak self] status, _, _ in
        switch status {
        case .succeeded:
          self?.viewModel.process3DSAuthentication(state: .succeeded)
          onProgress(.succeeded)
        case .canceled:
          onProgress(.cancelled)
        case .failed:
          self?.viewModel.process3DSAuthentication(state: .failed)
          onProgress(.failed)
        }
      }
    )
  }
}

extension PPOContainerViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage _: Message) {}
}

extension PPOContainerViewController: STPAuthenticationContext {
  public func authenticationPresentingViewController() -> UIViewController {
    return self
  }
}
