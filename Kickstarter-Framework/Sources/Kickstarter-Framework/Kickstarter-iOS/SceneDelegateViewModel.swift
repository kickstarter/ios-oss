import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

public protocol SceneDelegateViewModelInputs {
  /// Call when the application is handed off to.
  func applicationContinueUserActivity(_ userActivity: NSUserActivity) -> Bool

  /// Call to open a url that was sent to the app
  func applicationOpenUrl(
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool

  /// Call when the scene receives a request to perform a shortcut action.
  func applicationPerformActionForShortcutItem(_ item: UIApplicationShortcutItem)

  /// Call when the redirect URL has been found, see `findRedirectUrl` for more information.
  func foundRedirectUrl(_ url: URL)
}

public protocol SceneDelegateViewModelOutputs {
  /// Return this value in the delegate method.
  var continueUserActivityReturnValue: MutableProperty<Bool> { get }

  /// Emits the response from email verification with a message and success/failure.
  var emailVerificationCompleted: Signal<(String, Bool), Never> { get }

  /// Emits when the view needs to figure out the redirect URL for the emitted URL.
  /// Required in order to handle email links.
  var findRedirectUrl: Signal<URL, Never> { get }

  /// Emits when the root view controller should navigate to activity.
  var goToActivity: Signal<(), Never> { get }

  /// Emits when the root view controller should navigate to the discovery screen.
  var goToDiscovery: Signal<DiscoveryParams?, Never> { get }

  /// Emits when the root view controller should present the login modal.
  var goToLoginWithIntent: Signal<LoginIntent, Never> { get }

  /// Emits a message thread when we should navigate to it.
  var goToMessageThread: Signal<MessageThread, Never> { get }

  /// Emits a URL when we should open it in the safari browser.
  var goToMobileSafari: Signal<URL, Never> { get }

  /// Emits when the root view controller should navigate to the user's profile.
  var goToProfile: Signal<(), Never> { get }

  /// Emits when the root view controller should navigate to search.
  var goToSearch: Signal<(), Never> { get }

  /// Emits when a view controller should be presented.
  var presentViewController: Signal<UIViewController, Never> { get }

