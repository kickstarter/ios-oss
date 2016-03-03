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
  public let currentUser: CurrentUserType
  public let language: Language
  public let locale: NSLocale
  public let timeZone: NSTimeZone
  public let countryCode: String
  public let launchedCountries: LaunchedCountries
  public let debounceScheduler: DateSchedulerType
  public let mainBundle: NSBundleType
  public let assetImageGeneratorType: AssetImageGeneratorType.Type
  public let hockeyManager: HockeyManagerType

  public init(
    apiService: ServiceType = Service.shared,
    currentUser: CurrentUserType = CurrentUser.shared,
    language: Language = .en,
    locale: NSLocale = .currentLocale(),
    timeZone: NSTimeZone = .localTimeZone(),
    countryCode: String = "US",
    launchedCountries: LaunchedCountries = .init(),
    debounceScheduler: DateSchedulerType = QueueScheduler.mainQueueScheduler,
    mainBundle: NSBundleType = NSBundle.mainBundle(),
    assetImageGeneratorType: AssetImageGeneratorType.Type = AVAssetImageGenerator.self,
    hockeyManager: HockeyManagerType = BITHockeyManager.sharedHockeyManager()) {

      self.apiService = apiService
      self.currentUser = currentUser
      self.language = language
      self.locale = locale
      self.timeZone = timeZone
      self.countryCode = countryCode
      self.launchedCountries = launchedCountries
      self.debounceScheduler = debounceScheduler
      self.mainBundle = mainBundle
      self.assetImageGeneratorType = assetImageGeneratorType
      self.hockeyManager = hockeyManager
  }
}

extension Environment : CustomStringConvertible, CustomDebugStringConvertible {

  public var description: String {
    return "(apiService: \(self.apiService), currentUser: \(self.currentUser), language: \(language), locale: \(self.locale.localeIdentifier), timeZone: \(self.timeZone), countryCode: \(self.countryCode), launchedCountries: \(self.launchedCountries))"
  }

  public var debugDescription: String {
    return self.description
  }
}
