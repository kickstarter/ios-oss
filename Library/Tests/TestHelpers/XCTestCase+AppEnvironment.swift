import XCTest
@testable import Library
import AVFoundation
import Foundation
import KsApi
import ReactiveCocoa
import Models

extension XCTestCase {

  /**
   Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
   */
  func withEnvironment(env: Environment, @noescape body: () -> ()) {
    AppEnvironment.pushEnvironment(env)
    body()
    AppEnvironment.popEnvironment()
  }

  /**
   Pushes an environment onto the stack, executes a closure, and then pops the environment from the stack.
   */
  func withEnvironment(
    apiService apiService: ServiceType = AppEnvironment.current.apiService,
               apiThrottleInterval: NSTimeInterval = AppEnvironment.current.apiThrottleInterval,
               assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
               cookieStorage: NSHTTPCookieStorageType = AppEnvironment.current.cookieStorage,
               countryCode: String = AppEnvironment.current.countryCode,
               currentUser: User? = AppEnvironment.current.currentUser,
               debounceInterval: NSTimeInterval = AppEnvironment.current.debounceInterval,
               hockeyManager: HockeyManagerType = AppEnvironment.current.hockeyManager,
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
        apiThrottleInterval: apiThrottleInterval,
        assetImageGeneratorType: assetImageGeneratorType,
        cookieStorage: cookieStorage,
        countryCode: countryCode,
        currentUser: currentUser,
        debounceInterval: debounceInterval,
        hockeyManager: hockeyManager,
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
