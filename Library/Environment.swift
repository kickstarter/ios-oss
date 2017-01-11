import AVFoundation
import Foundation
import KsApi
import LiveStream
import ReactiveSwift
import Result
import FBSDKCoreKit

/**
 A collection of **all** global variables and singletons that the app wants access to.
 */
public struct Environment {
  /// A type that exposes endpoints for fetching Kickstarter data.
  public let apiService: ServiceType

  /// The amount of time to delay API requests by. Used primarily for testing. Default value is `0.0`.
  public let apiDelayInterval: DispatchTimeInterval

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

  /// The user’s current country. This is valid whether the user is logged-in or not.
  public let countryCode: String

  /// The currently logged in user.
  public let currentUser: User?

  /// A type that exposes how to capture dates as measured from # of seconds since 1970.
  public let dateType: DateProtocol.Type

  /// The amount of time to debounce signals by. Default value is `0.3`.
  public let debounceInterval: DispatchTimeInterval

  /// A delegate to handle Facebook initialization and incoming url requests
  public let facebookAppDelegate: FacebookAppDelegateProtocol

  /// A function that returns whether voice over mode is running.
  public let isVoiceOverRunning: () -> Bool

  /// A type that exposes endpoints for tracking various Kickstarter events.
  public let koala: Koala

  /// The user’s current language, which determines which localized strings bundle to load.
  public let language: Language

  /// The current set of launched countries for Kickstarter.
  public let launchedCountries: LaunchedCountries

  /// The current service being used for live stream requests.
  public let liveStreamService: LiveStreamServiceProtocol

  /// The user’s current locale, which determines how numbers are formatted. Default value is
  /// `Locale.current`.
  public let locale: Locale

  /// A type that exposes how to interface with an NSBundle. Default value is `Bundle.main`.
  public let mainBundle: NSBundleType

  /// A reachability signal producer.
  public let reachability: SignalProducer<Reachability, NoError>

  /// A scheduler to use for all time-based RAC operators. Default value is
  /// `QueueScheduler.mainQueueScheduler`.
  public let scheduler: DateSchedulerProtocol

  /// The user’s timezone. Default value is `TimeZone.local`.
  public let timeZone: TimeZone

  /// A ubiquitous key-value store. Default value is `NSUbiquitousKeyValueStore.default`.
  public let ubiquitousStore: KeyValueStoreType

  /// A user defaults key-value store. Default value is `NSUserDefaults.standard`.
  public let userDefaults: KeyValueStoreType

  public init(
    apiService: ServiceType = Service(),
    apiDelayInterval: DispatchTimeInterval = .seconds(0),
    assetImageGeneratorType: AssetImageGeneratorType.Type = AVAssetImageGenerator.self,
    cache: KSCache = KSCache(),
    calendar: Calendar = .current,
    config: Config? = nil,
    cookieStorage: HTTPCookieStorageProtocol = HTTPCookieStorage.shared,
    countryCode: String = "US",
    currentUser: User? = nil,
    dateType: DateProtocol.Type = Date.self,
    debounceInterval: DispatchTimeInterval = .milliseconds(300),
    facebookAppDelegate: FacebookAppDelegateProtocol = FBSDKApplicationDelegate.sharedInstance(),
    isVoiceOverRunning: @escaping () -> Bool = UIAccessibilityIsVoiceOverRunning,
    koala: Koala = Koala(client: KoalaTrackingClient(endpoint: .production)),
    language: Language = Language(languageStrings: Locale.preferredLanguages) ?? Language.en,
    launchedCountries: LaunchedCountries = .init(),
    liveStreamService: LiveStreamServiceProtocol = LiveStreamService(),
    locale: Locale = .current,
    mainBundle: NSBundleType = Bundle.main,
    reachability: SignalProducer<Reachability, NoError> = Reachability.signalProducer,
    scheduler: DateSchedulerProtocol = QueueScheduler.main,
    timeZone: TimeZone = .current,
    ubiquitousStore: KeyValueStoreType = NSUbiquitousKeyValueStore.default(),
    userDefaults: KeyValueStoreType = UserDefaults.standard) {

    self.apiService = apiService
    self.apiDelayInterval = apiDelayInterval
    self.assetImageGeneratorType = assetImageGeneratorType
    self.cache = cache
    self.calendar = calendar
    self.config = config
    self.cookieStorage = cookieStorage
    self.countryCode = countryCode
    self.currentUser = currentUser
    self.dateType = dateType
    self.debounceInterval = debounceInterval
    self.facebookAppDelegate = facebookAppDelegate
    self.isVoiceOverRunning = isVoiceOverRunning
    self.koala = koala
    self.language = language
    self.launchedCountries = launchedCountries
    self.liveStreamService = liveStreamService
    self.locale = locale
    self.mainBundle = mainBundle
    self.reachability = reachability
    self.scheduler = scheduler
    self.timeZone = timeZone
    self.ubiquitousStore = ubiquitousStore
    self.userDefaults = userDefaults
  }
}
