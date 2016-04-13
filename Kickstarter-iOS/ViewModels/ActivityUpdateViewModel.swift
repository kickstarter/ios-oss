import Models
import ReactiveCocoa
import Result
import Foundation
import Library
import Prelude

internal protocol ActivityUpdateViewModelOutputs {
  var projectImageURL: NSURL? { get }
  var projectName: String? { get }
  var title: String? { get }
  var sequenceTitle: String? { get }
  var timestamp: String { get }
  var body: String { get }
}

internal final class ActivityUpdateViewModel: ViewModelType, ActivityUpdateViewModelOutputs {
  typealias Model = Activity

  private let activity: Activity

  // MARK: Outputs
  internal lazy var projectImageURL: NSURL? = (self.activity.project?.photo.med).flatMap(NSURL.init)
  internal lazy var projectName: String? = self.activity.project?.name
  internal lazy var title: String? = self.activity.update?.title
  internal lazy var sequenceTitle: String? = {
    guard let sequence = self.activity.update?.sequence else { return nil }

    return localizedString(
      key: "update_sequence",
      defaultValue: "Update #%{sequence}",
      substitutions: ["sequence": Format.wholeNumber(sequence)]
    )
  }()
  internal lazy var timestamp: String = ""
  internal lazy var body: String = {
    ActivityUpdateViewModel.truncateBody(self.activity.update?.body ?? "")
  }()

  internal var outputs: ActivityUpdateViewModelOutputs { return self }

  internal init(activity: Activity, env: Environment = AppEnvironment.current) {
    self.activity = activity
  }

  private static func truncateBody(body: String) -> String {

    let maxLength = 300
    let string = body.htmlStripped()?
      .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
    let length = min(string.characters.count, maxLength)
    let endIndex = string.startIndex.advancedBy(length)
    let suffix = string.characters.count > maxLength ? "..." : ""
    return string.substringToIndex(endIndex) + suffix
  }
}
