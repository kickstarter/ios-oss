import Foundation
import KsApi
import ReactiveCocoa
import Result
import Models
import Argo

/**
 A global stack that captures the current state of global objects that the app wants access to.
 */
public struct AppEnvironment {

  internal static let environmentStorageKey = "com.kickstarter.AppEnvironment.current"
  internal static let oauthTokenStorageKey = "com.kickstarter.AppEnvironment.oauthToken"

  /**
   A global stack of environments.
   */
  private static var stack: [Environment] = [Environment()]

  /**
   Invoke when an access token has been acquired and you want to log the user in. Replaces the current
   environment with a new one that has the authenticated api service and current user model.

   - parameter envelope: An access token envelope with the api access token and user.
   */
  public static func login(envelope: AccessTokenEnvelope) {
    replaceCurrentEnvironment(
      apiService: AppEnvironment.current.apiService.login(OauthToken(token: envelope.accessToken)),
      currentUser: envelope.user
    )
  }

  /**
   Invoke when we have acquired a fresh current user and you want to replace the current environment's
   current user with the fresh one.

   - parameter user: A user model.
   */
  public static func updateCurrentUser(user: User) {
    replaceCurrentEnvironment(currentUser: user)
  }

  /**
   Invoke when you want to end the user's session.
   */
  public static func logout() {
    replaceCurrentEnvironment(
      apiService: AppEnvironment.current.apiService.logout(),
      currentUser: nil
    )
  }

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
    saveEnvironment(environment: env, ubiquitousStore: env.ubiquitousStore, userDefaults: env.userDefaults)
    stack.append(env)
  }

  /**
   Pop an environment off the stack.
   */
  public static func popEnvironment() -> Environment? {
    saveEnvironment(environment: current, ubiquitousStore: current.ubiquitousStore, userDefaults: current.userDefaults)
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
               userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults) {

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
        timeZone: timeZone,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
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
               userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults) {

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
        timeZone: timeZone,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      )
    )
  }

  /**
   Returns the last saved environment from user defaults.

   - parameter userDefaults:       A user defaults instance where the data is saved.
   - parameter ubiquitousStore: A ubiquitous store where an oauth token may be stored.

   - returns: An environment
   */
  public static func fromStorage(ubiquitousStore ubiquitousStore: KeyValueStoreType,
                                                    userDefaults: KeyValueStoreType) -> Environment {

    let data = userDefaults.dictionaryForKey(environmentStorageKey) ?? [:]

    var env: Environment = Environment()

    if let oauthToken = data["apiService.oauthToken.token"] as? String {
      // If there is an oauth token stored in the defaults, then we can authenticate our api service
      env = Environment(apiService: env.apiService.login(OauthToken(token: oauthToken)))
    } else if let oauthToken = ubiquitousStore.stringForKey(oauthTokenStorageKey) {
      // Otherwise if there is a token in the ubiquitous defaults we can use it
      env = Environment(apiService: env.apiService.login(OauthToken(token: oauthToken)))
    }

    // Try restoring the client id for the api service
    if let clientId = data["apiService.serverConfig.apiClientAuth.clientId"] as? String {
      env = Environment(
        apiService: Service(
          serverConfig: ServerConfig(
            apiBaseUrl: env.apiService.serverConfig.apiBaseUrl,
            webBaseUrl: env.apiService.serverConfig.webBaseUrl,
            apiClientAuth: ClientAuth(clientId: clientId),
            basicHTTPAuth: env.apiService.serverConfig.basicHTTPAuth
          ),
          oauthToken: env.apiService.oauthToken,
          language: env.apiService.language
        )
      )
    }

    // Try restoring the base urls for the api service
    if let apiBaseUrlString = data["apiService.serverConfig.apiBaseUrl"] as? String,
      apiBaseUrl = NSURL(string: apiBaseUrlString),
      webBaseUrlString = data["apiService.serverConfig.webBaseUrl"] as? String,
      webBaseUrl = NSURL(string: webBaseUrlString) {

      env = Environment(
        apiService: Service(
          serverConfig: ServerConfig(
            apiBaseUrl: apiBaseUrl,
            webBaseUrl: webBaseUrl,
            apiClientAuth: env.apiService.serverConfig.apiClientAuth,
            basicHTTPAuth: env.apiService.serverConfig.basicHTTPAuth
          ),
          oauthToken: env.apiService.oauthToken,
          language: env.apiService.language
        )
      )
    }

    // Try restoring the basic auth data for the api service
    if let username = data["apiService.serverConfig.basicHTTPAuth.username"] as? String,
      password = data["apiService.serverConfig.basicHTTPAuth.password"] as? String {

      env = Environment(
        apiService: Service(
          serverConfig: ServerConfig(
            apiBaseUrl: env.apiService.serverConfig.apiBaseUrl,
            webBaseUrl: env.apiService.serverConfig.webBaseUrl,
            apiClientAuth: env.apiService.serverConfig.apiClientAuth,
            basicHTTPAuth: BasicHTTPAuth(username: username, password: password)
          ),
          oauthToken: env.apiService.oauthToken,
          language: env.apiService.language
        )
      )
    }

    // Try restore the current user
    if let currentUserObject = data["currentUser"],
      currentUser = decode(currentUserObject) as User?
      where env.apiService.oauthToken != nil {
      env = Environment(apiService: env.apiService, currentUser: currentUser)
    }

    return env
  }

  /// Saves some key data for the current environment
  internal static func saveEnvironment(environment env: Environment = AppEnvironment.current,
                                                   ubiquitousStore: KeyValueStoreType,
                                                   userDefaults: KeyValueStoreType) {

    let data: [String:AnyObject?] = [
      "apiService.oauthToken.token": env.apiService.oauthToken?.token,
      "apiService.serverConfig.apiBaseUrl": env.apiService.serverConfig.apiBaseUrl.absoluteString,
      "apiService.serverConfig.apiClientAuth.clientId": env.apiService.serverConfig.apiClientAuth.clientId,
      "apiService.serverConfig.basicHTTPAuth.username": env.apiService.serverConfig.basicHTTPAuth?.username,
      "apiService.serverConfig.basicHTTPAuth.password": env.apiService.serverConfig.basicHTTPAuth?.password,
      "apiService.serverConfig.webBaseUrl": env.apiService.serverConfig.webBaseUrl.absoluteString,
      "apiService.language": env.apiService.language,
      "currentUser": env.currentUser?.encode()
    ]

    userDefaults.setObject(data.compact(), forKey: environmentStorageKey)
    userDefaults.synchronize()
    ubiquitousStore.setObject(env.apiService.oauthToken?.token, forKey: oauthTokenStorageKey)
    ubiquitousStore.synchronize()
  }
}
