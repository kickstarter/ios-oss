import Models
import ReactiveCocoa
import Result
import Foundation
import Library
import Prelude

internal protocol ActivityUpdateViewModelInputs {
  func activity(activity: Activity)
  func tappedProjectImage()
}

internal protocol ActivityUpdateViewModelOutputs {
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String?, NoError> { get }
  var title: Signal<String?, NoError> { get }
  var sequenceTitle: Signal<String?, NoError> { get }
  var timestamp: Signal<String, NoError> { get }
  var body: Signal<String, NoError> { get }
  var tappedActivityProjectImage: Signal<Activity, NoError> { get }
}

internal final class ActivityUpdateViewModel: ActivityUpdateViewModelInputs, ActivityUpdateViewModelOutputs {

  internal init() {
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
  internal func activity(activity: Activity) {
    self.activityProperty.value = activity
  }
  private let tappedProjectImageProperty = MutableProperty()
  internal func tappedProjectImage() {
    self.tappedProjectImageProperty.value = ()
  }

  internal let projectImageURL: Signal<NSURL?, NoError>
  internal let projectName: Signal<String?, NoError>
  internal let title: Signal<String?, NoError>
  internal let sequenceTitle: Signal<String?, NoError>
  internal let timestamp: Signal<String, NoError>
  internal let body: Signal<String, NoError>
  internal let tappedActivityProjectImage: Signal<Activity, NoError>

  internal var inputs: ActivityUpdateViewModelInputs { return self }
  internal var outputs: ActivityUpdateViewModelOutputs { return self }
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
