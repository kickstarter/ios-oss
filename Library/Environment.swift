import AVFoundation
import CoreTelephony
import FBSDKCoreKit
import Foundation
import KsApi
import ReactiveSwift

/**
 A collection of **all** global variables and singletons that the app wants access to.
 */
public struct Environment {
  /// A type that exposes endpoints for fetching Kickstarter data.
  public let apiService: ServiceType

  /// The amount of time to delay API requests by. Used primarily for testing. Default value is `0.0`.
  public let apiDelayInterval: DispatchTimeInterval

  /// A type that exposes Apple Pay capabilities
  public let applePayCapabilities: ApplePayCapabilitiesType

  /// The app instance
  public let application: UIApplicationType

  /// A type that exposes how to extract a still image from an AVAsset.
  public let assetImageGeneratorType: AssetImageGeneratorType.Type

  /// A type that stores a cached dictionary.
  public let cache: KSCache

  /// The user's calendar.
  public let calendar: Calendar

  /// A type that holds configuration values we download from the server.
  public let config: Config?

  /// A type that exposes how to interact with cookie storage. Default value is `HTTPCookieStorage.shared`.
  public let cookieStorage: HTTPCookieStorageProtocol

  /// A type that provides telephony network info.
  public let coreTelephonyNetworkInfo: CoreTelephonyNetworkInfoType

  /// The user’s current country. This is valid whether the user is logged-in or not.
  public let countryCode: String

  /// The currently logged in user.
  public let currentUser: User?

  /// A type that exposes how to capture dates as measured from # of seconds since 1970.
  public let dateType: DateProtocol.Type

  /// The amount of time to debounce signals by. Default value is `0.3`.
  public let debounceInterval: DispatchTimeInterval

  /// Stored data used for debugging tools
  public let debugData: DebugData?

  /// The current device running the app.
  public let device: UIDeviceType

  /// Returns the current environment type
  public var environmentType: EnvironmentType {
    return self.apiService.serverConfig.environment
  }

  /// The environment variables
  public let environmentVariables: EnvironmentVariables

  /// A function that returns whether VoiceOver mode is running.
  public let isVoiceOverRunning: () -> Bool

  /// A type that exposes endpoints for tracking various Kickstarter events.
  public let ksrAnalytics: KSRAnalytics

  /// The user’s current language, which determines which localized strings bundle to load.
  public let language: Language

  /// The current set of launched countries for Kickstarter.
  public let launchedCountries: LaunchedCountries

  /// The user’s current locale, which determines how numbers are formatted. Default value is
  /// `Locale.current`.
  public let locale: Locale

  /// A type that exposes how to interface with an NSBundle. Default value is `Bundle.main`.
  public let mainBundle: NSBundleType

  /// The optimizely client
  public let optimizelyClient: OptimizelyClientType?

  /// A type that manages registration for push notifications.
  public let pushRegistrationType: PushRegistrationType.Type

  /// A reachability signal producer.
  public let reachability: SignalProducer<Reachability, Never>

  /// A scheduler to use for all time-based RAC operators. Default value is
  /// `QueueScheduler.mainQueueScheduler`.
  public let scheduler: DateScheduler

  /// A ubiquitous key-value store. Default value is `NSUbiquitousKeyValueStore.default`.
  public let ubiquitousStore: KeyValueStoreType

  /// A user defaults key-value store. Default value is `NSUserDefaults.standard`.
  public let userDefaults: KeyValueStoreType

  /// A type that can generated `UUID`s.
  public let uuidType: UUIDType.Type

  public init(
    apiService: ServiceType = Service(),
    apiDelayInterval: DispatchTimeInterval = .seconds(0),
    applePayCapabilities: ApplePayCapabilitiesType = ApplePayCapabilities(),
    application: UIApplicationType = UIApplication.shared,
    assetImageGeneratorType: AssetImageGeneratorType.Type = AVAssetImageGenerator.self,
    cache: KSCache = KSCache(),
    calendar: Calendar = .current,
    config: Config? = nil,
    cookieStorage: HTTPCookieStorageProtocol = HTTPCookieStorage.shared,
    coreTelephonyNetworkInfo: CoreTelephonyNetworkInfoType = CTTelephonyNetworkInfo.current(),
    countryCode: String = "US",
    currentUser: User? = nil,
    dateType: DateProtocol.Type = Date.self,
    debounceInterval: DispatchTimeInterval = .milliseconds(300),
    debugData: DebugData? = nil,
    device: UIDeviceType = UIDevice.current,
    environmentVariables: EnvironmentVariables = EnvironmentVariables(),
    isVoiceOverRunning: @escaping () -> Bool = { UIAccessibility.isVoiceOverRunning },
    ksrAnalytics: KSRAnalytics = KSRAnalytics(),
    language: Language = Language(languageStrings: Locale.preferredLanguages) ?? Language.en,
    launchedCountries: LaunchedCountries = .init(),
    locale: Locale = .current,
    mainBundle: NSBundleType = Bundle.main,
    optimizelyClient: OptimizelyClientType? = nil,
    pushRegistrationType: PushRegistrationType.Type = PushRegistration.self,
    reachability: SignalProducer<Reachability, Never> = Reachability.signalProducer,
    scheduler: DateScheduler = QueueScheduler.main,
    ubiquitousStore: KeyValueStoreType = NSUbiquitousKeyValueStore.default,
    userDefaults: KeyValueStoreType = UserDefaults.standard,
    uuidType: UUIDType.Type = UUID.self
  ) {
    self.apiService = apiService
    self.apiDelayInterval = apiDelayInterval
    self.applePayCapabilities = applePayCapabilities
    self.application = application
    self.assetImageGeneratorType = assetImageGeneratorType
    self.cache = cache
    self.calendar = calendar
    self.config = config
    self.cookieStorage = cookieStorage
    self.countryCode = countryCode
    self.coreTelephonyNetworkInfo = coreTelephonyNetworkInfo
    self.currentUser = currentUser
    self.dateType = dateType
    self.debounceInterval = debounceInterval
    self.debugData = debugData
    self.device = device
    self.environmentVariables = environmentVariables
    self.isVoiceOverRunning = isVoiceOverRunning
    self.ksrAnalytics = ksrAnalytics
    self.language = language
    self.launchedCountries = launchedCountries
    self.locale = locale
    self.mainBundle = mainBundle
    self.optimizelyClient = optimizelyClient
    self.pushRegistrationType = pushRegistrationType
    self.reachability = reachability
    self.scheduler = scheduler
    self.ubiquitousStore = ubiquitousStore
    self.userDefaults = userDefaults
    self.uuidType = uuidType
  }
}
