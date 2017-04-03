import Foundation
import KsApi
import ReactiveSwift
import Result

public protocol BackerDashboardProjectCellViewModelInputs {
  /// Call to configure with a backed project.
  func configureWith(project: Project)
}

public protocol BackerDashboardProjectCellViewModelOutputs {
  /// Emits a boolean whether to show the metadata timer icon.
  var metadataIconIsHidden: Signal<Bool, NoError> { get }

  /// Emits text for the metadata label.
  var metadataText: Signal<String, NoError> { get }

  /// Emits attributed text for the percent funded label.
  var percentFundedText: Signal<NSAttributedString, NoError> { get }

  /// Emits the project's photo URL to be displayed.
  var photoURL: Signal<URL?, NoError> { get }

  /// Emits the project's funding progress amount to be displayed.
  var progress: Signal<Float, NoError> { get }

  /// Emits a color for the progress bar.
  var progressBarColor: Signal<UIColor, NoError> { get }

  /// Emits the project name to be displayed.
  var projectTitleText: Signal<NSAttributedString, NoError> { get }

  /// Emits a boolean when the saved icon is hidden or not.
  var savedIconIsHidden: Signal<Bool, NoError> { get }
}

public protocol BackerDashboardProjectCellViewModelType {
  var inputs: BackerDashboardProjectCellViewModelInputs { get }
  var outputs: BackerDashboardProjectCellViewModelOutputs { get }
}

public final class BackerDashboardProjectCellViewModel: BackerDashboardProjectCellViewModelType,
  BackerDashboardProjectCellViewModelInputs, BackerDashboardProjectCellViewModelOutputs {
  public init() {
    let project = projectProperty.signal.skipNil()

    self.projectTitleText = project.map(titleString(for:))

    self.photoURL = project.map { URL(string: $0.photo.full) }

    self.progress = project.map { $0.stats.fundingProgress }

    self.metadataText = project.map(metadataString(for:))

    self.metadataIconIsHidden = project.map { $0.state != .live }

    self.percentFundedText = project.map(percentFundedString(for:))

    self.progressBarColor = project.map(progressBarColor(for:))

    self.savedIconIsHidden = project.map { $0.personalization.isStarred != .some(true) }
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let metadataIconIsHidden: Signal<Bool, NoError>
  public let metadataText: Signal<String, NoError>
  public let percentFundedText: Signal<NSAttributedString, NoError>
  public let photoURL: Signal<URL?, NoError>
  public let progress: Signal<Float, NoError>
  public let progressBarColor: Signal<UIColor, NoError>
  public let projectTitleText: Signal<NSAttributedString, NoError>
  public let savedIconIsHidden: Signal<Bool, NoError>

  public var inputs: BackerDashboardProjectCellViewModelInputs { return self }
  public var outputs: BackerDashboardProjectCellViewModelOutputs { return self }
}

private func metadataString(for project: Project) -> String {
  switch project.state {
  case .live:
    let duration = Format.duration(secondsInUTC: project.dates.deadline, abbreviate: true, useToGo: false)
    return "\(duration.time) \(duration.unit)"
  default:
    return stateString(for: project)
  }
}

private func percentFundedString(for project: Project) -> NSAttributedString {
  let percentage = Format.percentage(project.stats.percentFunded)

  switch project.state {
  case .live, .successful:
    return NSAttributedString(string: percentage, attributes: [
      NSFontAttributeName: UIFont.ksr_caption1().bolded,
      NSForegroundColorAttributeName: UIColor.ksr_text_green_700
    ])
  default:
    return NSAttributedString(string: percentage, attributes: [
      NSFontAttributeName: UIFont.ksr_caption1().bolded,
      NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
    ])
  }
}

private func progressBarColor(for project: Project) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_green_500
  default:
    return .ksr_navy_500
  }
}

private func titleString(for project: Project) -> NSAttributedString {
  switch project.state {
  case .live, .successful:
    return NSAttributedString(string: project.name, attributes: [
      NSFontAttributeName: UIFont.ksr_caption1(size: 13),
      NSForegroundColorAttributeName: UIColor.ksr_text_navy_900
    ])
  default:
    return NSAttributedString(string: project.name, attributes: [
      NSFontAttributeName: UIFont.ksr_caption1(size: 13),
      NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
    ])
  }
}

private func stateString(for project: Project) -> String {
  switch project.state {
  case .canceled:
    return Strings.profile_projects_status_canceled()
  case .successful:
    return Strings.profile_projects_status_successful()
  case .suspended:
    return Strings.profile_projects_status_suspended()
  case .failed:
    return Strings.profile_projects_status_unsuccessful()
  default:
    return ""
  }
}
