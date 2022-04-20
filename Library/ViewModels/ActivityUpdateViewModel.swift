import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ActivityUpdateViewModelInputs {
  /// Call to configure with the activity.
  func configureWith(activity: Activity)

  /// Call when the project image is tapped.
  func tappedProjectImage()
}

public protocol ActivityUpdateViewModelOutputs {
  /// Emits the update's body to be displayed.
  var body: Signal<String, Never> { get }

  /// Emits the cell's accessibility label to be read by VoiceOver.
  var cellAccessibilityLabel: Signal<String, Never> { get }

  /// Emits when we should notify the delegate that the project image button was tapped.
  var notifyDelegateTappedProjectImage: Signal<Activity, Never> { get }

  /// Emits the project button's accessibility label to be read by VoiceOver.
  var projectButtonAccessibilityLabel: Signal<String, Never> { get }

  /// Emits the project image URL to be displayed.
  var projectImageURL: Signal<URL?, Never> { get }

  /// Emits the project name to be displayed.
  var projectName: Signal<String, Never> { get }

  /// Emits an attributed string for the update sequence title.
  var sequenceTitle: Signal<NSAttributedString, Never> { get }

  /// Emits the update title to be displayed.
  var title: Signal<String, Never> { get }
}

public protocol ActivityUpdateViewModelType {
  var inputs: ActivityUpdateViewModelInputs { get }
  var outputs: ActivityUpdateViewModelOutputs { get }
}

public final class ActivityUpdateViewModel: ActivityUpdateViewModelType, ActivityUpdateViewModelInputs,
  ActivityUpdateViewModelOutputs {
  public init() {
    let activity = self.activityProperty.signal.skipNil()
    let project = activity.map { $0.project }.skipNil()
    let update = activity.map { $0.update }.skipNil()

    self.body = update
      .map { $0.body?.htmlStripped()?.truncated(maxLength: 300) ?? "" }

    self.projectImageURL = project.map { $0.photo.med }.map(URL.init(string:))

    self.projectName = project.map { $0.name }
    self.projectButtonAccessibilityLabel = self.projectName

    self.title = update.map { $0.title }

    self.sequenceTitle = activity.map(updatePostedString(forActivity:))

    self.notifyDelegateTappedProjectImage = activity
      .takeWhen(self.tappedProjectImageProperty.signal)

    self.cellAccessibilityLabel = Signal.combineLatest(project, self.sequenceTitle)
      .map { project, postedText in "\(project.name) \(postedText.string)" }
  }

  fileprivate let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity: Activity) {
    self.activityProperty.value = activity
  }

  fileprivate let tappedProjectImageProperty = MutableProperty(())
  public func tappedProjectImage() {
    self.tappedProjectImageProperty.value = ()
  }

  public let body: Signal<String, Never>
  public let cellAccessibilityLabel: Signal<String, Never>
  public let notifyDelegateTappedProjectImage: Signal<Activity, Never>
  public let projectButtonAccessibilityLabel: Signal<String, Never>
  public let projectImageURL: Signal<URL?, Never>
  public let projectName: Signal<String, Never>
  public let sequenceTitle: Signal<NSAttributedString, Never>
  public let title: Signal<String, Never>

  public var inputs: ActivityUpdateViewModelInputs { return self }
  public var outputs: ActivityUpdateViewModelOutputs { return self }
}

private let decimalCharacterSet = NSCharacterSet.decimalDigits.inverted

private func updatePostedString(forActivity activity: Activity) -> NSAttributedString {
  let updateNum = Format.wholeNumber(activity.update?.sequence ?? 1)
  let time = Format.relative(secondsInUTC: activity.createdAt)
  let fullString = Strings.dashboard_activity_update_number_posted_time_count_days_ago(
    space: " ",
    update_number: updateNum,
    time_count_days_ago: time
  )

  let attributedString = fullString.simpleHtmlAttributedString(
    base: [
      NSAttributedString.Key.font: UIFont.ksr_footnote(),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
    ],
    bold: [
      NSAttributedString.Key.font: UIFont.ksr_headline(size: 13.0),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
    ]
  ) ?? .init(string: "")

  let mutableString = NSMutableAttributedString(attributedString: attributedString)

  let timeNumber = time.components(separatedBy: decimalCharacterSet).first

  if let timeRange = mutableString.string.range(of: time), let timeNumber = timeNumber {
    let timeStartIndex = mutableString.string
      .distance(from: mutableString.string.startIndex, to: timeRange.lowerBound)
    let timeNumberStartIndex = mutableString.string
      .distance(from: time.startIndex, to: timeNumber.startIndex)

    mutableString.addAttributes(
      [
        NSAttributedString.Key.font: UIFont.ksr_headline(size: 13.0),
        NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
      ],
      range: NSRange(location: timeStartIndex + timeNumberStartIndex, length: timeNumber.count)
    )
  }

  return mutableString
}
