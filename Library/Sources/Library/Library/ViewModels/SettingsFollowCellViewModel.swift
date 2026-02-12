import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol SettingsFollowCellViewModelInputs {
  func configureWith(user: User)
  func followTapped(on: Bool)
}

public protocol SettingsFollowCellViewModelOutputs {
  var followingPrivacyOn: Signal<Bool, Never> { get }
  var showPrivacyFollowingPrompt: Signal<(), Never> { get }
  var updateCurrentUser: Signal<User, Never> { get }
}

public protocol SettingsFollowCellViewModelType {
  var inputs: SettingsFollowCellViewModelInputs { get }
  var outputs: SettingsFollowCellViewModelOutputs { get }
}

public final class SettingsFollowCellViewModel: SettingsFollowCellViewModelType,
  SettingsFollowCellViewModelInputs, SettingsFollowCellViewModelOutputs {
  public init() {
    let initialUser = self.configureWithProperty.signal.skipNil()

    let userAttributeChanged: Signal<(UserAttribute, Bool), Never> =
      self.followTappedProperty.signal.filter { $0 == true }.map {
        (UserAttribute.privacy(UserAttribute.Privacy.following), $0)
      }

    self.updateCurrentUser = initialUser
      .switchMap { user in
        userAttributeChanged.scan(user) { user, attributeAndOn in
          let (attribute, on) = attributeAndOn
          return user |> attribute.keyPath .~ on
        }
      }

    self.followingPrivacyOn = initialUser
      .map { $0.social }.skipNil()

    self.showPrivacyFollowingPrompt = self.followTappedProperty.signal
      .filter { $0 == false }
      .ignoreValues()
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  fileprivate let followTappedProperty = MutableProperty(false)
  public func followTapped(on: Bool) {
    self.followTappedProperty.value = on
  }

  public let followingPrivacyOn: Signal<Bool, Never>
  public let showPrivacyFollowingPrompt: Signal<(), Never>
  public let updateCurrentUser: Signal<User, Never>

  public var inputs: SettingsFollowCellViewModelInputs { return self }
  public var outputs: SettingsFollowCellViewModelOutputs { return self }
}
