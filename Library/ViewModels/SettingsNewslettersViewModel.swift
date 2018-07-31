import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SettingsNewslettersViewModelInputs {

  func didUpdate(user: User)
  func viewDidLoad()
}

public protocol SettingsNewslettersViewModelOutputs {

  var currentUser: Signal<User, NoError> { get }
}

public protocol SettingsNewslettersViewModelType {

  var inputs: SettingsNewslettersViewModelInputs { get }
  var outputs: SettingsNewslettersViewModelOutputs { get }
}

public final class SettingsNewslettersViewModel: SettingsNewslettersViewModelType,
SettingsNewslettersViewModelInputs, SettingsNewslettersViewModelOutputs {

  public init() {

    let initialUser = self.viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .wrapInOptional()
          .prefix(value: AppEnvironment.current.currentUser)
          .demoteErrors()
      }
      .skipNil()
      .skipRepeats()

    let updatedUser = self.didUpdateUserProperty.signal.skipNil()

    self.currentUser = Signal.merge(initialUser, updatedUser)
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let didUpdateUserProperty = MutableProperty<User?>(nil)
  public func didUpdate(user: User) {
    self.didUpdateUserProperty.value = user
  }

  public let currentUser: Signal<User, NoError>

  public var inputs: SettingsNewslettersViewModelInputs { return self }
  public var outputs: SettingsNewslettersViewModelOutputs { return self }
}
