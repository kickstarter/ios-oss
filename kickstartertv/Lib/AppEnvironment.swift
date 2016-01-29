import Foundation
import KsApi

/**
 A global stack that captures the current state of global objects that the app wants access to.
*/
struct AppEnvironment {
  /**
   A global stack of environments.
  */
  private static var stack: [Environment] = [Environment()]

  /**
   The most recent environment on the stack.
  */
  static var current: Environment! {
    return stack.last
  }

  /**
   Push a new environment onto the stack.
  */
  static func pushEnvironment(env: Environment) {
    stack.append(env)
  }

  /**
   Pop an environment off the stack.
  */
  static func popEnvironment() -> Environment? {
    return stack.popLast()
  }

  /**
   Replace the current environment with a new environment.
  */
  static func replaceCurrentEnvironment(env: Environment) {
    popEnvironment()
    pushEnvironment(env)
  }

  /**
   Pushes a new environment onto the stack that changes only a subset of the current global dependencies.
  */
  static func pushEnvironment(
    apiService apiService: ServiceType = AppEnvironment.current.apiService,
    currentUser: CurrentUserType = AppEnvironment.current.currentUser,
    language: Language = AppEnvironment.current.language,
    locale: NSLocale = AppEnvironment.current.locale,
    timeZone: NSTimeZone = AppEnvironment.current.timeZone,
    countryCode: String = AppEnvironment.current.countryCode,
    launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries) {

      stack.append(
        Environment(
          apiService: apiService,
          currentUser: currentUser,
          language: language,
          locale: locale,
          timeZone: timeZone,
          countryCode: countryCode,
          launchedCountries: launchedCountries
        )
      )
  }

  /**
   Replaces the current environment onto the stack with an environment that changes only a subset
   of current global dependencies.
  */
  static func replaceCurrentEnvironment(
    apiService apiService: ServiceType = AppEnvironment.current.apiService,
    currentUser: CurrentUserType = AppEnvironment.current.currentUser,
    language: Language = AppEnvironment.current.language,
    locale: NSLocale = AppEnvironment.current.locale,
    timeZone: NSTimeZone = AppEnvironment.current.timeZone,
    countryCode: String = AppEnvironment.current.countryCode,
    launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries) {

      replaceCurrentEnvironment(
        Environment(
          apiService: apiService,
          currentUser: currentUser,
          language: language,
          locale: locale,
          timeZone: timeZone,
          countryCode: countryCode,
          launchedCountries: launchedCountries
        )
      )
  }
}
