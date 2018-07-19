import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsPrivacyViewModelInputs {
  func configureWith(user: User)
  func viewDidLoad()
}

public protocol SettingsPrivacyViewModelOutputs {
  var reloadData: Signal <User, NoError> { get }
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
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let configureWithUserProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithUserProperty.value = user
  }

  public let reloadData: Signal<User, NoError>

  public var inputs: SettingsPrivacyViewModelInputs { return self }
  public var outputs: SettingsPrivacyViewModelOutputs { return self }
}
