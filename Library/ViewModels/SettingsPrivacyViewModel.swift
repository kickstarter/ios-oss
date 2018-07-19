import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsPrivacyViewModelInputs {
  func configureWith(user: User)
  func showPrivacyAlert()
  func viewDidLoad()
}

public protocol SettingsPrivacyViewModelOutputs {
  var reloadData: Signal<User, NoError> { get }
  var showFollowPrivacyAlert: Signal<(), NoError> { get }
}

public protocol SettingsPrivacyViewModelType {
  var inputs: SettingsPrivacyViewModelInputs { get }
  var outputs: SettingsPrivacyViewModelOutputs { get }
}

public final class SettingsPrivacyViewModel: SettingsPrivacyViewModelType,
SettingsPrivacyViewModelInputs, SettingsPrivacyViewModelOutputs {

  public init() {
    let initialUser = Signal.combineLatest(
      self.configureWithUserProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.reloadData = initialUser
      .takeWhen(self.viewDidLoadProperty.signal)

    self.showFollowPrivacyAlert = self.showFollowPrivacyAlertProperty.signal

}

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let configureWithUserProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithUserProperty.value = user
  }

  fileprivate let showFollowPrivacyAlertProperty = MutableProperty(())
  public func showPrivacyAlert() {
    self.showFollowPrivacyAlertProperty.value = ()
  }

  public let reloadData: Signal<User, NoError>
  public let showFollowPrivacyAlert: Signal<(), NoError>

  public var inputs: SettingsPrivacyViewModelInputs { return self }
  public var outputs: SettingsPrivacyViewModelOutputs { return self }
}
