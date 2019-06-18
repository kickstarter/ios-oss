import Foundation
import KsApi
@testable import Library
import ReactiveSwift
import XCTest

// swiftlint:disable line_length
extension XCTestCase {
  // Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
  func withEnvironment(_ env: Environment, body: () -> Void) {
    AppEnvironment.pushEnvironment(env)
    body()
    AppEnvironment.popEnvironment()
  }

  // Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
  func withEnvironment(
    apiService: ServiceType = AppEnvironment.current.apiService,
    apiDelayInterval: DispatchTimeInterval = AppEnvironment.current.apiDelayInterval,
    application: UIApplicationType = UIApplication.shared,
    assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
    cache: KSCache = AppEnvironment.current.cache,
    calendar: Calendar = AppEnvironment.current.calendar,
    config: Config? = AppEnvironment.current.config,
    cookieStorage: HTTPCookieStorageProtocol = AppEnvironment.current.cookieStorage,
    countryCode: String = AppEnvironment.current.countryCode,
    currentUser: User? = AppEnvironment.current.currentUser,
    dateType: DateProtocol.Type = AppEnvironment.current.dateType,
    debounceInterval: DispatchTimeInterval = AppEnvironment.current.debounceInterval,
    device: UIDeviceType = AppEnvironment.current.device,
    facebookAppDelegate: FacebookAppDelegateProtocol = AppEnvironment.current.facebookAppDelegate,
    isOSVersionAvailable: @escaping (Double) -> Bool = AppEnvironment.current.isOSVersionAvailable,
    isVoiceOverRunning: @escaping () -> Bool = AppEnvironment.current.isVoiceOverRunning,
    koala: Koala = AppEnvironment.current.koala,
    language: Language = AppEnvironment.current.language,
    launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
    lightImpactFeedbackGenerator: UIImpactFeedbackGeneratorType = AppEnvironment.current.lightImpactFeedbackGenerator,
    locale: Locale = AppEnvironment.current.locale,
    mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
    notificationFeedbackGenerator: UINotificationFeedbackGeneratorType = AppEnvironment.current.notificationFeedbackGenerator,
    pushRegistrationType: PushRegistrationType.Type = AppEnvironment.current.pushRegistrationType,
    scheduler: DateScheduler = AppEnvironment.current.scheduler,
    selectionFeedbackGenerator: UISelectionFeedbackGeneratorType = AppEnvironment.current.selectionFeedbackGenerator,
    ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
    userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults,
    body: () -> Void
  ) {
    self.withEnvironment(
      Environment(
        apiService: apiService,
        apiDelayInterval: apiDelayInterval,
        application: application,
        assetImageGeneratorType: assetImageGeneratorType,
        cache: cache,
        calendar: calendar,
        config: config,
        cookieStorage: cookieStorage,
        countryCode: countryCode,
        currentUser: currentUser,
        dateType: dateType,
        debounceInterval: debounceInterval,
        device: device,
        facebookAppDelegate: facebookAppDelegate,
        isOSVersionAvailable: isOSVersionAvailable,
        isVoiceOverRunning: isVoiceOverRunning,
        koala: koala,
        language: language,
        launchedCountries: launchedCountries,
        lightImpactFeedbackGenerator: lightImpactFeedbackGenerator,
        locale: locale,
        mainBundle: mainBundle,
        notificationFeedbackGenerator: notificationFeedbackGenerator,
        pushRegistrationType: pushRegistrationType,
        scheduler: scheduler,
        selectionFeedbackGenerator: selectionFeedbackGenerator,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      ),
      body: body
    )
  }
}
