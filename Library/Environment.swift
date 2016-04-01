import AVFoundation
import class Foundation.NSBundle
import class Foundation.NSLocale
import class Foundation.NSTimeZone
import class HockeySDK.BITHockeyManager
import struct KsApi.Service
import protocol KsApi.ServiceType
import protocol ReactiveCocoa.DateSchedulerType
import class ReactiveCocoa.QueueScheduler

/**
 A collection of **all** global variables and singletons that the app wants access to.
 */
public struct Environment {
  public let apiService: ServiceType
  public let apiThrottleInterval: NSTimeInterval
  public let assetImageGeneratorType: AssetImageGeneratorType.Type
  public let countryCode: String
  public let currentUser: CurrentUserType
  public let debounceInterval: NSTimeInterval
  public let hockeyManager: HockeyManagerType
  public let koala: Koala
  public let language: Language
  public let launchedCountries: LaunchedCountries
  public let locale: NSLocale
  public let mainBundle: NSBundleType
  public let scheduler: DateSchedulerType
  public let timeZone: NSTimeZone

  public init(
    apiService: ServiceType = Service.shared,
    apiThrottleInterval: NSTimeInterval = 0.0,
    assetImageGeneratorType: AssetImageGeneratorType.Type = AVAssetImageGenerator.self,
    countryCode: String = "US",
    currentUser: CurrentUserType = CurrentUser.shared,
    debounceInterval: NSTimeInterval = 0.3,
    hockeyManager: HockeyManagerType = BITHockeyManager.sharedHockeyManager(),
    koala: Koala = Koala(client: KoalaTrackingClient(endpoint: .Production)),
    language: Language = .en,
    launchedCountries: LaunchedCountries = .init(),
    locale: NSLocale = .currentLocale(),
    mainBundle: NSBundleType = NSBundle.mainBundle(),
    scheduler: DateSchedulerType = QueueScheduler.mainQueueScheduler,
    timeZone: NSTimeZone = .localTimeZone()) {

    self.apiService = apiService
    self.apiThrottleInterval = apiThrottleInterval
    self.assetImageGeneratorType = assetImageGeneratorType
    self.countryCode = countryCode
    self.currentUser = currentUser
    self.debounceInterval = debounceInterval
    self.hockeyManager = hockeyManager
    self.koala = koala
    self.language = language
    self.launchedCountries = launchedCountries
    self.locale = locale
    self.mainBundle = mainBundle
    self.scheduler = scheduler
    self.timeZone = timeZone
  }

  private var allGlobals: [Any] {
    return [
      self.apiService,
      self.apiThrottleInterval,
      self.assetImageGeneratorType,
      self.countryCode,
      self.currentUser,
      self.debounceInterval,
      self.hockeyManager,
      self.koala,
      self.language,
      self.launchedCountries,
      self.locale,
      self.mainBundle,
      self.scheduler,
      self.timeZone
    ]
  }
}

extension Environment : CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return self.allGlobals.map { "\($0.dynamicType)" }.reduce("", combine: +)
  }

  public var debugDescription: String {
    return self.description
  }
}
