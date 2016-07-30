import AVFoundation
import Foundation
import HockeySDK
import KsApi
import ReactiveCocoa
import KsApi
import FBSDKCoreKit

/**
 A collection of **all** global variables and singletons that the app wants access to.
 */
public struct Environment {
  /// A type that exposes endpoints for fetching Kickstarter data.
  public let apiService: ServiceType

  /// The amount of time to delay API requests by. Used primarily for testing. Default value is `0.0`.
  public let apiDelayInterval: NSTimeInterval

  /// A type that exposes how to extract a still image from an AVAsset.
  public let assetImageGeneratorType: AssetImageGeneratorType.Type

  /// A type that stores a cached dictionary.
  public let cache: CacheProtocol

  /// The user's calendar.
  public let calendar: NSCalendar

  /// A type that holds configuration values we download from the server.
  public let config: Config?

  /// A type that exposes how to interact with cookie storage. Default value is
  /// `NSHTTPCookieStorage.sharedHTTPCookieStorage()`
  public let cookieStorage: NSHTTPCookieStorageType

  /// The user’s current country. This is valid whether the user is logged-in or not.
  public let countryCode: String

  /// The currently logged in user.
  public let currentUser: User?

  /// The amount of time to debounce signals by. Default value is `0.3`.
  public let debounceInterval: NSTimeInterval

  /// A delegate to handle Facebook initialization and incoming url requests
  public let facebookAppDelegate: FacebookAppDelegateProtocol

  /// A type that exposes how to initialize and start the Hockey manager. Default value is
  /// `BITHockeyManager.sharedHockeyManager()`.
  public let hockeyManager: HockeyManagerType

  /// A type that exposes endpoints for tracking various Kickstarter events.
  public let koala: Koala

  /// The user’s current language, which determines which localized strings bundle to load.
  public let language: Language

  /// The current set of launched countries for Kickstarter.
  public let launchedCountries: LaunchedCountries

  /// The user’s current locale, which determines how numbers are formatted. Default value is
  /// `NSLocale.currentLocale()`.
  public let locale: NSLocale

  /// A type that exposes how to interface with an NSBundle. Default value is `NSBundle.mainBundle()`.
  public let mainBundle: NSBundleType

  /// A scheduler to use for all time-based RAC operators. Default value is
  /// `QueueScheduler.mainQueueScheduler`.
  public let scheduler: DateSchedulerType

  /// The user’s timezone. Default value is `NSTimeZone.localTimeZone()`.
  public let timeZone: NSTimeZone

  /// A ubiquitous key-value store. Default value is `NSUbiquitousKeyValueStore.defaultStore()`.
  public let ubiquitousStore: KeyValueStoreType

  /// A user defaults key-value store. Default value is `NSUserDefaults.standardUserDefaults()`.
  public let userDefaults: KeyValueStoreType

  public init(
    apiService: ServiceType = Service(buildVersion: NSBundle.mainBundle().version),
    apiDelayInterval: NSTimeInterval = 0.0,
    assetImageGeneratorType: AssetImageGeneratorType.Type = AVAssetImageGenerator.self,
    cache: CacheProtocol = NSCache(),
    calendar: NSCalendar = NSCalendar.currentCalendar(),
    config: Config? = nil,
    cookieStorage: NSHTTPCookieStorageType = NSHTTPCookieStorage.sharedHTTPCookieStorage(),
    countryCode: String = "US",
    currentUser: User? = nil,
    debounceInterval: NSTimeInterval = 0.3,
    facebookAppDelegate: FacebookAppDelegateProtocol = FBSDKApplicationDelegate.sharedInstance(),
    hockeyManager: HockeyManagerType = BITHockeyManager.sharedHockeyManager(),
    koala: Koala = Koala(client: KoalaTrackingClient(endpoint: .Production)),
    language: Language = .en,
    launchedCountries: LaunchedCountries = .init(),
    locale: NSLocale = .currentLocale(),
    mainBundle: NSBundleType = NSBundle.mainBundle(),
    scheduler: DateSchedulerType = QueueScheduler.mainQueueScheduler,
    timeZone: NSTimeZone = .localTimeZone(),
    ubiquitousStore: KeyValueStoreType = NSUbiquitousKeyValueStore.defaultStore(),
    userDefaults: KeyValueStoreType = NSUserDefaults.standardUserDefaults()) {

    self.apiService = apiService
    self.apiDelayInterval = apiDelayInterval
    self.assetImageGeneratorType = assetImageGeneratorType
    self.cache = cache
    self.calendar = calendar
    self.config = config
    self.cookieStorage = cookieStorage
    self.countryCode = countryCode
    self.currentUser = currentUser
    self.debounceInterval = debounceInterval
    self.facebookAppDelegate = facebookAppDelegate
    self.hockeyManager = hockeyManager
    self.koala = koala
    self.language = language
    self.launchedCountries = launchedCountries
    self.locale = locale
    self.mainBundle = mainBundle
    self.scheduler = scheduler
    self.timeZone = timeZone
    self.ubiquitousStore = ubiquitousStore
    self.userDefaults = userDefaults
  }

  private var allGlobals: [Any] {
    return [
      self.apiService,
      self.apiDelayInterval,
      self.assetImageGeneratorType,
      self.cache,
      self.calendar,
      self.config,
      self.cookieStorage,
      self.countryCode,
      self.currentUser,
      self.debounceInterval,
      self.facebookAppDelegate,
      self.hockeyManager,
      self.koala,
      self.language,
      self.launchedCountries,
      self.locale,
      self.mainBundle,
      self.scheduler,
      self.timeZone,
      self.ubiquitousStore,
      self.userDefaults,
    ]
  }
}

extension Environment: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return self.allGlobals.map { "\($0.dynamicType)" }.reduce("", combine: +)
  }

  public var debugDescription: String {
    return self.description
  }
}
