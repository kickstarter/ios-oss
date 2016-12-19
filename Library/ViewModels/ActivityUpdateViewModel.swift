import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ActivityUpdateViewModelInputs {
  /// Call to configure with the activity.
  func configureWith(activity: Activity)

  /// Call when the project image is tapped.
  func tappedProjectImage()
}

public protocol ActivityUpdateViewModelOutputs {
  /// Emits the update's body to be displayed.
  var body: Signal<String, NoError> { get }

  /// Emits the cell's accessibility label to be read by voiceover.
  var cellAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits when we should notify the delegate that the project image button was tapped.
  var notifyDelegateTappedProjectImage: Signal<Activity, NoError> { get }

  /// Emits the project button's accessibility label to be read by voiceover.
  var projectButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the project image URL to be displayed.
  var projectImageURL: Signal<NSURL?, NoError> { get }

  /// Emits the project name to be displayed.
  var projectName: Signal<String, NoError> { get }

  /// Emits an attributed string for the update sequence title.
  var sequenceTitle: Signal<NSAttributedString, NoError> { get }

  /// Emits the update title to be displayed.
  var title: Signal<String, NoError> { get }
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

    self.projectImageURL = project.map { $0.photo.med }.map(NSURL.init(string:))

    self.projectName = project.map { $0.name }
    self.projectButtonAccessibilityLabel = self.projectName

    self.title = update.map { $0.title }

    self.sequenceTitle = activity.map(updatePostedString(forActivity:))

    self.notifyDelegateTappedProjectImage = activity
      .takeWhen(self.tappedProjectImageProperty.signal)

    self.cellAccessibilityLabel = combineLatest(project, self.sequenceTitle)
      .map { project, postedText in "\(project.name) \(postedText.string)" }
  }

  fileprivate let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity: Activity) {
    self.activityProperty.value = activity
  }
  fileprivate let tappedProjectImageProperty = MutableProperty()
  public func tappedProjectImage() {
    self.tappedProjectImageProperty.value = ()
  }

  public let body: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let notifyDelegateTappedProjectImage: Signal<Activity, NoError>
  public let projectButtonAccessibilityLabel: Signal<String, NoError>
  public let projectImageURL: Signal<NSURL?, NoError>
  public let projectName: Signal<String, NoError>
  public let sequenceTitle: Signal<NSAttributedString, NoError>
  public let title: Signal<String, NoError>

  public var inputs: ActivityUpdateViewModelInputs { return self }
  public var outputs: ActivityUpdateViewModelOutputs { return self }
}

private let decimalCharacterSet = NSCharacterSet.decimalDigitCharacterSet.invertedSet

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
        NSFontAttributeName: UIFont.ksr_footnote(),
        NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
      ],
      bold: [
        NSFontAttributeName: UIFont.ksr_headline(size: 13.0),
        NSForegroundColorAttributeName: UIColor.ksr_text_green_700
      ]
    ) ?? NSAttributedString(string: "")

  let mutableString = NSMutableAttributedString(attributedString: attributedString)

  let timeNumber = time.componentsSeparatedByCharactersInSet(decimalCharacterSet).first

  if let timeRange = mutableString.string.rangeOfString(time), let timeNumber = timeNumber {
    let timeStartIndex = mutableString.string.startIndex.distanceTo(timeRange.startIndex)
    let timeNumberStartIndex = time.startIndex.distanceTo(timeNumber.startIndex)

    mutableString.addAttributes(
      [NSFontAttributeName: UIFont.ksr_headline(size: 13.0)],
      range: NSRange(location: timeStartIndex + timeNumberStartIndex, length: timeNumber.characters.count)
    )
  }

  return mutableString
}
