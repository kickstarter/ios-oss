import Foundation
import KsApi
import ReactiveSwift
import UIKit

public protocol BackerDashboardProjectCellViewModelInputs {
  /// Call to configure with a backed project.
  func configureWith(project: any BackerDashboardProjectCellViewModel.ProjectModel)
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

  /// Emits to hide information about pledging when project is prelaunch
  var prelaunchProject: Signal<Bool, Never> { get }
}

public protocol BackerDashboardProjectCellViewModelType {
  var inputs: BackerDashboardProjectCellViewModelInputs { get }
  var outputs: BackerDashboardProjectCellViewModelOutputs { get }
}

public final class BackerDashboardProjectCellViewModel: BackerDashboardProjectCellViewModelType,
  BackerDashboardProjectCellViewModelInputs, BackerDashboardProjectCellViewModelOutputs {
  public protocol ProjectModel {
    var id: Int { get }
    var name: String { get }
    var state: Project.State { get }
    var imageURL: String { get }
    var fundingProgress: Float { get }
    var percentFunded: Int { get }
    var displayPrelaunch: Bool? { get }
    var prelaunchActivated: Bool? { get }
    var launchedAt: TimeInterval? { get }
    var deadline: TimeInterval? { get }
    var isStarred: Bool? { get }
  }

  public init() {
    let project = self.projectProperty.signal.skipNil()

    self.projectTitleText = project.map(titleString(for:))

    self.photoURL = project.map { URL(string: $0.imageURL) }

    self.progress = project.map { $0.fundingProgress }

    self.metadataBackgroundColor = project.map(metadataBackgroundColorForProject)

    self.metadataText = project.map(metadataString(for:))

    self.metadataIconIsHidden = project.map { project in
      guard !isProjectPrelaunch(project) else { return true }

      return project.state != .live
    }

    self.percentFundedText = project.map(percentFundedString(for:))

    self.progressBarColor = project.map(progressBarColorForProject)

    self.savedIconIsHidden = project.map { $0.isStarred != .some(true) }

    self.prelaunchProject = project.map(isProjectPrelaunch)
  }

  fileprivate let projectProperty = MutableProperty<(any ProjectModel)?>(nil)
  public func configureWith(project: any ProjectModel) {
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
  public let prelaunchProject: Signal<Bool, Never>
  public let savedIconIsHidden: Signal<Bool, Never>

  public var inputs: BackerDashboardProjectCellViewModelInputs { return self }
  public var outputs: BackerDashboardProjectCellViewModelOutputs { return self }
}

private func metadataString(for project: any BackerDashboardProjectCellViewModel.ProjectModel) -> String {
  guard !isProjectPrelaunch(project) else { return Strings.Coming_soon() }

  switch project.state {
  case .live:
    guard let deadline = project.deadline else {
      return ""
    }

    let duration = Format.duration(secondsInUTC: deadline, abbreviate: true, useToGo: false)
    return "\(duration.time) \(duration.unit)"
  default:
    return stateString(for: project)
  }
}

private func percentFundedString(
  for project: any BackerDashboardProjectCellViewModel
    .ProjectModel
) -> NSAttributedString {
  let percentage = Format.percentage(project.percentFunded)

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

private func progressBarColorForProject(
  _ project: any BackerDashboardProjectCellViewModel
    .ProjectModel
) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_create_700
  default:
    return .ksr_support_300
  }
}

private func metadataBackgroundColorForProject(
  _ project: any BackerDashboardProjectCellViewModel
    .ProjectModel
) -> UIColor {
  guard !isProjectPrelaunch(project) else {
    return .ksr_create_700
  }

  switch project.state {
  case .live, .successful:
    return .ksr_create_700
  default:
    return .ksr_support_700
  }
}

private func titleString(
  for project: any BackerDashboardProjectCellViewModel
    .ProjectModel
) -> NSAttributedString {
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

private func stateString(for project: any BackerDashboardProjectCellViewModel.ProjectModel) -> String {
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

private func isProjectPrelaunch(_ project: any BackerDashboardProjectCellViewModel.ProjectModel) -> Bool {
  switch (project.displayPrelaunch, project.prelaunchActivated, project.launchedAt) {
  // GraphQL requests using ProjectFragment will populate displayPrelaunch and prelaunchActivated
  case (.some(true), .some(true), _):
    return true

  // V1 requests may not return displayPrelaunch and prelaunchActivated.
  // But if no launch date is set, we can assume this is a prelaunch project.
  case let (.none, .none, .some(timeValue)):
    return timeValue <= 0
  default:
    return false
  }
}
