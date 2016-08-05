import XCTest
@testable import Library
import AVFoundation
import Foundation
import KsApi
import ReactiveCocoa
import KsApi

extension XCTestCase {

  // Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
  func withEnvironment(env: Environment, @noescape body: () -> ()) {
    AppEnvironment.pushEnvironment(env)
    body()
    AppEnvironment.popEnvironment()
  }

  // Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
  func withEnvironment(
    apiService apiService: ServiceType = AppEnvironment.current.apiService,
               apiDelayInterval: NSTimeInterval = AppEnvironment.current.apiDelayInterval,
               // swiftlint:disable line_length
               assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
               // swiftlint:enable line_length
               cache: CacheProtocol = AppEnvironment.current.cache,
               calendar: NSCalendar = AppEnvironment.current.calendar,
               config: Config? = AppEnvironment.current.config,
               cookieStorage: NSHTTPCookieStorageType = AppEnvironment.current.cookieStorage,
               countryCode: String = AppEnvironment.current.countryCode,
               currentUser: User? = AppEnvironment.current.currentUser,
               debounceInterval: NSTimeInterval = AppEnvironment.current.debounceInterval,
               facebookAppDelegate: FacebookAppDelegateProtocol = AppEnvironment.current.facebookAppDelegate,
               hockeyManager: HockeyManagerType = AppEnvironment.current.hockeyManager,
               isVoiceOverRunning: () -> Bool = AppEnvironment.current.isVoiceOverRunning,
               koala: Koala = AppEnvironment.current.koala,
               language: Language = AppEnvironment.current.language,
               launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
               locale: NSLocale = AppEnvironment.current.locale,
               mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
               scheduler: DateSchedulerType = AppEnvironment.current.scheduler,
               timeZone: NSTimeZone = AppEnvironment.current.timeZone,
               ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
               userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults,
               @noescape body: () -> ()) {

    withEnvironment(
      Environment(
        apiService: apiService,
        apiDelayInterval: apiDelayInterval,
        assetImageGeneratorType: assetImageGeneratorType,
        cache: cache,
        calendar: calendar,
        config: config,
        cookieStorage: cookieStorage,
        countryCode: countryCode,
        currentUser: currentUser,
        debounceInterval: debounceInterval,
        facebookAppDelegate: facebookAppDelegate,
        hockeyManager: hockeyManager,
        isVoiceOverRunning: isVoiceOverRunning,
        koala: koala,
        language: language,
        launchedCountries: launchedCountries,
        locale: locale,
        mainBundle: mainBundle,
        scheduler: scheduler,
        timeZone: timeZone,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      ),
      body: body
    )
  }
}
