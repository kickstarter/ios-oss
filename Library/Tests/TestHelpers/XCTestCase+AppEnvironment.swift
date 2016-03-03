import XCTest
@testable import Library
import AVFoundation
import class Foundation.NSLocale
import class Foundation.NSTimeZone
import protocol KsApi.ServiceType
import protocol ReactiveCocoa.DateSchedulerType

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
    currentUser: CurrentUserType = AppEnvironment.current.currentUser,
    language: Language = AppEnvironment.current.language,
    locale: NSLocale = AppEnvironment.current.locale,
    timeZone: NSTimeZone = AppEnvironment.current.timeZone,
    countryCode: String = AppEnvironment.current.countryCode,
    launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
    debounceScheduler: DateSchedulerType = AppEnvironment.current.debounceScheduler,
    mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
    assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
    hockeyManager: HockeyManagerType = AppEnvironment.current.hockeyManager,
    koala: Koala = AppEnvironment.current.koala,
    @noescape body: () -> ()) {

      withEnvironment(
        Environment(
          apiService: apiService,
          currentUser: currentUser,
          language: language,
          locale: locale,
          timeZone: timeZone,
          countryCode: countryCode,
          launchedCountries: launchedCountries,
          debounceScheduler: debounceScheduler,
          mainBundle: mainBundle,
          assetImageGeneratorType: assetImageGeneratorType,
          hockeyManager: hockeyManager,
          koala: koala
        ),
        body: body
      )
  }
}
