import Models
import ReactiveCocoa
import Result
import ReactiveExtensions
import KsApi
import struct Library.Environment
import struct Library.AppEnvironment

protocol ProfileViewModelInputs {
  func logoutPressed()
}

protocol ProfileViewModelOutputs {
  var avatarURL: MutableProperty<NSURL?> { get }
  var name: MutableProperty<String?> { get }
}

final class ProfileViewModel : ProfileViewModelInputs, ProfileViewModelOutputs {
  // MARK: Inputs
  let (logoutSignal, logoutObserver) = Signal<(), NoError>.pipe()
  func logoutPressed() { logoutObserver.sendNext(()) }
  var inputs: ProfileViewModelInputs { return self }

  // MARK: Outputs
  let avatarURL = MutableProperty<NSURL?>(nil)
  let name = MutableProperty<String?>(nil)
  var outputs: ProfileViewModelOutputs { return self }

  init(env: Environment = AppEnvironment.current) {
    let currentUser = env.currentUser

    let user = currentUser.producer.ignoreNil()
    currentUser.refresh()

    avatarURL <~ user.map { $0.avatar.large }.ignoreNil().map { NSURL(string: $0) }.skipRepeats(==)
    name <~ user.map { $0.name }.skipRepeats(==)

    logoutSignal.observeNext {
      currentUser.logout()
    }
  }
}