  /// Emits a fresh user to be updated in the app environment.
  var updateCurrentUserInEnvironment: Signal<User, Never> { get }
}

public protocol SceneDelegateViewModelType {
  var inputs: SceneDelegateViewModelInputs { get }
  var outputs: SceneDelegateViewModelOutputs { get }
}

/// Handles everything that arrives through a `UIWindowScene`'s delegate: URL opens, continued user
/// activities (universal links / Handoff), and shortcut-item invocations, for now. This is the
/// SceneDelegate's counterpart to `AppDelegateViewModel`, which instead handles push-notification and
/// Braze deep links.
/// Both funnel their resolved `Navigation` values through the shared `DeepLinkNavigationRouter`
/// router so the navigation-resolution logic isn't duplicated.
public final class SceneDelegateViewModel: SceneDelegateViewModelType, SceneDelegateViewModelInputs,
  SceneDelegateViewModelOutputs {
  public init() {
    let openUrl = self.applicationOpenUrlProperty.signal.skipNil()

    let continueUserActivity = self.applicationContinueUserActivityProperty.signal.skipNil()

    let continueUserActivityWithNavigation = continueUserActivity
      .filter { $0.activityType == NSUserActivityTypeBrowsingWeb }
      .map { activity in (activity, activity.webpageURL.flatMap(Navigation.match)) }

    self.continueUserActivityReturnValue <~ continueUserActivityWithNavigation.map(second >>> isNotNil)

    let deepLinkUrl = Signal
      .merge(
        openUrl.map { $0.url },
        self.foundRedirectUrlProperty.signal.skipNil(),
        continueUserActivity
          .filter { $0.activityType == NSUserActivityTypeBrowsingWeb }
          .map { $0.webpageURL }
          .skipNil()
      )

    let deepLinkFromUrl = deepLinkUrl.map(Navigation.match)

    let performShortcutItem = self.performActionForShortcutItemProperty.signal.skipNil()
      .map { ShortcutItem(typeString: $0.type) }
      .skipNil()

    let deepLinkFromShortcut = performShortcutItem
      .switchMap(navigation(fromShortcutItem:))

    let deepLink = Signal
      .merge(
        deepLinkFromUrl,
        deepLinkFromShortcut
      )
      .skipNil()

    let emailVerificationEvent = deepLinkUrl
      .filter { Navigation.match($0) == .profile(.verifyEmail) }
      .map(accessTokenFromUrl)
      .skipNil()
      .switchMap { accessToken in
        AppEnvironment.current.apiService.verifyEmail(withToken: accessToken)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.emailVerificationCompleted = emailVerificationEvent
      .map(emailVerificationCompletionData)
      .skipNil()

    self.findRedirectUrl = deepLinkUrl
      .filter { Navigation.match($0) == .emailClick }

    self.goToMobileSafari = deepLinkUrl
      .filter(shouldOpenUrlInBrowser)

    let deepLinkOutputs = DeepLinkNavigationRouter(deepLink: deepLink)

    self.goToActivity = deepLinkOutputs.goToActivity
    self.goToDiscovery = deepLinkOutputs.goToDiscovery
    self.goToLoginWithIntent = deepLinkOutputs.goToLoginWithIntent
    self.goToMessageThread = deepLinkOutputs.goToMessageThread
    self.goToProfile = deepLinkOutputs.goToProfile
    self.goToSearch = deepLinkOutputs.goToSearch
    self.presentViewController = deepLinkOutputs.presentViewController
    self.updateCurrentUserInEnvironment = deepLinkOutputs.updateCurrentUserInEnvironment
  }

  public var inputs: SceneDelegateViewModelInputs { return self }
  public var outputs: SceneDelegateViewModelOutputs { return self }

  fileprivate let applicationContinueUserActivityProperty = MutableProperty<NSUserActivity?>(nil)
  public func applicationContinueUserActivity(_ userActivity: NSUserActivity) -> Bool {
    self.applicationContinueUserActivityProperty.value = userActivity
    return self.continueUserActivityReturnValue.value
  }

  // swiftlint:disable:next large_tuple
  fileprivate typealias ApplicationOpenUrl = (
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  )
  fileprivate let applicationOpenUrlProperty = MutableProperty<ApplicationOpenUrl?>(nil)
  public func applicationOpenUrl(
    application: UIApplication?,
    url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool {
    self.applicationOpenUrlProperty.value = (application, url, options)
    return true
  }

  fileprivate let performActionForShortcutItemProperty = MutableProperty<UIApplicationShortcutItem?>(nil)
  public func applicationPerformActionForShortcutItem(_ item: UIApplicationShortcutItem) {
    self.performActionForShortcutItemProperty.value = item
  }

  private let foundRedirectUrlProperty = MutableProperty<URL?>(nil)
  public func foundRedirectUrl(_ url: URL) {
    self.foundRedirectUrlProperty.value = url
  }

  public let continueUserActivityReturnValue = MutableProperty(false)
  public let emailVerificationCompleted: Signal<(String, Bool), Never>
  public let findRedirectUrl: Signal<URL, Never>
  public let goToActivity: Signal<(), Never>
  public let goToDiscovery: Signal<DiscoveryParams?, Never>
  public let goToLoginWithIntent: Signal<LoginIntent, Never>
  public let goToMessageThread: Signal<MessageThread, Never>
  public let goToMobileSafari: Signal<URL, Never>
  public let goToProfile: Signal<(), Never>
  public let goToSearch: Signal<(), Never>
  public let presentViewController: Signal<UIViewController, Never>
  public let updateCurrentUserInEnvironment: Signal<User, Never>
}

// Figures out a `Navigation` to route the user to from a shortcut item.
private func navigation(fromShortcutItem shortcutItem: ShortcutItem) -> SignalProducer<Navigation?, Never> {
  switch shortcutItem {
  case .recommendedForYou:
    let params = .defaults
      |> DiscoveryParams.lens.recommended .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    return SignalProducer(value: .tab(.discovery(params.queryParams)))

  case .projectsWeLove:
    let params = .defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    return SignalProducer(value: .tab(.discovery(params.queryParams)))

  case .search:
    return SignalProducer(value: .tab(.search))
  }
}

private func accessTokenFromUrl(_ url: URL?) -> String? {
  return url.flatMap { url in
    URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
  }?
    .first { item in item.name == "at" }?
    .value
}

private func emailVerificationCompletionData(
  event: Signal<EmailVerificationResponseEnvelope, ErrorEnvelope>.Event
) -> (String, Bool)? {
  guard !event.isCompleted else { return nil }

  guard isNil(event.error), let message = event.value?.message else {
    let message = event.error?.errorMessages.first ?? Strings.Something_went_wrong_please_try_again()

    return (message, false)
  }

  return (message, true)
}
