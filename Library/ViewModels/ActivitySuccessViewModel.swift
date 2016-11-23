import KsApi
import ReactiveCocoa
import Result

public protocol ActivitySuccessViewModelInputs {
  func configureWith(activity activity: Activity)
}

public protocol ActivitySuccessViewModelOutputs {
  var fundingDate: Signal<String, NoError> { get }
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String, NoError> { get }
  var pledgedSubtitle: Signal<String, NoError> { get }
  var pledgedTitle: Signal<String, NoError> { get }
}

public protocol ActivitySuccessViewModelType {
  var inputs: ActivitySuccessViewModelInputs { get }
  var outputs: ActivitySuccessViewModelOutputs { get }
}

public final class ActivitySuccessViewModel: ActivitySuccessViewModelType, ActivitySuccessViewModelInputs,
ActivitySuccessViewModelOutputs {

  public init() {
    let project = self.activityProperty.signal.ignoreNil()
      .map { $0.project }.ignoreNil()

    self.projectImageURL = project.map { $0.photo.full }.map(NSURL.init(string:))

    self.projectName = project.map { $0.name }

    self.fundingDate = project.map {
      Format.date(secondsInUTC: $0.dates.stateChangedAt, dateStyle: .MediumStyle, timeStyle: .NoStyle)
    }

    self.pledgedTitle = project.map { Format.currency($0.stats.pledged, country: $0.country) }

    self.pledgedSubtitle = project.map {
      Strings.activity_project_state_change_pledged_of_goal(
        goal: Format.currency($0.stats.goal, country: $0.country)
      )
    }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
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
