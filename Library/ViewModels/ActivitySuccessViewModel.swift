import KsApi
import ReactiveCocoa
import Result

public protocol ActivitySuccessViewModelInputs {
  func activity(activity: Activity)
}

public protocol ActivitySuccessViewModelOutputs {
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String, NoError> { get }
  var fundingDate: Signal<String, NoError> { get }
  var pledgedTitle: Signal<String, NoError> { get }
  var pledgedSubtitle: Signal<String, NoError> { get }
}

public final class ActivitySuccessViewModel: ActivitySuccessViewModelInputs,
ActivitySuccessViewModelOutputs {

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()

    self.projectImageURL = activity.map { ($0.project?.photo.full).flatMap(NSURL.init) }

    self.projectName = activity.map { $0.project?.name ?? "" }

    self.fundingDate = activity.mapConst("Mar 2, 2016")

    self.pledgedTitle = activity.map {
      Format.currency(
        $0.project?.stats.pledged ?? 0,
        country: $0.project?.country ?? .US
      )
    }

    self.pledgedSubtitle = activity.mapConst("pledged of $10,000")
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func activity(activity: Activity) {
    self.activityProperty.value = activity
  }

  public let projectImageURL: Signal<NSURL?, NoError>
  public let projectName: Signal<String, NoError>
  public let fundingDate: Signal<String, NoError>
  public let pledgedTitle: Signal<String, NoError>
  public let pledgedSubtitle: Signal<String, NoError>

  public var inputs: ActivitySuccessViewModelInputs { return self }
  public var outputs: ActivitySuccessViewModelOutputs { return self }
}
