import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SettingsNewslettersViewModelInputs {

  func viewDidLoad()
}

public protocol SettingsNewslettersViewModelOutputs {

  var initialUser: Signal<User, NoError> { get }
}

public protocol SettingsNewslettersViewModelType {

  var inputs: SettingsNewslettersViewModelInputs { get }
  var outputs: SettingsNewslettersViewModelOutputs { get }
}

public final class SettingsNewslettersViewModel: SettingsNewslettersViewModelType,
SettingsNewslettersViewModelInputs, SettingsNewslettersViewModelOutputs {

  public init() {

    self.initialUser = self.viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
      }
      .skipNil()
      .skipRepeats()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let initialUser: Signal<User, NoError>

  public var inputs: SettingsNewslettersViewModelInputs { return self }
  public var outputs: SettingsNewslettersViewModelOutputs { return self }
}
