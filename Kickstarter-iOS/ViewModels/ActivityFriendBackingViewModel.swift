import protocol Library.ViewModelType
import struct Models.Activity
import struct Library.Environment
import struct Library.AppEnvironment
import class Foundation.NSURL
import func Library.localizedString
import class ReactiveCocoa.Signal
import enum Result.NoError

internal protocol ActivityFriendBackingViewModelOutputs {
  var friendImageURL: NSURL? { get }
  var friendTitle: String { get }
  var projectName: String { get }
  var creatorName: String { get }
  var projectImageURL: NSURL? { get }
}

internal final class ActivityFriendBackingViewModel: ViewModelType, ActivityFriendBackingViewModelOutputs {

  internal typealias Model = Activity
  private let activity: Activity

  // MARK: Outputs
  internal lazy var friendImageURL: NSURL? = (self.activity.user?.avatar.medium).flatMap(NSURL.init)
  internal lazy var friendTitle: String = localizedString(
    key: "friend.title",
    defaultValue: "%{friend_name} backed a %{category} project.",
    substitutions: [
      "friend_name": self.activity.user?.name ?? "",
      "category": self.activity.project?.category.name ?? ""
    ]
  )
  internal lazy var projectName: String = self.activity.project?.name ?? ""
  internal lazy var creatorName: String = localizedString(
    key: "by_creator",
    defaultValue: "by %{creator_name}",
    substitutions: ["creator_name": self.activity.project?.creator.name ?? ""]
  )
  internal lazy var projectImageURL: NSURL? = (self.activity.project?.photo.med).flatMap(NSURL.init)

  internal var outputs: ActivityFriendBackingViewModelOutputs { return self }

  internal init(activity: Activity, env: Environment = AppEnvironment.current) {
    self.activity = activity
  }
}
