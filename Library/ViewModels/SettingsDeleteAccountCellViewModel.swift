import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsDeleteAccountCellViewModelInputs {
  func configureWith(user: User)
  func deleteAccountTapped()
}

public protocol SettingsDeleteAccountCellViewModelOutputs {
  var notifyDeleteAccountTapped: Signal<URL, NoError> { get }
}

public protocol SettingsDeleteAccountCellViewModelType {
  var inputs: SettingsDeleteAccountCellViewModelInputs { get }
  var outputs: SettingsDeleteAccountCellViewModelOutputs { get }
}

public final class SettingsDeleteAccountCellViewModel: SettingsDeleteAccountCellViewModelType, SettingsDeleteAccountCellViewModelInputs, SettingsDeleteAccountCellViewModelOutputs {

  public init() {
    self.notifyDeleteAccountTapped = self.deleteAccountTappedProperty.signal
      .map {
        AppEnvironment.current.apiService.serverConfig.webBaseUrl.appendingPathComponent("/profile/destroy")
    }
  }

  fileprivate let deleteAccountTappedProperty = MutableProperty(())
  public func deleteAccountTapped() {
    self.deleteAccountTappedProperty.value = ()
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  public let notifyDeleteAccountTapped: Signal<URL, NoError>

  public var inputs: SettingsDeleteAccountCellViewModelInputs { return self }
  public var outputs: SettingsDeleteAccountCellViewModelOutputs { return self }
}
