import Models
import Foundation
import ReactiveCocoa
import Result
import Library

internal protocol ActivityFriendFollowViewModelInputs {
  func followButtonPressed()
}

internal protocol ActivityFriendFollowViewModelOutputs {
  var friendImageURL: NSURL? { get }
  var title: String { get }
  var hideFollowButton: Bool { get }
}

internal final class ActivityFriendFollowViewModel: ViewModelType, ActivityFriendFollowViewModelInputs,
ActivityFriendFollowViewModelOutputs {

  internal typealias Model = Activity

  private let activity: Activity

  // MARK: Inputs
  private let followPressedProperty = MutableProperty()
  internal func followButtonPressed() {
    self.followPressedProperty.value = ()
  }

  // MARK: Outputs
  internal lazy var friendImageURL: NSURL? = (self.activity.user?.avatar.medium).flatMap(NSURL.init)
  internal lazy var title: String = {
    return "Your friend \(self.activity.user?.name ?? "") is following you!"
  }()
  internal lazy var hideFollowButton: Bool = false

  internal var inputs: ActivityFriendFollowViewModelInputs { return self }
  internal var outputs: ActivityFriendFollowViewModelOutputs { return self }

  internal init(activity: Activity) {
    self.activity = activity

    self.followPressedProperty.signal
      .observeNext { [weak self] _ in
        print("You wanna follow \(self?.activity.user?.name ?? ""), huh?")
    }
  }
}
