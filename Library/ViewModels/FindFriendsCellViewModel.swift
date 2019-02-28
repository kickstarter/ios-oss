import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol FindFriendsCellViewModelOutputs {
  var isDisabled: Signal<Bool, NoError> { get }
}

public protocol FindFriendsCellViewModelInputs {
  func configure(with user: User?)
}

public protocol FindFriendsCellViewModelType {
  var inputs: FindFriendsCellViewModelInputs { get }
  var outputs: FindFriendsCellViewModelOutputs { get }
}

public final class FindFriendsCellViewModel: FindFriendsCellViewModelInputs,
FindFriendsCellViewModelOutputs, FindFriendsCellViewModelType {
  public init() {
    let isFollowingEnabled = userProperty.signal
      .skipNil()
      .map { $0 |> User.lens.social.view }
      .skipNil()

    self.isDisabled = isFollowingEnabled.negate()
  }

  fileprivate var userProperty = MutableProperty<User?>(nil)
  public func configure(with user: User?) {
    self.userProperty.value = user
  }

  public let isDisabled: Signal<Bool, NoError>

  public var outputs: FindFriendsCellViewModelOutputs {
    return self
  }

  public var inputs: FindFriendsCellViewModelInputs {
    return self
  }
}
