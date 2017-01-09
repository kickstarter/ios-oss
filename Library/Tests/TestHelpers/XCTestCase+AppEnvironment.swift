import XCTest
@testable import Library
import AVFoundation
import Foundation
import KsApi
import ReactiveSwift
import KsApi

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
    // swiftlint:disable line_length
    assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
    // swiftlint:enable line_length
    cache: KSCache = AppEnvironment.current.cache,
    calendar: Calendar = AppEnvironment.current.calendar,
    config: Config? = AppEnvironment.current.config,
    cookieStorage: HTTPCookieStorageProtocol = AppEnvironment.current.cookieStorage,
    countryCode: String = AppEnvironment.current.countryCode,
    currentUser: User? = AppEnvironment.current.currentUser,
    dateType: DateProtocol.Type = AppEnvironment.current.dateType,
    debounceInterval: DispatchTimeInterval = AppEnvironment.current.debounceInterval,
    facebookAppDelegate: FacebookAppDelegateProtocol = AppEnvironment.current.facebookAppDelegate,
    isVoiceOverRunning: @escaping () -> Bool = AppEnvironment.current.isVoiceOverRunning,
    koala: Koala = AppEnvironment.current.koala,
    language: Language = AppEnvironment.current.language,
    launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
    locale: Locale = AppEnvironment.current.locale,
    mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
    scheduler: DateSchedulerProtocol = AppEnvironment.current.scheduler,
    timeZone: TimeZone = AppEnvironment.current.timeZone,
    ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
    userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults,
    body: () -> Void) {

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
        dateType: dateType,
        debounceInterval: debounceInterval,
        facebookAppDelegate: facebookAppDelegate,
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
