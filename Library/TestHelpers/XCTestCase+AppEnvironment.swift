import Foundation
import KsApi
@testable import Library
import ReactiveSwift
import XCTest

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
    applePayCapabilities: ApplePayCapabilitiesType = AppEnvironment.current.applePayCapabilities,
    application: UIApplicationType = UIApplication.shared,
    appTrackingTransparency: AppTrackingTransparencyType = AppEnvironment.current.appTrackingTransparency,
    assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
    cache: KSCache = AppEnvironment.current.cache,
    calendar: Calendar = AppEnvironment.current.calendar,
    config: Config? = AppEnvironment.current.config,
    cookieStorage: HTTPCookieStorageProtocol = AppEnvironment.current.cookieStorage,
    coreTelephonyNetworkInfo: CoreTelephonyNetworkInfoType = AppEnvironment.current.coreTelephonyNetworkInfo,
    countryCode: String = AppEnvironment.current.countryCode,
    currentUser: User? = AppEnvironment.current.currentUser,
    currentUserEmail: String? = AppEnvironment.current.currentUserEmail,
    currentUserServerFeatures: Set<ServerFeature>? = AppEnvironment.current.currentUserServerFeatures,
    dateType: DateProtocol.Type = AppEnvironment.current.dateType,
    debounceInterval: DispatchTimeInterval = AppEnvironment.current.debounceInterval,
    device: UIDeviceType = AppEnvironment.current.device,
    isVoiceOverRunning: @escaping () -> Bool = AppEnvironment.current.isVoiceOverRunning,
    ksrAnalytics: KSRAnalytics = AppEnvironment.current.ksrAnalytics,
    language: Language = AppEnvironment.current.language,
    launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
    locale: Locale = AppEnvironment.current.locale,
    mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
    pushRegistrationType: PushRegistrationType.Type = AppEnvironment.current.pushRegistrationType,
    remoteConfigClient: RemoteConfigClientType? = AppEnvironment.current.remoteConfigClient,
    scheduler: DateScheduler = AppEnvironment.current.scheduler,
    ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
    userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults,
    uuidType: UUIDType.Type = AppEnvironment.current.uuidType,
    body: () -> Void
  ) {
    self.withEnvironment(
      Environment(
        apiService: apiService,
        apiDelayInterval: apiDelayInterval,
        applePayCapabilities: applePayCapabilities,
        application: application,
        appTrackingTransparency: appTrackingTransparency,
        assetImageGeneratorType: assetImageGeneratorType,
        cache: cache,
        calendar: calendar,
        config: config,
        cookieStorage: cookieStorage,
        coreTelephonyNetworkInfo: coreTelephonyNetworkInfo,
        countryCode: countryCode,
        currentUser: currentUser,
        currentUserEmail: currentUserEmail,
        currentUserServerFeatures: currentUserServerFeatures,
        dateType: dateType,
        debounceInterval: debounceInterval,
        device: device,
        isVoiceOverRunning: isVoiceOverRunning,
        ksrAnalytics: ksrAnalytics,
        language: language,
        launchedCountries: launchedCountries,
        locale: locale,
        mainBundle: mainBundle,
        pushRegistrationType: pushRegistrationType,
        remoteConfigClient: remoteConfigClient,
        scheduler: scheduler,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults,
        uuidType: uuidType
      ),
      body: body
    )
  }

  // MARK: Async

  // Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
  func withEnvironment(_ env: Environment, body: () async -> Void) async {
    AppEnvironment.pushEnvironment(env)
    await body()
    AppEnvironment.popEnvironment()
  }

  // Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
  func withEnvironment(
    apiService: ServiceType = AppEnvironment.current.apiService,
    apiDelayInterval: DispatchTimeInterval = AppEnvironment.current.apiDelayInterval,
    applePayCapabilities: ApplePayCapabilitiesType = AppEnvironment.current.applePayCapabilities,
    application: UIApplicationType = UIApplication.shared,
    appTrackingTransparency: AppTrackingTransparencyType = AppEnvironment.current.appTrackingTransparency,
    assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
    cache: KSCache = AppEnvironment.current.cache,
    calendar: Calendar = AppEnvironment.current.calendar,
    config: Config? = AppEnvironment.current.config,
    cookieStorage: HTTPCookieStorageProtocol = AppEnvironment.current.cookieStorage,
    coreTelephonyNetworkInfo: CoreTelephonyNetworkInfoType = AppEnvironment.current.coreTelephonyNetworkInfo,
    countryCode: String = AppEnvironment.current.countryCode,
    currentUser: User? = AppEnvironment.current.currentUser,
    currentUserEmail: String? = AppEnvironment.current.currentUserEmail,
    currentUserServerFeatures: Set<ServerFeature>? = AppEnvironment.current.currentUserServerFeatures,
    dateType: DateProtocol.Type = AppEnvironment.current.dateType,
    debounceInterval: DispatchTimeInterval = AppEnvironment.current.debounceInterval,
    device: UIDeviceType = AppEnvironment.current.device,
    isVoiceOverRunning: @escaping () -> Bool = AppEnvironment.current.isVoiceOverRunning,
    ksrAnalytics: KSRAnalytics = AppEnvironment.current.ksrAnalytics,
    language: Language = AppEnvironment.current.language,
    launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
    locale: Locale = AppEnvironment.current.locale,
    mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
    pushRegistrationType: PushRegistrationType.Type = AppEnvironment.current.pushRegistrationType,
    remoteConfigClient: RemoteConfigClientType? = AppEnvironment.current.remoteConfigClient,
    scheduler: DateScheduler = AppEnvironment.current.scheduler,
    ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
    userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults,
    uuidType: UUIDType.Type = AppEnvironment.current.uuidType,
    body: () async -> Void
  ) async {
    await self.withEnvironment(
      Environment(
        apiService: apiService,
        apiDelayInterval: apiDelayInterval,
        applePayCapabilities: applePayCapabilities,
        application: application,
        appTrackingTransparency: appTrackingTransparency,
        assetImageGeneratorType: assetImageGeneratorType,
        cache: cache,
        calendar: calendar,
        config: config,
        cookieStorage: cookieStorage,
        coreTelephonyNetworkInfo: coreTelephonyNetworkInfo,
        countryCode: countryCode,
        currentUser: currentUser,
        currentUserEmail: currentUserEmail,
        currentUserServerFeatures: currentUserServerFeatures,
        dateType: dateType,
        debounceInterval: debounceInterval,
        device: device,
        isVoiceOverRunning: isVoiceOverRunning,
        ksrAnalytics: ksrAnalytics,
        language: language,
        launchedCountries: launchedCountries,
        locale: locale,
        mainBundle: mainBundle,
        pushRegistrationType: pushRegistrationType,
        remoteConfigClient: remoteConfigClient,
        scheduler: scheduler,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults,
        uuidType: uuidType
      ),
      body: body
    )
  }
}
