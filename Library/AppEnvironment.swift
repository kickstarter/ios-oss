import class Foundation.NSLocale
import struct Foundation.NSTimeInterval
import class Foundation.NSTimeZone
import protocol KsApi.ServiceType
import protocol ReactiveCocoa.DateSchedulerType

/**
 A global stack that captures the current state of global objects that the app wants access to.
 */
public struct AppEnvironment {
  /**
   A global stack of environments.
   */
  private static var stack: [Environment] = [Environment()]

  /**
   The most recent environment on the stack.
   */
  public static var current: Environment! {
    return stack.last
  }

  /**
   Push a new environment onto the stack.
   */
  public static func pushEnvironment(env: Environment) {
    stack.append(env)
  }

  /**
   Pop an environment off the stack.
   */
  public static func popEnvironment() -> Environment? {
    return stack.popLast()
  }

  /**
   Replace the current environment with a new environment.
   */
  public static func replaceCurrentEnvironment(env: Environment) {
    popEnvironment()
    pushEnvironment(env)
  }

  /**
   Pushes a new environment onto the stack that changes only a subset of the current global dependencies.
   */
  public static func pushEnvironment(
    apiService apiService: ServiceType = AppEnvironment.current.apiService,
               apiThrottleInterval: NSTimeInterval = AppEnvironment.current.apiThrottleInterval,
               assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
               countryCode: String = AppEnvironment.current.countryCode,
               currentUser: CurrentUserType = AppEnvironment.current.currentUser,
               debounceInterval: NSTimeInterval = AppEnvironment.current.debounceInterval,
               hockeyManager: HockeyManagerType = AppEnvironment.current.hockeyManager,
               koala: Koala = AppEnvironment.current.koala,
               language: Language = AppEnvironment.current.language,
               launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
               locale: NSLocale = AppEnvironment.current.locale,
               mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
               scheduler: DateSchedulerType = AppEnvironment.current.scheduler,
               timeZone: NSTimeZone = AppEnvironment.current.timeZone) {

    pushEnvironment(
      Environment(
        apiService: apiService,
        apiThrottleInterval: apiThrottleInterval,
        assetImageGeneratorType: assetImageGeneratorType,
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
        timeZone: timeZone
      )
    )
  }

  /**
   Replaces the current environment onto the stack with an environment that changes only a subset
   of current global dependencies.
   */
  public static func replaceCurrentEnvironment(
    apiService apiService: ServiceType = AppEnvironment.current.apiService,
               apiThrottleInterval: NSTimeInterval = AppEnvironment.current.apiThrottleInterval,
               assetImageGeneratorType: AssetImageGeneratorType.Type = AppEnvironment.current.assetImageGeneratorType,
               countryCode: String = AppEnvironment.current.countryCode,
               currentUser: CurrentUserType = AppEnvironment.current.currentUser,
               debounceInterval: NSTimeInterval = AppEnvironment.current.debounceInterval,
               hockeyManager: HockeyManagerType = AppEnvironment.current.hockeyManager,
               koala: Koala = AppEnvironment.current.koala,
               language: Language = AppEnvironment.current.language,
               launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
               locale: NSLocale = AppEnvironment.current.locale,
               mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
               scheduler: DateSchedulerType = AppEnvironment.current.scheduler,
               timeZone: NSTimeZone = AppEnvironment.current.timeZone) {

    replaceCurrentEnvironment(
      Environment(
        apiService: apiService,
        apiThrottleInterval: apiThrottleInterval,
        assetImageGeneratorType: assetImageGeneratorType,
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
        timeZone: timeZone
      )
    )
  }
}
