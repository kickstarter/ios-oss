import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol SettingsDeleteOrRequestCellViewModelInputs {
  func configureWith(user: User)
  func deleteAccountTapped()
}

public protocol SettingsDeleteOrRequestCellViewModelOutputs {
  var notifyDeleteAccountTapped: Signal<URL, Never> { get }
}

public protocol SettingsDeleteOrRequestCellViewModelType {
  var inputs: SettingsDeleteOrRequestCellViewModelInputs { get }
  var outputs: SettingsDeleteOrRequestCellViewModelOutputs { get }
}

public final class SettingsDeleteOrRequestCellViewModel: SettingsDeleteOrRequestCellViewModelType,
  SettingsDeleteOrRequestCellViewModelInputs, SettingsDeleteOrRequestCellViewModelOutputs {
  public init() {
    self.notifyDeleteAccountTapped = self.deleteAccountTappedProperty.signal
      .map {
        let code = Locale.current.languageCode ?? "en"
        return URL(string: "https://legal.kickstarter.com/policies/\(code)/?modal=take-control")
      }.skipNil()
  }

  fileprivate let deleteAccountTappedProperty = MutableProperty(())
  public func deleteAccountTapped() {
    self.deleteAccountTappedProperty.value = ()
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  public let notifyDeleteAccountTapped: Signal<URL, Never>

  public var inputs: SettingsDeleteOrRequestCellViewModelInputs { return self }
  public var outputs: SettingsDeleteOrRequestCellViewModelOutputs { return self }
}
