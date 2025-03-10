import KsApi
import ReactiveSwift
import UIKit

public protocol ProjectsCardViewModelInputs {
  func configureWith(project: Project)
}

public protocol ProjectsCardViewModelOutputs {
  /// Emits the project's photo URL to be displayed.
  var projectImageUrl: Signal<URL?, Never> { get }

  /// Emits text for the project status label. (days left, ended, launching soon, late pledges active)
  var projectStatus: Signal<String, Never> { get }

  /// Emits image for the project status based on the project status label.
  var projectStatusImage: Signal<UIImage?, Never> { get }

  /// Emits project name to be displayed.
  var projectTitle: Signal<String, Never> { get }

  /// Emits the project's funding progress amount to be displayed.
  var progress: Signal<Float, Never> { get }

  /// Emits a color for the progress bar.
  var progressBarColor: Signal<UIColor, Never> { get }

  /// Emits to hide information about pledging when project is prelaunch
  var prelaunchProject: Signal<Bool, Never> { get }
}

public protocol SimilarProjectsCardViewModelType {
  var inputs: ProjectsCardViewModelInputs { get }
  var outputs: ProjectsCardViewModelOutputs { get }
}

public final class SimilarProjectsCardViewModel: SimilarProjectsCardViewModelType,
  ProjectsCardViewModelInputs,
  ProjectsCardViewModelOutputs {
  public init() {
    let project = self.projectProperty.signal.skipNil()

    self.projectImageUrl = project.map { URL(string: $0.photo.full) }

    self.projectStatus = project.map(projectStatus(for:))

    self.projectStatusImage = project.map(projectStatusImage(for:))

    self.projectTitle = project.map { $0.name }

    self.progress = project.map { $0.stats.fundingProgress }

    self.progressBarColor = project.map(progressBarColorForProject)

    self.prelaunchProject = project.map(isProjectPrelaunch)
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let projectImageUrl: Signal<URL?, Never>
  public let projectStatus: Signal<String, Never>
  public let projectStatusImage: Signal<UIImage?, Never>
  public let projectTitle: Signal<String, Never>
  public let progress: Signal<Float, Never>
  public let progressBarColor: Signal<UIColor, Never>
  public let prelaunchProject: Signal<Bool, Never>

  public var inputs: ProjectsCardViewModelInputs { return self }
  public var outputs: ProjectsCardViewModelOutputs { return self }
}

// TODO: Update hardcoded strings
private func projectStatus(for project: Project) -> String {
  guard !isProjectPrelaunch(project) else { return "Launching Soon" }

  guard !project.isInPostCampaignPledgingPhase else { return "Late pledges active" }

  let percentage = Format.percentage(project.stats.percentFunded)

  switch project.state {
  case .live:
    guard let deadline = project.dates.deadline else {
      return ""
    }

    let duration = Format.duration(secondsInUTC: deadline, abbreviate: true, useToGo: false)

    return Strings.Time_left_left(time_left: "\(duration.time) \(duration.unit)") + " • " + Strings
      .percentage_funded(percentage: percentage)
  case .successful, .failed:
    return "Ended" + " • " + Strings
      .percentage_funded(percentage: percentage)
  default:
    return ""
  }
}

private func projectStatusImage(for project: Project) -> UIImage? {
  guard !project.isInPostCampaignPledgingPhase else { return UIImage(named: "icon-late-pledge-timer") }

  guard !isProjectPrelaunch(project) else { return UIImage(named: "icon-launching-soon") }

  switch project.state {
  case .successful, .failed:
    return UIImage(named: "icon-project-ended-flag")
  case .live:
    return UIImage(named: "icon-timer")
  default:
    return nil
  }
}

private func isProjectPrelaunch(_ project: Project) -> Bool {
  switch (project.displayPrelaunch, project.prelaunchActivated, project.dates.launchedAt) {
  // GraphQL requests using ProjectFragment will populate displayPrelaunch and prelaunchActivated
  case (.some(true), .some(true), _):
    return true

  // V1 requests may not return displayPrelaunch and prelaunchActivated.
  // But if no launch date is set, we can assume this is a prelaunch project.
  case let (.none, _, .some(timeValue)):
    return timeValue <= 0
  default:
    return false
  }
}

private func progressBarColorForProject(_ project: Project) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_create_500
  default:
    return .ksr_support_200
  }
}
