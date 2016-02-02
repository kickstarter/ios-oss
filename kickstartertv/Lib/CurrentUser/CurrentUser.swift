import Foundation
import ReactiveCocoa
import Result
import Models
import KsApi
import ReactiveExtensions

public protocol CurrentUserType {
  /// Makes `user` the new current user.
  func login(user: User, accessToken: String)

  /// Clears the current user.
  func logout()

  /// Returns the access token for the current user
  var accessToken: String? { get }

  /// Returns a signal producer of current users
  var producer: SignalProducer<User?, NoError> { get }

  /// Refreshes the current user from the API server.
  func refresh()
}

public struct CurrentUser : CurrentUserType {
  public static let shared = CurrentUser(apiService: Service.shared)
  private static let userKey = "com.kickstarter.CurrentUser"
  private static let tokenKey = "com.kickstarter.AccessToken"

  private let apiService: ServiceType
  private let store = MultiKeyValueStore()

  private let (userSignal, userObserver) = SignalProducer<User?, NoError>.buffer(1)
  private let (refreshSignal, refreshObserver) = Signal<(), NoError>.pipe()

  private init(apiService: ServiceType) {
    self.apiService = apiService

    self.userSignal
      .skip(1)
      .startWithNext(self.persistToStorage)

    self.refreshSignal
      .switchMap { _ in apiService.fetchUserSelf().demoteErrors() }
      .wrapInOptional()
      .observe(self.userObserver)

    self.userObserver.sendNext(reviveFromStorage())
  }

  public func login(user: User, accessToken: String) -> Void {
    self.userObserver.sendNext(user)
    self.store.setObject(accessToken, forKey: CurrentUser.tokenKey)
  }

  public func logout() -> Void {
    self.userObserver.sendNext(nil)
    self.store.removeObjectForKey(CurrentUser.tokenKey)
  }

  public var accessToken: String? {
    return self.store.stringForKey(CurrentUser.tokenKey)
  }

  public var producer: SignalProducer<User?, NoError> {
    return self.userSignal
  }

  public func refresh() -> Void {
    self.refreshObserver.sendNext(())
  }

  private func persistToStorage(user: User?) -> Void {
    if let user = user {
      self.store.setObject(user.encode(), forKey: CurrentUser.userKey)
    } else {
      self.store.removeObjectForKey(CurrentUser.userKey)
    }
    self.store.synchronize()
  }

  private func reviveFromStorage() -> User? {
    if let json = self.store.dictionaryForKey(CurrentUser.userKey),
      let user = User.decodeJSONDictionary(json) {
        return user
    }
    
    return nil
  }
}
