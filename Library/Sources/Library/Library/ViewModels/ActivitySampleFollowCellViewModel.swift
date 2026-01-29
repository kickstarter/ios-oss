import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ActivitySampleFollowCellViewModelInputs {
  /// Call to configure cell with activity value.
  func configureWith(activity: Activity)

  /// Call when the see all activity button is tapped.
  func seeAllActivityTapped()
}

public protocol ActivitySampleFollowCellViewModelOutputs {
  /// Emits the friend follow to be displayed.
  var friendFollowText: Signal<String, Never> { get }

  /// Emits the friend image url to be displayed.
  var friendImageURL: Signal<URL?, Never> { get }

  /// Emits when should go to activities screen.
  var goToActivity: Signal<Void, Never> { get }
}

public protocol ActivitySampleFollowCellViewModelType {
  var inputs: ActivitySampleFollowCellViewModelInputs { get }
  var outputs: ActivitySampleFollowCellViewModelOutputs { get }
}

public final class ActivitySampleFollowCellViewModel: ActivitySampleFollowCellViewModelInputs,
  ActivitySampleFollowCellViewModelOutputs, ActivitySampleFollowCellViewModelType {
  public init() {
    let activity = self.activityProperty.signal.skipNil()

    self.friendFollowText = activity
      .map { Strings.activity_user_name_is_now_following_you(user_name: $0.user?.name ?? "") }

    self.friendImageURL = activity
      .map { ($0.user?.avatar.medium).flatMap(URL.init) }

    self.goToActivity = self.seeAllActivityTappedProperty.signal
  }

  fileprivate let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity: Activity) {
    self.activityProperty.value = activity
  }

  fileprivate let seeAllActivityTappedProperty = MutableProperty(())
  public func seeAllActivityTapped() {
    self.seeAllActivityTappedProperty.value = ()
  }

  public let friendFollowText: Signal<String, Never>
  public let friendImageURL: Signal<URL?, Never>
  public let goToActivity: Signal<Void, Never>

  public var inputs: ActivitySampleFollowCellViewModelInputs { return self }
  public var outputs: ActivitySampleFollowCellViewModelOutputs { return self }
}
