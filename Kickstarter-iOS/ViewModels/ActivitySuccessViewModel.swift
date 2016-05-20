import Library
import Models
import Foundation
import Library
import ReactiveCocoa
import Result

internal protocol ActivitySuccessViewModelInputs {
  func activity(activity: Activity)
}

internal protocol ActivitySuccessViewModelOutputs {
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String, NoError> { get }
  var fundingDate: Signal<String, NoError> { get }
  var pledgedTitle: Signal<String, NoError> { get }
  var pledgedSubtitle: Signal<String, NoError> { get }
}

internal final class ActivitySuccessViewModel: ActivitySuccessViewModelInputs,
ActivitySuccessViewModelOutputs {

  internal init() {
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
  internal func activity(activity: Activity) {
    self.activityProperty.value = activity
  }

  internal let projectImageURL: Signal<NSURL?, NoError>
  internal let projectName: Signal<String, NoError>
  internal let fundingDate: Signal<String, NoError>
  internal let pledgedTitle: Signal<String, NoError>
  internal let pledgedSubtitle: Signal<String, NoError>

  internal var inputs: ActivitySuccessViewModelInputs { return self }
  internal var outputs: ActivitySuccessViewModelOutputs { return self }
}
