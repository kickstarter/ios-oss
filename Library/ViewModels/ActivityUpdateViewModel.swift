import Models
import Prelude
import ReactiveCocoa
import Result

public protocol ActivityUpdateViewModelInputs {
  func activity(activity: Activity)
  func tappedProjectImage()
}

public protocol ActivityUpdateViewModelOutputs {
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String?, NoError> { get }
  var title: Signal<String?, NoError> { get }
  var sequenceTitle: Signal<String?, NoError> { get }
  var timestamp: Signal<String, NoError> { get }
  var body: Signal<String, NoError> { get }
  var tappedActivityProjectImage: Signal<Activity, NoError> { get }
}

public final class ActivityUpdateViewModel: ActivityUpdateViewModelInputs, ActivityUpdateViewModelOutputs {

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()

    self.projectImageURL = activity.map { ($0.project?.photo.med).flatMap(NSURL.init) }

    self.projectName = activity.map { $0.project?.name }

    self.title = activity.map { $0.update?.title }

    self.sequenceTitle = activity.map { $0.update?.sequence ?? 1 }
      .map {
        localizedString(
          key: "update_sequence",
          defaultValue: "Update #%{sequence}",
          substitutions: ["sequence": Format.wholeNumber($0)]
        )
    }

    self.timestamp = activity.map {
      Format.date(secondsInUTC: $0.createdAt, dateStyle: .MediumStyle, timeStyle: .NoStyle)
    }

    self.body = activity.map { $0.update?.body ?? "" }.map(truncateBody)

    self.tappedActivityProjectImage = activity
      .takeWhen(self.tappedProjectImageProperty.signal)
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func activity(activity: Activity) {
    self.activityProperty.value = activity
  }
  private let tappedProjectImageProperty = MutableProperty()
  public func tappedProjectImage() {
    self.tappedProjectImageProperty.value = ()
  }

  public let projectImageURL: Signal<NSURL?, NoError>
  public let projectName: Signal<String?, NoError>
  public let title: Signal<String?, NoError>
  public let sequenceTitle: Signal<String?, NoError>
  public let timestamp: Signal<String, NoError>
  public let body: Signal<String, NoError>
  public let tappedActivityProjectImage: Signal<Activity, NoError>

  public var inputs: ActivityUpdateViewModelInputs { return self }
  public var outputs: ActivityUpdateViewModelOutputs { return self }
}

private func truncateBody(body: String) -> String {

  let maxLength = 300
  let string = body.htmlStripped()?
    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
  let length = min(string.characters.count, maxLength)
  let endIndex = string.startIndex.advancedBy(length)
  let suffix = string.characters.count > maxLength ? "..." : ""
  return string.substringToIndex(endIndex) + suffix
}
