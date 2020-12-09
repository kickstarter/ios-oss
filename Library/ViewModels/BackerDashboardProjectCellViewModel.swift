import Foundation
import KsApi
import ReactiveSwift
import UIKit

public protocol BackerDashboardProjectCellViewModelInputs {
  /// Call to configure with a backed project.
  func configureWith(project: Project)
}

public protocol BackerDashboardProjectCellViewModelOutputs {
  /// Emits a boolean whether to show the metadata timer icon.
  var metadataIconIsHidden: Signal<Bool, Never> { get }

  /// Emits text for the metadata label.
  var metadataText: Signal<String, Never> { get }

  /// Emits a color for the metadata background view.
  var metadataBackgroundColor: Signal<UIColor, Never> { get }

  /// Emits attributed text for the percent funded label.
  var percentFundedText: Signal<NSAttributedString, Never> { get }

  /// Emits the project's photo URL to be displayed.
  var photoURL: Signal<URL?, Never> { get }

  /// Emits the project's funding progress amount to be displayed.
  var progress: Signal<Float, Never> { get }

  /// Emits a color for the progress bar.
  var progressBarColor: Signal<UIColor, Never> { get }

  /// Emits the project name to be displayed.
  var projectTitleText: Signal<NSAttributedString, Never> { get }

  /// Emits a boolean when the saved icon is hidden or not.
  var savedIconIsHidden: Signal<Bool, Never> { get }
}

public protocol BackerDashboardProjectCellViewModelType {
  var inputs: BackerDashboardProjectCellViewModelInputs { get }
  var outputs: BackerDashboardProjectCellViewModelOutputs { get }
}

public final class BackerDashboardProjectCellViewModel: BackerDashboardProjectCellViewModelType,
  BackerDashboardProjectCellViewModelInputs, BackerDashboardProjectCellViewModelOutputs {
  public init() {
    let project = self.projectProperty.signal.skipNil()

    self.projectTitleText = project.map(titleString(for:))

    self.photoURL = project.map { URL(string: $0.photo.full) }

    self.progress = project.map { $0.stats.fundingProgress }

    self.metadataBackgroundColor = project.map(metadataBackgroundColorForProject)

    self.metadataText = project.map(metadataString(for:))

    self.metadataIconIsHidden = project.map { $0.state != .live }

    self.percentFundedText = project.map(percentFundedString(for:))

    self.progressBarColor = project.map(progressBarColorForProject)

    self.savedIconIsHidden = project.map { $0.personalization.isStarred != .some(true) }
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let metadataBackgroundColor: Signal<UIColor, Never>
  public let metadataIconIsHidden: Signal<Bool, Never>
  public let metadataText: Signal<String, Never>
  public let percentFundedText: Signal<NSAttributedString, Never>
  public let photoURL: Signal<URL?, Never>
  public let progress: Signal<Float, Never>
  public let progressBarColor: Signal<UIColor, Never>
  public let projectTitleText: Signal<NSAttributedString, Never>
  public let savedIconIsHidden: Signal<Bool, Never>

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
      NSAttributedString.Key.font: UIFont.ksr_caption1(size: 10),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_create_700
    ])
  default:
    return NSAttributedString(string: percentage, attributes: [
      NSAttributedString.Key.font: UIFont.ksr_caption1(size: 10),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400
    ])
  }
}

private func progressBarColorForProject(_ project: Project) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_create_700
  default:
    return .ksr_support_300
  }
}

private func metadataBackgroundColorForProject(_ project: Project) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_create_700
  default:
    return .ksr_support_700
  }
}

private func titleString(for project: Project) -> NSAttributedString {
  switch project.state {
  case .live, .successful:
    return NSAttributedString(string: project.name, attributes: [
      NSAttributedString.Key.font: UIFont.ksr_caption1(size: 13),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
    ])
  default:
    return NSAttributedString(string: project.name, attributes: [
      NSAttributedString.Key.font: UIFont.ksr_caption1(size: 13),
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400
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
