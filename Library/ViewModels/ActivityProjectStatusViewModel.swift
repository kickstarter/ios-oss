import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ActivityProjectStatusViewModelInputs {
  /// Call to configure with an Activity.
  func configureWith(activity: Activity)
}

public protocol ActivityProjectStatusViewModelOutputs {
  /// Emits a color for the funding progress bar.
  var fundingBarColor: Signal<UIColor, Never> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var fundingProgressPercentage: Signal<Float, Never> { get }

  /// Emits a color for metadata view background.
  var metadataBackgroundColor: Signal<UIColor, Never> { get }

  /// Emits text for the metadata label.
  var metadataText: Signal<String, Never> { get }

  /// Emits an attributed string for percent funded label.
  var percentFundedText: Signal<NSAttributedString, Never> { get }

  /// Emits a url to the project image.
  var projectImageURL: Signal<URL?, Never> { get }

  /// Emits text for the project name label.
  var projectName: Signal<String, Never> { get }
}

public protocol ActivityProjectStatusViewModelType {
  var inputs: ActivityProjectStatusViewModelInputs { get }
  var outputs: ActivityProjectStatusViewModelOutputs { get }
}

public final class ActivityProjectStatusViewModel: ActivityProjectStatusViewModelType,
  ActivityProjectStatusViewModelInputs, ActivityProjectStatusViewModelOutputs {
  public init() {
    let activity = self.activityProperty.signal.skipNil()
    let project = activity.map { $0.project }.skipNil()

    self.fundingBarColor = activity.map { progressBarColor(forActivityCategory: $0.category) }

    self.fundingProgressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.metadataBackgroundColor = activity.map { metadataColor(forActivityCategory: $0.category) }

    self.metadataText = activity.map {
      let creator = $0.project?.creator
      return metadataString(
        forActivityCategory: $0.category,
        isCreatorUser: AppEnvironment.current.currentUser == creator,
        friendName: creator?.name ?? ""
      )
    }

    self.percentFundedText = activity.map(percentFundedString(forActivity:))

    self.projectImageURL = project.map { $0.photo.full }.map(URL.init(string:))

    self.projectName = project.map { $0.name }
  }

  fileprivate let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity: Activity) {
    self.activityProperty.value = activity
  }

  public let fundingBarColor: Signal<UIColor, Never>
  public let fundingProgressPercentage: Signal<Float, Never>
  public let metadataBackgroundColor: Signal<UIColor, Never>
  public let metadataText: Signal<String, Never>
  public let percentFundedText: Signal<NSAttributedString, Never>
  public let projectImageURL: Signal<URL?, Never>
  public let projectName: Signal<String, Never>

  public var inputs: ActivityProjectStatusViewModelInputs { return self }
  public var outputs: ActivityProjectStatusViewModelOutputs { return self }
}

private func progressBarColor(forActivityCategory category: Activity.Category) -> UIColor {
  switch category {
  case .cancellation, .failure, .suspension:
    return LegacyColors.ksr_support_700.uiColor()
  case .launch, .success:
    return LegacyColors.ksr_create_700.uiColor()
  default:
    return LegacyColors.ksr_create_700.uiColor()
  }
}

private func metadataColor(forActivityCategory category: Activity.Category) -> UIColor {
  switch category {
  case .cancellation, .failure, .suspension:
    return LegacyColors.ksr_support_700.uiColor()
  case .launch:
    return LegacyColors.ksr_create_700.uiColor()
  case .success:
    return LegacyColors.ksr_create_700.uiColor()
  default:
    return LegacyColors.ksr_create_700.uiColor()
  }
}

private func metadataString(
  forActivityCategory category: Activity.Category,
  isCreatorUser: Bool, friendName: String
) -> String {
  switch category {
  case .cancellation:
    return Strings.Project_Cancelled()
  case .failure:
    return Strings.Unsuccessfully_Funded()
  case .launch:
    return isCreatorUser
      ? Strings.You_Launched()
      : Strings.Friend_name_launched_a_project(friend_name: friendName)
  case .success:
    return Strings.activity_successfully_funded()
  case .suspension:
    return Strings.Project_Suspended()
  default:
    return ""
  }
}

private func percentFundedString(forActivity activity: Activity) -> NSAttributedString {
  guard let project = activity.project else { return NSAttributedString(string: "") }

  let percentage = Format.percentage(project.stats.percentFunded)

  return NSAttributedString(string: percentage, attributes: [
    NSAttributedString.Key.font: UIFont.ksr_caption1(size: 10),
    NSAttributedString.Key.foregroundColor: LegacyColors.ksr_create_700.uiColor()
  ])
}
