import Foundation
import Library
import Models
import Prelude
import ReactiveCocoa
import Result

internal protocol ProfileHeaderViewModelInputs {
  /// Call with the logged-in user data.
  func user(user: User)
}

internal protocol ProfileHeaderViewModelOutputs {
  /// Emits the user avatar URL to be displayed.
  var avatarURL: Signal<NSURL?, NoError> { get }

  /// Emits the number of backed projects to be displayed.
  var backedProjectsCountLabel: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the created label should be hidden.
  var createdProjectsLabelHidden: Signal<Bool, NoError> { get }

  /// Emits the number of created projects to be displayed.
  var createdProjectsCountLabel: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the created projects count label should be hidden.
  var createdProjectsCountLabelHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the divider view between created and backed projects should be
  /// hidden.
  var dividerViewHidden: Signal<Bool, NoError> { get }

  /// Emits the user name to be displayed.
  var userName: Signal<String, NoError> { get }
}

internal protocol ProfileHeaderViewModelType {
  var inputs: ProfileHeaderViewModelInputs { get }
  var outputs: ProfileHeaderViewModelOutputs { get }
}

internal final class ProfileHeaderViewModel: ProfileHeaderViewModelType,
  ProfileHeaderViewModelInputs, ProfileHeaderViewModelOutputs {
  internal init() {
    let user = userProperty.signal.ignoreNil()

    self.avatarURL = user.map { NSURL(string: $0.avatar.large ?? $0.avatar.medium) }
    self.backedProjectsCountLabel = user.map { Format.wholeNumber($0.stats.backedProjectsCount ?? 0) }
    self.createdProjectsCountLabel = user.map { Format.wholeNumber($0.stats.createdProjectsCount ?? 0) }
    self.userName = user.map { $0.name }

    self.createdProjectsCountLabelHidden = user.map { !$0.isCreator }
    self.createdProjectsLabelHidden = user.map { !$0.isCreator }
    self.dividerViewHidden = user.map { !$0.isCreator }
  }

  private let userProperty = MutableProperty<User?>(nil)
  internal func user(user: User) {
    self.userProperty.value = user
  }

  internal let avatarURL: Signal<NSURL?, NoError>
  internal let backedProjectsCountLabel: Signal<String, NoError>
  internal let createdProjectsLabelHidden: Signal<Bool, NoError>
  internal let createdProjectsCountLabel: Signal<String, NoError>
  internal let createdProjectsCountLabelHidden: Signal<Bool, NoError>
  internal let dividerViewHidden: Signal<Bool, NoError>
  internal let userName: Signal<String, NoError>

  internal var inputs: ProfileHeaderViewModelInputs { return self }
  internal var outputs: ProfileHeaderViewModelOutputs { return self }
}
