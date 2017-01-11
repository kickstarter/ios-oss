import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ActivitySampleBackingCellViewModelInputs {
  /// Call to configure cell with activity value.
  func configureWith(activity: Activity)

  /// Call when the see all activity button is tapped.
  func seeAllActivityTapped()
}

public protocol ActivitySampleBackingCellViewModelOutputs {
  /// Emits the backer image url to be displayed.
  var backerImageURL: Signal<URL?, NoError> { get }

  /// Emits the backing message to be displayed.
  var backingTitleText: Signal<NSAttributedString, NoError> { get }

  /// Emits when should go to activities screen.
  var goToActivity: Signal<Void, NoError> { get }
}

public protocol ActivitySampleBackingCellViewModelType {
  var inputs: ActivitySampleBackingCellViewModelInputs { get }
  var outputs: ActivitySampleBackingCellViewModelOutputs { get }
}

public final class ActivitySampleBackingCellViewModel: ActivitySampleBackingCellViewModelInputs,
  ActivitySampleBackingCellViewModelOutputs, ActivitySampleBackingCellViewModelType {

  public init() {
    let activity = self.activityProperty.signal.skipNil()

    self.backingTitleText = activity.map {
      let string = Strings.activity_friend_backed_project_name_by_creator_name(
        friend_name: $0.user?.name ?? "",
        project_name: $0.project?.name ?? "",
        creator_name: $0.project?.creator.name ?? ""
      )

      return string.simpleHtmlAttributedString(font: UIFont.ksr_subhead()) ?? NSAttributedString(string: "")
    }

    self.backerImageURL = activity
      .map { ($0.user?.avatar.medium).flatMap(URL.init) }

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

  public let backingTitleText: Signal<NSAttributedString, NoError>
  public let backerImageURL: Signal<URL?, NoError>
  public let goToActivity: Signal<Void, NoError>

  public var inputs: ActivitySampleBackingCellViewModelInputs { return self }
  public var outputs: ActivitySampleBackingCellViewModelOutputs { return self }
}
