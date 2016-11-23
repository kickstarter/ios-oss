import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ActivityyProjectStatusViewModelInputs {
  func configureWith(activity activity: Activity)
}

public protocol ActivityyProjectStatusViewModelOutputs {
  var fundingBarColor: Signal<UIColor, NoError> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var fundingProgressPercentage: Signal<Float, NoError> { get }
  var metadataBackgroundColor: Signal<UIColor, NoError> { get }
  var metadataText: Signal<String, NoError> { get }
  var percentFundedText: Signal<NSAttributedString, NoError> { get }
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String, NoError> { get }
}

public protocol ActivityyProjectStatusViewModelType {
  var inputs: ActivityyProjectStatusViewModelInputs { get }
  var outputs: ActivityyProjectStatusViewModelOutputs { get }
}

public final class ActivityyProjectStatusViewModel: ActivityyProjectStatusViewModelType,
  ActivityyProjectStatusViewModelInputs, ActivityyProjectStatusViewModelOutputs {

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()
    let project = activity.map { $0.project }.ignoreNil()

    self.fundingBarColor = activity.map {
      return progressBarColor(forActivityCategory: $0.category)
    }

    self.fundingProgressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.metadataBackgroundColor = activity.map {
      return metadataColor(forActivityCategory: $0.category)
    }

    self.metadataText = activity.map {
      let creator = $0.project?.creator
      return metadataString(forActivityCategory: $0.category,
        isCreatorUser: AppEnvironment.current.currentUser == creator,
        friendName: creator?.name ?? "")
    }

    self.percentFundedText = project
      .map {
        let percentage = Format.percentage($0.stats.percentFunded)
        let funded = Strings.percentage_funded(percentage: percentage)

        let fundedAttributedString = NSMutableAttributedString(string: funded, attributes: [
          NSFontAttributeName: UIFont.ksr_caption1(),
          NSForegroundColorAttributeName: UIColor.ksr_navy_500
        ])

        if let percentRange = funded.rangeOfString(percentage) {
          let percentStartIndex = funded.startIndex.distanceTo(percentRange.startIndex)
          fundedAttributedString.addAttributes([
            NSFontAttributeName: UIFont.ksr_headline(size: 12.0),
            NSForegroundColorAttributeName:
              ($0.state == .canceled
              || $0.state == .failed
              || $0.state == .suspended) ? UIColor.ksr_text_navy_500 : UIColor.ksr_green_500
          ], range: NSRange(location: percentStartIndex, length: percentage.characters.count))
        }

        return fundedAttributedString
    }

    self.projectImageURL = project.map { $0.photo.full }.map(NSURL.init(string:))

    self.projectName = project.map { $0.name }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  public let fundingBarColor: Signal<UIColor, NoError>
  public let fundingProgressPercentage: Signal<Float, NoError>
  public let metadataBackgroundColor: Signal<UIColor, NoError>
  public let metadataText: Signal<String, NoError>
  public let percentFundedText: Signal<NSAttributedString, NoError>
  public let projectImageURL: Signal<NSURL?, NoError>
  public let projectName: Signal<String, NoError>

  public var inputs: ActivityyProjectStatusViewModelInputs { return self }
  public var outputs: ActivityyProjectStatusViewModelOutputs { return self }
}

private func progressBarColor(forActivityCategory category: Activity.Category) -> UIColor {
  switch category {
  case .cancellation, .failure, .suspension:
    return .ksr_navy_500
  case .launch, .success:
    return .ksr_green_400
  default:
    return .ksr_green_400
  }
}

private func metadataColor(forActivityCategory category: Activity.Category) -> UIColor {
  switch category {
  case .cancellation, .failure, .suspension:
    return .ksr_navy_500
  case .launch:
    return .ksr_navy_700
  case .success:
    return .ksr_green_700
  default:
    return .ksr_green_700
  }
}

private func metadataString(forActivityCategory category: Activity.Category,
                                                isCreatorUser: Bool, friendName: String) -> String {
  switch category {
  case .cancellation:
    return "Project Cancelled."
  case .failure:
    return "Unsuccessfully Funded."
  case .launch:
    return isCreatorUser ? "You Launched!" : "\(friendName) launched a project!"
  case .success:
    return "Successfully Funded!"
  case .suspension:
    "Project Suspended."
  default:
    return ""
  }
  return ""
}
