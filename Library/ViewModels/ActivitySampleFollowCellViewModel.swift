import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ActivitySampleFollowCellViewModelInputs {
  /// Call to configure cell with activity value.
  func configureWith(activity: Activity)

  /// Call when the see all activity button is tapped.
  func seeAllActivityTapped()
}

public protocol ActivitySampleFollowCellViewModelOutputs {
  /// Emits the friend follow to be displayed.
  var friendFollowText: Signal<String, NoError> { get }

  /// Emits the friend image url to be displayed.
  var friendImageURL: Signal<NSURL?, NoError> { get }

  /// Emits when should go to activities screen.
  var goToActivity: Signal<Void, NoError> { get }
}

public protocol ActivitySampleFollowCellViewModelType {
  var inputs: ActivitySampleFollowCellViewModelInputs { get }
  var outputs: ActivitySampleFollowCellViewModelOutputs { get }
}

public final class ActivitySampleFollowCellViewModel: ActivitySampleFollowCellViewModelInputs,
  ActivitySampleFollowCellViewModelOutputs, ActivitySampleFollowCellViewModelType {

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()

    self.friendFollowText = activity
      .map { Strings.activity_user_name_is_now_following_you(user_name: $0.user?.name ?? "" ) }

    self.friendImageURL = activity
      .map { ($0.user?.avatar.medium).flatMap(NSURL.init) }

    self.goToActivity = self.seeAllActivityTappedProperty.signal
  }

  fileprivate let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity: Activity) {
    self.activityProperty.value = activity
  }

  fileprivate let seeAllActivityTappedProperty = MutableProperty()
  public func seeAllActivityTapped() {
    self.seeAllActivityTappedProperty.value = ()
  }

  public let friendFollowText: Signal<String, NoError>
  public let friendImageURL: Signal<NSURL?, NoError>
  public let goToActivity: Signal<Void, NoError>

  public var inputs: ActivitySampleFollowCellViewModelInputs { return self }
  public var outputs: ActivitySampleFollowCellViewModelOutputs { return self }
}
