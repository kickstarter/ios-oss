import Argo
import FBSDKCoreKit
import Foundation
import KsApi
import Prelude
import ReactiveCocoa
import Result

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
      apiService: current.apiService.login(OauthToken(token: envelope.accessToken)),
      currentUser: envelope.user,
      koala: current.koala |> Koala.lens.loggedInUser .~ envelope.user
    )
  }

  /**
   Invoke when we have acquired a fresh current user and you want to replace the current environment's
   current user with the fresh one.

   - parameter user: A user model.
   */
  public static func updateCurrentUser(user: User) {
    replaceCurrentEnvironment(
      currentUser: user,
      koala: current.koala |> Koala.lens.loggedInUser .~ user
    )
  }

  // Invoke when you want to end the user's session.
  public static func logout() {
    replaceCurrentEnvironment(
      apiService: AppEnvironment.current.apiService.logout(),
      currentUser: nil,
      koala: current.koala |> Koala.lens.loggedInUser .~ nil
    )
  }

  // The most recent environment on the stack.
  public static var current: Environment! {
    return stack.last
  }

  // Push a new environment onto the stack.
  public static func pushEnvironment(env: Environment) {
    saveEnvironment(environment: env, ubiquitousStore: env.ubiquitousStore, userDefaults: env.userDefaults)
    stack.append(env)
  }

  // Pop an environment off the stack.
  public static func popEnvironment() -> Environment? {
    let last = stack.popLast()
    let next = current ?? Environment()
    saveEnvironment(environment: next,
                    ubiquitousStore: next.ubiquitousStore,
                    userDefaults: next.userDefaults)
    return last
  }

  // Replace the current environment with a new environment.
  public static func replaceCurrentEnvironment(env: Environment) {
    popEnvironment()
    pushEnvironment(env)
  }

  // Pushes a new environment onto the stack that changes only a subset of the current global dependencies.
  public static func pushEnvironment(
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
               koala: Koala = AppEnvironment.current.koala,
               language: Language = AppEnvironment.current.language,
               launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
               locale: NSLocale = AppEnvironment.current.locale,
               mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
               reachability: SignalProducer<Reachability, NoError> = AppEnvironment.current.reachability,
               scheduler: DateSchedulerType = AppEnvironment.current.scheduler,
               timeZone: NSTimeZone = AppEnvironment.current.timeZone,
               ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
               userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults) {

    pushEnvironment(
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
        koala: koala,
        language: language,
        launchedCountries: launchedCountries,
        locale: locale,
        mainBundle: mainBundle,
        reachability: reachability,
        scheduler: scheduler,
        timeZone: timeZone,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      )
    )
  }

  // Replaces the current environment onto the stack with an environment that changes only a subset
  // of current global dependencies.
  public static func replaceCurrentEnvironment(
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
               koala: Koala = AppEnvironment.current.koala,
               language: Language = AppEnvironment.current.language,
               launchedCountries: LaunchedCountries = AppEnvironment.current.launchedCountries,
               locale: NSLocale = AppEnvironment.current.locale,
               mainBundle: NSBundleType = AppEnvironment.current.mainBundle,
               reachability: SignalProducer<Reachability, NoError> = AppEnvironment.current.reachability,
               scheduler: DateSchedulerType = AppEnvironment.current.scheduler,
               timeZone: NSTimeZone = AppEnvironment.current.timeZone,
               ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore,
               userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults) {

    replaceCurrentEnvironment(
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
        koala: koala,
        language: language,
        launchedCountries: launchedCountries,
        locale: locale,
        mainBundle: mainBundle,
        reachability: reachability,
        scheduler: scheduler,
        timeZone: timeZone,
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      )
    )
  }

  // Returns the last saved environment from user defaults.
  // swiftlint:disable function_body_length
  public static func fromStorage(ubiquitousStore ubiquitousStore: KeyValueStoreType,
                                                    userDefaults: KeyValueStoreType) -> Environment {

    let data = userDefaults.dictionaryForKey(environmentStorageKey) ?? [:]

    var service = AppEnvironment.current.apiService
    var currentUser: User? = nil
    let config: Config? = data["config"].flatMap(decode)

    if let oauthToken = data["apiService.oauthToken.token"] as? String {
      // If there is an oauth token stored in the defaults, then we can authenticate our api service
      service = service.login(OauthToken(token: oauthToken))
    } else if let oauthToken = ubiquitousStore.stringForKey(oauthTokenStorageKey) {
      // Otherwise if there is a token in the ubiquitous defaults we can use it
      service = service.login(OauthToken(token: oauthToken))
    }

    // Try restoring the client id for the api service
    if let clientId = data["apiService.serverConfig.apiClientAuth.clientId"] as? String {
      service = Service(
        serverConfig: ServerConfig(
          apiBaseUrl: service.serverConfig.apiBaseUrl,
          webBaseUrl: service.serverConfig.webBaseUrl,
          apiClientAuth: ClientAuth(clientId: clientId),
          basicHTTPAuth: service.serverConfig.basicHTTPAuth
        ),
        oauthToken: service.oauthToken,
        language: service.language,
        buildVersion: service.buildVersion
      )
    }

    // Try restoring the base urls for the api service
    if let apiBaseUrlString = data["apiService.serverConfig.apiBaseUrl"] as? String,
      apiBaseUrl = NSURL(string: apiBaseUrlString),
      webBaseUrlString = data["apiService.serverConfig.webBaseUrl"] as? String,
      webBaseUrl = NSURL(string: webBaseUrlString) {

      service = Service(
        serverConfig: ServerConfig(
          apiBaseUrl: apiBaseUrl,
          webBaseUrl: webBaseUrl,
          apiClientAuth: service.serverConfig.apiClientAuth,
          basicHTTPAuth: service.serverConfig.basicHTTPAuth
        ),
        oauthToken: service.oauthToken,
        language: service.language,
        buildVersion: service.buildVersion
      )
    }

    // Try restoring the basic auth data for the api service
    if let username = data["apiService.serverConfig.basicHTTPAuth.username"] as? String,
      password = data["apiService.serverConfig.basicHTTPAuth.password"] as? String {

      service = Service(
        serverConfig: ServerConfig(
          apiBaseUrl: service.serverConfig.apiBaseUrl,
          webBaseUrl: service.serverConfig.webBaseUrl,
          apiClientAuth: service.serverConfig.apiClientAuth,
          basicHTTPAuth: BasicHTTPAuth(username: username, password: password)
        ),
        oauthToken: service.oauthToken,
        language: service.language,
        buildVersion: service.buildVersion
      )
    }

    // Try restore the current user
    if service.oauthToken != nil {
      currentUser = data["currentUser"].flatMap(decode)
    }

    return Environment(apiService: service, config: config, currentUser: currentUser)
  }
  // swiftlint:enable function_body_length

  // Saves some key data for the current environment
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
      "config": env.config?.encode(),
      "currentUser": env.currentUser?.encode()
    ]

    userDefaults.setObject(data.compact(), forKey: environmentStorageKey)
    ubiquitousStore.setObject(env.apiService.oauthToken?.token, forKey: oauthTokenStorageKey)
  }
}
