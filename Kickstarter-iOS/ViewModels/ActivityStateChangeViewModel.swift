import protocol Library.ViewModelType
import struct Models.Activity
import class Foundation.NSURL
import enum Library.Format

internal protocol ActivityStateChangeViewModelOutputs {
  var projectImageURL: NSURL? { get }
  var projectName: String { get }
  var fundingDate: String { get }
  var pledgedTitle: String { get }
  var pledgedSubtitle: String { get }
}

internal class ActivityStateChangeViewModel: ViewModelType, ActivityStateChangeViewModelOutputs {
  internal typealias Model = Activity
  private let activity: Activity

  // MARK: Outputs
  internal lazy var projectImageURL: NSURL? = (self.activity.project?.photo.full).flatMap(NSURL.init)
  internal lazy var projectName: String = "\(self.activity.project?.name ?? "") was successfully funded."
  internal lazy var fundingDate = "Mar 2, 2016"
  internal lazy var pledgedTitle: String = Format.currency(self.activity.project?.pledged ?? 0,
    country: self.activity.project?.country ?? .US)
  internal lazy var pledgedSubtitle = "pledged of $10,000"

  internal var outputs: ActivityStateChangeViewModelOutputs { return self }

  internal init(activity: Activity) {
    self.activity = activity
  }
}
