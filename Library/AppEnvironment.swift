import class Foundation.NSLocale
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
    koala: Koala = AppEnvironment.current.koala) {

      stack.append(
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
        )
      )
  }

  /**
   Replaces the current environment onto the stack with an environment that changes only a subset
   of current global dependencies.
  */
  public static func replaceCurrentEnvironment(
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
    koala: Koala = AppEnvironment.current.koala) {

      replaceCurrentEnvironment(
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
        )
      )
  }
}
