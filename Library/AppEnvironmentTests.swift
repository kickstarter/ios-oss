import Foundation
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class AppEnvironmentTests: XCTestCase {
  func testPushAndPopEnvironment() {
    let lang = AppEnvironment.current.language

    AppEnvironment.pushEnvironment()
    XCTAssertEqual(lang, AppEnvironment.current.language)

    AppEnvironment.pushEnvironment(language: .es)
    XCTAssertEqual(Language.es, AppEnvironment.current.language)

    AppEnvironment.pushEnvironment(Environment(language: .en))
    XCTAssertEqual(Language.en, AppEnvironment.current.language)

    AppEnvironment.popEnvironment()
    XCTAssertEqual(Language.es, AppEnvironment.current.language)

    AppEnvironment.popEnvironment()
    XCTAssertEqual(lang, AppEnvironment.current.language)

    AppEnvironment.popEnvironment()
  }

  func testReplaceCurrentEnvironment() {
    AppEnvironment.pushEnvironment(language: .es)
    XCTAssertEqual(AppEnvironment.current.language, Language.es)

    AppEnvironment.pushEnvironment(language: .fr)
    XCTAssertEqual(AppEnvironment.current.language, Language.fr)

    AppEnvironment.replaceCurrentEnvironment(language: Language.de)
    XCTAssertEqual(AppEnvironment.current.language, Language.de)

    AppEnvironment.popEnvironment()
    XCTAssertEqual(AppEnvironment.current.language, Language.es)

    AppEnvironment.popEnvironment()
  }

  func testPersistenceKey() {
    XCTAssertEqual(
      "com.kickstarter.AppEnvironment.current", AppEnvironment.environmentStorageKey,
      "Failing this test means users will get logged out, so you better have a good reason."
    )
    XCTAssertEqual(
      "com.kickstarter.AppEnvironment.oauthToken", AppEnvironment.oauthTokenStorageKey,
      "Failing this means user's token will be lost, so you better have a good reason."
    )
  }

  func testUserSession() {
    AppEnvironment.pushEnvironment()

    XCTAssertNil(AppEnvironment.current.apiService.oauthToken)
    XCTAssertNil(AppEnvironment.current.currentUser)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

    XCTAssertEqual("deadbeef", AppEnvironment.current.apiService.oauthToken?.token)
    XCTAssertEqual(User.template, AppEnvironment.current.currentUser)

    AppEnvironment.updateCurrentUser(User.template)

    XCTAssertEqual("deadbeef", AppEnvironment.current.apiService.oauthToken?.token)
    XCTAssertEqual(User.template, AppEnvironment.current.currentUser)

    AppEnvironment.logout()

    XCTAssertNil(AppEnvironment.current.apiService.oauthToken)
    XCTAssertNil(AppEnvironment.current.currentUser)

    AppEnvironment.popEnvironment()
  }

  func testFromStorage_WithNothingStored() {
    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()
    let env = AppEnvironment.fromStorage(ubiquitousStore: ubiquitousStore, userDefaults: userDefaults)

    XCTAssertNil(env.apiService.oauthToken?.token)
    XCTAssertEqual(nil, env.currentUser)
  }

  func testFromStorage_WithFullDataStored() {
    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()
    let user = User.template

    userDefaults.set(
      [
        "apiService.oauthToken.token": "deadbeef",
        "apiService.serverConfig.apiBaseUrl": "http://api.ksr.com",
        "apiService.serverConfig.apiClientAuth.clientId": "cafebeef",
        "apiService.serverConfig.basicHTTPAuth.username": "hola",
        "apiService.serverConfig.basicHTTPAuth.password": "mundo",
        "apiService.serverConfig.webBaseUrl": "http://ksr.com",
        "apiService.language": "en",
        "currentUser": user.encode()
      ],
      forKey: AppEnvironment.environmentStorageKey
    )

    let env = AppEnvironment.fromStorage(ubiquitousStore: ubiquitousStore, userDefaults: userDefaults)

    XCTAssertEqual("deadbeef", env.apiService.oauthToken?.token)
    XCTAssertEqual("http://api.ksr.com", env.apiService.serverConfig.apiBaseUrl.absoluteString)
    XCTAssertEqual("cafebeef", env.apiService.serverConfig.apiClientAuth.clientId)
    XCTAssertEqual("hola", env.apiService.serverConfig.basicHTTPAuth?.username)
    XCTAssertEqual("mundo", env.apiService.serverConfig.basicHTTPAuth?.password)
    XCTAssertEqual("http://ksr.com", env.apiService.serverConfig.webBaseUrl.absoluteString)
    XCTAssertEqual(user, env.currentUser)
    XCTAssertEqual(user, env.koala.loggedInUser)

    let differentEnv = AppEnvironment.fromStorage(
      ubiquitousStore: MockKeyValueStore(),
      userDefaults: MockKeyValueStore()
    )
    XCTAssertNil(differentEnv.apiService.oauthToken?.token)
    XCTAssertEqual(nil, differentEnv.currentUser)
  }

  func testFromStorage_LegacyUserDefaults() {
    let userDefaults = MockKeyValueStore()
    userDefaults.set("deadbeef", forKey: "com.kickstarter.access_token")
    let env = AppEnvironment.fromStorage(ubiquitousStore: MockKeyValueStore(), userDefaults: userDefaults)

    XCTAssertEqual("deadbeef", env.apiService.oauthToken?.token)
    XCTAssertTrue(env.apiService.isAuthenticated)
    XCTAssertNil(userDefaults.object(forKey: "com.kickstarter.access_token"))
  }

  func testSaveEnvironment() {
    let apiService = MockService(
      serverConfig: ServerConfig(
        apiBaseUrl: URL(string: "http://api.ksr.com")!,
        webBaseUrl: URL(string: "http://ksr.com")!,
        apiClientAuth: ClientAuth(clientId: "cafebeef"),
        basicHTTPAuth: nil,
        graphQLEndpointUrl: URL(string: "http://ksr.dev/graph")!
      ),
      oauthToken: OauthToken(token: "deadbeef")
    )
    let currentUser = User.template
    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    AppEnvironment.saveEnvironment(
      environment: Environment(apiService: apiService, currentUser: currentUser),
      ubiquitousStore: ubiquitousStore,
      userDefaults: userDefaults
    )

    let result = userDefaults.dictionary(forKey: AppEnvironment.environmentStorageKey)!

    XCTAssertEqual("deadbeef", result["apiService.oauthToken.token"] as? String)
    XCTAssertEqual("http://api.ksr.com", result["apiService.serverConfig.apiBaseUrl"] as? String)
    XCTAssertEqual("cafebeef", result["apiService.serverConfig.apiClientAuth.clientId"] as? String)
    XCTAssertEqual("http://ksr.com", result["apiService.serverConfig.webBaseUrl"] as? String)
    XCTAssertEqual("en", result["apiService.language"] as? String)
    XCTAssertEqual(User.template.id, (result["currentUser"] as? [String: AnyObject])?["id"] as? Int)

    XCTAssertEqual(
      nil, ubiquitousStore.string(forKey: AppEnvironment.oauthTokenStorageKey),
      "No token stored."
    )
  }

  func testRestoreFromEnvironment() {
    let apiService = MockService(
      serverConfig: ServerConfig.production,
      oauthToken: OauthToken(token: "deadbeef")
    )

    let currentUser = User.template
    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    AppEnvironment.saveEnvironment(
      environment: Environment(apiService: apiService, currentUser: currentUser),
      ubiquitousStore: ubiquitousStore,
      userDefaults: userDefaults
    )

    let env = AppEnvironment.fromStorage(ubiquitousStore: ubiquitousStore, userDefaults: userDefaults)

    XCTAssertEqual("deadbeef", env.apiService.oauthToken?.token)
    XCTAssertEqual(
      ServerConfig.production.apiBaseUrl.absoluteString,
      env.apiService.serverConfig.apiBaseUrl.absoluteString
    )
    XCTAssertEqual(
      ServerConfig.production.apiClientAuth.clientId,
      env.apiService.serverConfig.apiClientAuth.clientId
    )
    XCTAssertNil(ServerConfig.production.basicHTTPAuth)
    XCTAssertEqual(
      ServerConfig.production.webBaseUrl.absoluteString,
      env.apiService.serverConfig.webBaseUrl.absoluteString
    )
    XCTAssertEqual(EnvironmentType.production, env.apiService.serverConfig.environment)
    XCTAssertEqual(currentUser, env.currentUser)
    XCTAssertEqual(currentUser, env.koala.loggedInUser)
  }

  func testPushPopSave() {
    AppEnvironment.pushEnvironment(
      ubiquitousStore: MockKeyValueStore(),
      userDefaults: MockKeyValueStore()
    )

    AppEnvironment.pushEnvironment(currentUser: User.template)

    var currentUserId = AppEnvironment.current.userDefaults
      .dictionary(forKey: AppEnvironment.environmentStorageKey)
      .flatMap { $0["currentUser"] as? [String: AnyObject] }
      .flatMap { $0["id"] as? Int }
    XCTAssertEqual(User.template.id, currentUserId, "Current user is saved.")

    AppEnvironment.popEnvironment()

    currentUserId = AppEnvironment.current.userDefaults
      .dictionary(forKey: AppEnvironment.environmentStorageKey)
      .flatMap { $0["currentUser"] as? [String: AnyObject] }
      .flatMap { $0["id"] as? Int }
    XCTAssertEqual(nil, currentUserId, "Current user is cleared.")

    AppEnvironment.popEnvironment()
  }

  func testUpdateServerConfig() {
    AppEnvironment.pushEnvironment()

    // Starts out as production environment
    XCTAssertEqual(AppEnvironment.current.apiService.serverConfig.environment, .production)
    XCTAssertEqual(
      AppEnvironment.current.apiService.serverConfig.apiBaseUrl,
      ServerConfig.production.apiBaseUrl
    )
    XCTAssertEqual(
      AppEnvironment.current.apiService.serverConfig.webBaseUrl,
      ServerConfig.production.webBaseUrl
    )
    XCTAssertEqual(
      AppEnvironment.current.apiService.serverConfig.apiClientAuth.clientId,
      ClientAuth.production.clientId
    )
    XCTAssertNil(AppEnvironment.current.apiService.serverConfig.basicHTTPAuth)
    XCTAssertEqual(
      AppEnvironment.current.apiService.serverConfig.graphQLEndpointUrl,
      ServerConfig.production.graphQLEndpointUrl
    )

    let serverConfig = ServerConfig.staging

    AppEnvironment.updateServerConfig(serverConfig)

    // Updates all properties to staging environment
    XCTAssertEqual(AppEnvironment.current.apiService.serverConfig.environment, .staging)
    XCTAssertEqual(AppEnvironment.current.apiService.serverConfig.apiBaseUrl, ServerConfig.staging.apiBaseUrl)
    XCTAssertEqual(AppEnvironment.current.apiService.serverConfig.webBaseUrl, ServerConfig.staging.webBaseUrl)
    XCTAssertEqual(
      AppEnvironment.current.apiService.serverConfig.apiClientAuth.clientId,
      ClientAuth.development.clientId
    )
    XCTAssertEqual(
      AppEnvironment.current.apiService.serverConfig.basicHTTPAuth?.username,
      BasicHTTPAuth.development.username
    )
    XCTAssertEqual(
      AppEnvironment.current.apiService.serverConfig.basicHTTPAuth?.password,
      BasicHTTPAuth.development.password
    )
    XCTAssertEqual(
      AppEnvironment.current.apiService.serverConfig.graphQLEndpointUrl,
      ServerConfig.staging.graphQLEndpointUrl
    )

    AppEnvironment.popEnvironment()
  }

  func testUpdateDebugData() {
    AppEnvironment.pushEnvironment()

    XCTAssertNil(AppEnvironment.current.debugData)

    let debugConfig = Config.template
      |> \.features .~ ["hello": true]

    AppEnvironment.updateDebugData(DebugData(config: debugConfig))

    XCTAssertEqual(AppEnvironment.current.debugData?.config, debugConfig)

    AppEnvironment.popEnvironment()
  }

  func testUpdateConfig_nilDebugData() {
    AppEnvironment.pushEnvironment()

    XCTAssertNil(AppEnvironment.current.debugData)
    XCTAssertNil(AppEnvironment.current.config)
    XCTAssertEqual(AppEnvironment.current.countryCode, "US")

    let config = Config.template
      |> \.countryCode .~ "CA"
      |> \.features .~ ["hello": true]

    AppEnvironment.updateConfig(config)

    XCTAssertEqual(AppEnvironment.current.config, config)
    XCTAssertEqual(AppEnvironment.current.countryCode, "CA")

    AppEnvironment.popEnvironment()
  }

  func testUpdateConfig_nonNilDebugData() {
    AppEnvironment.pushEnvironment()

    XCTAssertNil(AppEnvironment.current.debugData)
    XCTAssertNil(AppEnvironment.current.config)
    XCTAssertEqual(AppEnvironment.current.countryCode, "US")

    let debugConfig = Config.template
      |> \.countryCode .~ "CA"
      |> \.features .~ ["hello": true]

    AppEnvironment.pushEnvironment(debugData: DebugData(config: debugConfig))

    XCTAssertNotNil(AppEnvironment.current.debugData)

    AppEnvironment.updateConfig(Config.template)

    XCTAssertEqual(AppEnvironment.current.config, debugConfig)
    XCTAssertEqual(AppEnvironment.current.countryCode, "CA")

    AppEnvironment.popEnvironment()
  }

  func testUpdateLanguage() {
    AppEnvironment.pushEnvironment()

    XCTAssertEqual(AppEnvironment.current.language, .en)

    AppEnvironment.updateLanguage(.fr)

    XCTAssertEqual(AppEnvironment.current.language, .fr)

    AppEnvironment.popEnvironment()
  }
}
