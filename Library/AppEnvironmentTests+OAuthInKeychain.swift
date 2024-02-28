@testable import KsApi
@testable import Library
import XCTest

final class AppEnvironmentTests_OAuthInKeychain: XCTestCase {
  override func setUp() {
    AppEnvironment.resetStackForUnitTests()
    XCTAssertNoThrow(try Keychain.deleteAllPasswords())
  }

  func setFeatureUseKeychainEnabled(_ setting: Bool) {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.useKeychainForOAuthToken.rawValue: setting
    ]

    /* Awkward bit of condition here - our feature flag values implicitly come from
     AppEnvironment.current, which in some cases, is the PREVIOUS environment in the stack.
     If you're pushing/saving a new stack, that can be confusing. */
    AppEnvironment.updateRemoteConfigClient(mockConfigClient)
  }

  // MARK: - Tests copied from AppEnvironmentTests

  func testSaveEnvironment_featureUseKeychainEnabledIsTrue() {
    self.setFeatureUseKeychainEnabled(true)

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

    do {
      let tokenFromKeychain = try Keychain
        .fetchPassword(forAccount: AppEnvironment.accountNameForUserId(currentUser.id))
      XCTAssertEqual(tokenFromKeychain, "deadbeef")

    } catch {
      XCTFail("Expected keychain fetch not to throw")
    }

    XCTAssertNil(
      result["apiService.oauthToken.token"] as? String,
      "If login with keychain is enabled, the oauth token shouldn't be saved in the user defaults"
    )

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

  func testRestoreFromEnvironment_featureUseKeychainEnabledIsTrue() {
    self.setFeatureUseKeychainEnabled(true)

    let apiService = MockService(
      serverConfig: ServerConfig.production,
      oauthToken: OauthToken(token: "deadbeef")
    )

    let currentUser = User.template
    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    AppEnvironment.saveEnvironment(
      environment: Environment(
        apiService: apiService,
        currentUser: currentUser
      ),
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
    XCTAssertEqual(currentUser, env.ksrAnalytics.loggedInUser)
  }

  func testFromStorage_WithFullDataStored_featureUseKeychainEnabledIsTrue() {
    self.setFeatureUseKeychainEnabled(true)

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
      ] as [String: Any],
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
    XCTAssertEqual(user, env.ksrAnalytics.loggedInUser)
    XCTAssertNotNil(env.appTrackingTransparency)

    let differentEnv = AppEnvironment.fromStorage(
      ubiquitousStore: MockKeyValueStore(),
      userDefaults: MockKeyValueStore()
    )
    XCTAssertNil(differentEnv.apiService.oauthToken?.token)
    XCTAssertEqual(nil, differentEnv.currentUser)
    XCTAssertNotNil(env.appTrackingTransparency)
  }

  func testFromStorage_WithNothingStored_featureUseKeychainEnabledIsTrue() {
    self.setFeatureUseKeychainEnabled(true)

    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()
    let env = AppEnvironment.fromStorage(ubiquitousStore: ubiquitousStore, userDefaults: userDefaults)

    XCTAssertNil(env.apiService.oauthToken?.token)
    XCTAssertEqual(nil, env.currentUser)
  }

  func testUserSession_featureUseKeychainEnabledIsTrue() {
    self.setFeatureUseKeychainEnabled(true)

    AppEnvironment.pushEnvironment(userDefaults: MockKeyValueStore())

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

    let env = AppEnvironment
      .fromStorage(
        ubiquitousStore: AppEnvironment.current.ubiquitousStore,
        userDefaults: AppEnvironment.current.userDefaults
      )
    XCTAssertNil(env.apiService.oauthToken)
    XCTAssertNil(env.currentUser)
  }

  // MARK: - New tests

  func testFromStorage_featureUseKeychainEnabledIsTrue_hasTokenInKeychain_usesToken() {
    self.setFeatureUseKeychainEnabled(true)

    let tokenInKeychain = "this is my token"
    let tokenInDefaults = "this is NOT my token"
    let user = User.template

    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    userDefaults.set(
      [
        "apiService.oauthToken.token": tokenInDefaults,
        "currentUser": user.encode()
      ] as [String: Any],
      forKey: AppEnvironment.environmentStorageKey
    )

    XCTAssertNoThrow(try Keychain
      .storePassword(tokenInKeychain, forAccount: AppEnvironment.accountNameForUserId(user.id)))

    let env = AppEnvironment
      .fromStorage(
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      )

    XCTAssertNotNil(env.apiService.oauthToken)
    XCTAssertEqual(env.apiService.oauthToken?.token, tokenInKeychain)
    XCTAssertNotEqual(env.apiService.oauthToken?.token, tokenInDefaults)
  }

  func testFromStorage_featureUseKeychainEnabledIsTrue_hasTokenInDefaults_usesTokenAndMigratesToKeychainOnNextSave() {
    self.setFeatureUseKeychainEnabled(true)

    let tokenInDefaults = "this is my token"
    let user = User.template

    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    userDefaults.set(
      [
        "apiService.oauthToken.token": tokenInDefaults,
        "currentUser": user.encode()
      ] as [String: Any],
      forKey: AppEnvironment.environmentStorageKey
    )

    let env = AppEnvironment
      .fromStorage(
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      )

    XCTAssertNotNil(env.apiService.oauthToken)
    XCTAssertEqual(env.apiService.oauthToken?.token, tokenInDefaults)

    AppEnvironment.pushEnvironment(env)

    let tokenFromKeychain = try! Keychain
      .fetchPassword(forAccount: AppEnvironment.accountNameForUserId(user.id))
    XCTAssertEqual(tokenInDefaults, tokenFromKeychain)
  }

  func testLoginLogoutFromStorage_clearsKeychainTokenAfterLogout() {
    self.setFeatureUseKeychainEnabled(true)
    let user = User.template
    let token = "this is a token"

    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    AppEnvironment.pushEnvironment(userDefaults: userDefaults)

    XCTAssertNil(AppEnvironment.current.apiService.oauthToken)
    XCTAssertNil(AppEnvironment.current.currentUser)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: token, user: user))

    XCTAssertEqual(AppEnvironment.current.apiService.oauthToken?.token, token)
    XCTAssertEqual(AppEnvironment.current.currentUser, user)

    AppEnvironment.logout()

    XCTAssertNil(AppEnvironment.current.apiService.oauthToken)
    XCTAssertNil(AppEnvironment.current.currentUser)

    let env = AppEnvironment
      .fromStorage(
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      )

    XCTAssertNil(AppEnvironment.current.apiService.oauthToken)
    XCTAssertNil(AppEnvironment.current.currentUser)
  }

  func testFromStorage_featureUseKeychainEnabledIsFalse_hasTokenInDefaults_usesTokenInDefaults() {
    self.setFeatureUseKeychainEnabled(false)

    let tokenInKeychain = "this is NOT my token"
    let tokenInDefaults = "this is my token"
    let user = User.template

    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    userDefaults.set(
      [
        "apiService.oauthToken.token": tokenInDefaults,
        "currentUser": user.encode()
      ] as [String: Any],
      forKey: AppEnvironment.environmentStorageKey
    )

    XCTAssertNoThrow(try Keychain
      .storePassword(tokenInKeychain, forAccount: AppEnvironment.accountNameForUserId(user.id)))

    let env = AppEnvironment
      .fromStorage(
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      )

    XCTAssertNotNil(env.apiService.oauthToken)
    XCTAssertEqual(env.apiService.oauthToken?.token, tokenInDefaults)
    XCTAssertNotEqual(env.apiService.oauthToken?.token, tokenInKeychain)
  }

  func testFromStorage_featureUseKeychainEnabledIsFalse_hasTokenInDefaults_usesTokenAndDoesntMigrateToKeychain() {
    self.setFeatureUseKeychainEnabled(false)

    let tokenInDefaults = "this is my token"
    let user = User.template

    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    userDefaults.set(
      [
        "apiService.oauthToken.token": tokenInDefaults,
        "currentUser": user.encode()
      ] as [String: Any],
      forKey: AppEnvironment.environmentStorageKey
    )

    let env = AppEnvironment
      .fromStorage(
        ubiquitousStore: ubiquitousStore,
        userDefaults: userDefaults
      )

    XCTAssertNotNil(env.apiService.oauthToken)
    XCTAssertEqual(env.apiService.oauthToken?.token, tokenInDefaults)

    let hasTokenInKeychain = Keychain.hasPassword(forAccount: AppEnvironment.accountNameForUserId(user.id))
    XCTAssertFalse(hasTokenInKeychain)
  }

  func testLoginTwice_differentToken_changesTokenInKeychain() {
    self.setFeatureUseKeychainEnabled(true)

    let userDefaults = MockKeyValueStore()
    let ubiquitiousStore = MockKeyValueStore()

    AppEnvironment.pushEnvironment(userDefaults: userDefaults)

    let user = User.template
    let token1 = "first token"
    let token2 = "second token"
    let accountName = AppEnvironment.accountNameForUserId(user.id)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: token1, user: user))

    let fetchedToken1 = try! Keychain.fetchPassword(forAccount: accountName)
    XCTAssertEqual(AppEnvironment.current.apiService.oauthToken?.token, token1)
    XCTAssertEqual(fetchedToken1, token1)

    AppEnvironment.login(AccessTokenEnvelope(accessToken: token2, user: user))

    let fetchedToken2 = try! Keychain.fetchPassword(forAccount: accountName)
    XCTAssertEqual(AppEnvironment.current.apiService.oauthToken?.token, token2)
    XCTAssertEqual(fetchedToken2, token2)

    let env = AppEnvironment.fromStorage(ubiquitousStore: ubiquitiousStore, userDefaults: userDefaults)
    XCTAssertEqual(env.apiService.oauthToken?.token, token2)
  }

  func testMigrateToKeychain_thenTurnOffFeatureFlag() {
    self.setFeatureUseKeychainEnabled(true)

    let token = "this is a token"
    let user = User.template

    let userDefaults = MockKeyValueStore()
    let ubiquitousStore = MockKeyValueStore()

    userDefaults.set(
      [
        "apiService.oauthToken.token": token,
        "currentUser": user.encode()
      ] as [String: Any],
      forKey: AppEnvironment.environmentStorageKey
    )

    let env = AppEnvironment.fromStorage(ubiquitousStore: ubiquitousStore, userDefaults: userDefaults)
    XCTAssertEqual(env.apiService.oauthToken?.token, token)
    XCTAssertEqual(env.currentUser, user)

    AppEnvironment.saveEnvironment(ubiquitousStore: ubiquitousStore, userDefaults: userDefaults)

    self.setFeatureUseKeychainEnabled(false)

    // Keychain use is off, but the token has been deleted from userDefaults
    let env2 = AppEnvironment.fromStorage(ubiquitousStore: ubiquitousStore, userDefaults: userDefaults)
    XCTAssertNil(env2.apiService.oauthToken?.token)
    XCTAssertNil(env2.currentUser)
  }
}
