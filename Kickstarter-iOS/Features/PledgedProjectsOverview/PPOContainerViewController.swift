import Combine
import Foundation
import KsApi
import Library
import Stripe
import SwiftUI

public class PPOContainerViewController: UIViewController, MessageBannerViewControllerPresenting {
  private let viewModel = PPOContainerViewModel()

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.title = Strings.tabbar_backings()

    let ppoView = PPOView(
      shouldRefresh: self.viewModel.shouldRefresh,
      onCountChange: { [weak self] count in
        self?.viewModel.projectAlertsCountChanged(count)
      },
      onNavigate: { [weak self] event in
        self?.viewModel.handle(navigationEvent: event)
      }
    )

    let ppoViewController = UIHostingController(rootView: ppoView)
    self.displayChildViewController(ppoViewController)

    let tabBarController = self.tabBarController as? RootTabBarViewController

    // FIXME: MBL-2075: Badges will now be updated by RootTabBarController and displayed on the tab.
    // The PPO container will need to tell the root tab bar to refresh when a PPO action has occured.

    /*
      Update badges in the paging tab bar at the top of the view
     Publishers.CombineLatest(
       self.viewModel.projectAlertsBadge,
       self.viewModel.activityBadge
     )
     .map { projectAlerts, activity in
       let projectAlerts = Page.projectAlerts(projectAlerts)
       let activityFeed = Page.activityFeed(activity)
       return (projectAlerts, activityFeed)
     }
     .sink { [weak self, weak ppoViewController] projectAlerts, _ in
       guard let self, let ppoViewController else {
         return
       }
       ppoViewController.title = projectAlerts.name
       self.setPagedViewControllers([
         (projectAlerts, ppoViewController)
       ])
     }
     .store(in: &self.subscriptions)
     */

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

  public var messageBannerViewController: MessageBannerViewController?

  private var subscriptions = Set<AnyCancellable>()

  // MARK: - Navigation Helpers

  private func fixPayment(projectId: Int, backingId: Int) {
    let data = (projectParam: Param.id(projectId), backingParam: Param.id(backingId))
    let vc = ManagePledgeViewController.controller(with: data, delegate: self)
    vc.presentationController?.delegate = self
    self.navigationController?.present(vc, animated: true)
  }

  private func openSurvey(_ url: String) {
    let vc = SurveyResponseViewController.configuredWith(surveyUrl: url)
    vc.delegate = self
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    nav.presentationController?.delegate = self

    self.navigationController?.present(nav, animated: true)
  }

  private func messageCreator(_ messageSubject: MessageSubject) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: messageSubject, context: .backerModal)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    nav.presentationController?.delegate = self

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

  public func authenticationContextWillDismiss(_: UIViewController) {
    self.viewModel.actionFinishedPerforming()
  }
}

extension PPOContainerViewController: SurveyResponseViewControllerDelegate {
  public func surveyResponseViewControllerDismissed() {
    self.viewModel.actionFinishedPerforming()
  }
}

extension PPOContainerViewController: ManagePledgeViewControllerDelegate {
  func managePledgeViewController(
    _: ManagePledgeViewController,
    managePledgeViewControllerFinishedWithMessage _: String?
  ) {
    self.viewModel.actionFinishedPerforming()
  }

  func managePledgeViewControllerDidDismiss(_: ManagePledgeViewController) {
    self.viewModel.actionFinishedPerforming()
  }
}

extension PPOContainerViewController: UIAdaptivePresentationControllerDelegate {
  public func presentationControllerDidDismiss(_: UIPresentationController) {
    self.viewModel.actionFinishedPerforming()
  }
}
