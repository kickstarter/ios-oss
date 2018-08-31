import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

protocol FindFriendsCellViewModelOutputs {
  var disabledDescriptionLabelShouldHide: Signal<Bool, NoError> { get }
  var isDisabled: Signal<Bool, NoError> { get }
}

protocol FindFriendsCellViewModelInputs {
  func configure(with user: User?)
}

protocol FindFriendsCellViewModelType {
  var inputs: FindFriendsCellViewModelInputs { get }
  var outputs: FindFriendsCellViewModelOutputs { get }
}

final class FindFriendsCellViewModel: FindFriendsCellViewModelInputs,
FindFriendsCellViewModelOutputs, FindFriendsCellViewModelType {
  init() {
    let isFollowingEnabled = userProperty.signal
      .skipNil()
      .map { $0 |> User.lens.social.view }
      .skipNil()

    self.isDisabled = isFollowingEnabled.negate()
    self.disabledDescriptionLabelShouldHide = isFollowingEnabled
  }

  fileprivate var userProperty = MutableProperty<User?>(nil)
  func configure(with user: User?) {
    self.userProperty.value = user
  }

  public let disabledDescriptionLabelShouldHide: Signal<Bool, NoError>
  public let isDisabled: Signal<Bool, NoError>

  var outputs: FindFriendsCellViewModelOutputs {
    return self
  }

  var inputs: FindFriendsCellViewModelInputs {
    return self
  }
}
