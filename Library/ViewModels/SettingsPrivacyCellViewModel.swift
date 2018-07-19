import Foundation
import KsApi
import ReactiveSwift
import Result
import UIKit

public protocol SettingsPrivacyCellViewModelInputs {
  func configureWith(user: User)
}

public protocol SettingsPrivacyCellViewModelOutputs {
  var followToggleOn: Signal<Bool, NoError> { get }
}

public protocol SettingsPrivacyCellViewModelType {
  var inputs: SettingsPrivacyCellViewModelInputs { get }
  var outputs: SettingsPrivacyCellViewModelOutputs { get }
}

public final class SettingsPrivacyCellViewModel: SettingsPrivacyCellViewModelType,
SettingsPrivacyCellViewModelInputs, SettingsPrivacyCellViewModelOutputs {

  public init() {

    self.followToggleOn = .empty
  }

  fileprivate let userProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.userProperty.value = user
  }

  public let followToggleOn: Signal<Bool, NoError>

  public var inputs: SettingsPrivacyCellViewModelInputs { return self }
  public var outputs: SettingsPrivacyCellViewModelOutputs { return self }
}
