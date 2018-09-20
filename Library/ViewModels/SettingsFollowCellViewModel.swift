import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsFollowCellViewModelInputs {
  func configureWith(user: User)
  func followTapped(on: Bool)
}

public protocol SettingsFollowCellViewModelOutputs {
  var followingPrivacyOn: Signal<Bool, NoError> { get }
  var showPrivacyFollowingPrompt: Signal<(), NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
}

public protocol SettingsFollowCellViewModelType {
  var inputs: SettingsFollowCellViewModelInputs { get }
  var outputs: SettingsFollowCellViewModelOutputs { get }
}

public final class SettingsFollowCellViewModel: SettingsFollowCellViewModelType,
SettingsFollowCellViewModelInputs, SettingsFollowCellViewModelOutputs {

  public init() {
    let initialUser = configureWithProperty.signal
      .skipNil()

    let userAttributeChanged: Signal<(UserAttribute, Bool), NoError> =
      self.followTappedProperty.signal.filter { $0 == true }.map {
        (UserAttribute.privacy(UserAttribute.Privacy.following), $0)
    }

    self.updateCurrentUser = initialUser
      .switchMap { user in
        userAttributeChanged.scan(user) { user, attributeAndOn in
          let (attribute, on) = attributeAndOn
          return user |> attribute.lens .~ on
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

  public let followingPrivacyOn: Signal<Bool, NoError>
  public let showPrivacyFollowingPrompt: Signal<(), NoError>
  public let updateCurrentUser: Signal<User, NoError>

  public var inputs: SettingsFollowCellViewModelInputs { return self }
  public var outputs: SettingsFollowCellViewModelOutputs { return self }
}
