import XCTest
@testable import Kickstarter_tvOS
import AVFoundation
import class Foundation.NSLocale
import class Foundation.NSTimeZone
import protocol Library.HockeyManagerType
import protocol KsApi.ServiceType
import protocol ReactiveCocoa.DateSchedulerType
import struct Library.Environment
import struct Library.AppEnvironment
import protocol Library.CurrentUserType
import enum Library.Language
import struct Library.LaunchedCountries
import protocol Library.NSBundleType
import protocol Library.AssetImageGeneratorType
import class Library.Koala

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
    assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
    countryCode: String = AppEnvironment.current.countryCode,
    currentUser: CurrentUserType = AppEnvironment.current.currentUser,
    hockeyManager: HockeyManagerType = AppEnvironment.current.hockeyManager,
    koala: Koala = AppEnvironment.current.koala,
    language: Language = AppEnvironment.current.language,
    launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
    locale: NSLocale = AppEnvironment.current.locale,
    mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
    scheduler: DateSchedulerType = AppEnvironment.current.scheduler,
    timeZone: NSTimeZone = AppEnvironment.current.timeZone,
    @noescape body: () -> ()) {

      withEnvironment(
        Environment(
          apiService: apiService,
          assetImageGeneratorType: assetImageGeneratorType,
          countryCode: countryCode,
          currentUser: currentUser,
          hockeyManager: hockeyManager,
          koala: koala,
          language: language,
          launchedCountries: launchedCountries,
          locale: locale,
          mainBundle: mainBundle,
          scheduler: scheduler,
          timeZone: timeZone
        ),
        body: body
      )
  }
}
