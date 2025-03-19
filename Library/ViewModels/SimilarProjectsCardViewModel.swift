import Kingfisher
import KsApi
import ReactiveSwift
import UIKit

public protocol ProjectsCardViewModelInputs {
  func configureWith(project: any SimilarProject)
}

public protocol ProjectsCardViewModelOutputs {
  /// Emits the project's photo URL to be displayed.
  var projectImageSource: Signal<Kingfisher.Source?, Never> { get }

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

    self.projectImageSource = project.map { $0.image }

    self.projectStatus = project.map(getProjectStatus(for:))

    self.projectStatusImage = project.map(getProjectStatusImage(for:))

    self.projectTitle = project.map { $0.name }

    self.progress = project.map { Float($0.percentFunded) / 100 }

    self.progressBarColor = project.map(progressBarColorForProject)

    self.prelaunchProject = project.map(isProjectPrelaunch)
  }

  fileprivate let projectProperty = MutableProperty<(any SimilarProject)?>(nil)
  public func configureWith(project: any SimilarProject) {
    self.projectProperty.value = project
  }

  public let projectImageSource: Signal<Kingfisher.Source?, Never>
  public let projectStatus: Signal<String, Never>
  public let projectStatusImage: Signal<UIImage?, Never>
  public let projectTitle: Signal<String, Never>
  public let progress: Signal<Float, Never>
  public let progressBarColor: Signal<UIColor, Never>
  public let prelaunchProject: Signal<Bool, Never>

  public var inputs: ProjectsCardViewModelInputs { return self }
  public var outputs: ProjectsCardViewModelOutputs { return self }
}

private func getProjectStatus(for project: any SimilarProject) -> String {
  guard !isProjectPrelaunch(project) else { return Strings.Launching_soon() }

  let percentage = Format.percentage(project.percentFunded)

  guard !(project.isInPostCampaignPledgingPhase && project.isPostCampaignPledgingEnabled)
  else { return Strings.Late_pledges_active() + " • " + Strings
    .percentage_funded(percentage: percentage)
  }

  switch project.state {
  case .live:
    guard let deadline = project.deadlineAt?.timeIntervalSince1970 else {
      return ""
    }

    let duration = Format.duration(secondsInUTC: deadline, abbreviate: true, useToGo: false)

    return Strings.Time_left_left(time_left: "\(duration.time) \(duration.unit)") + " • " + Strings
      .percentage_funded(percentage: percentage)
  case .successful, .failed:
    return Strings.Ended() + " • " + Strings
      .percentage_funded(percentage: percentage)
  default:
    return ""
  }
}

private func getProjectStatusImage(for project: any SimilarProject) -> UIImage? {
//  guard !(project.isInPostCampaignPledgingPhase && project.isPostCampaignPledgingEnabled)
//  else { return UIImage(named: "icon-late-pledge-timer") }

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

private func isProjectPrelaunch(_ project: any SimilarProject) -> Bool {
  project.shouldDisplayPrelaunch && project.isPrelaunchActivated
}

private func progressBarColorForProject(_ project: any SimilarProject) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_create_500
  default:
    return .ksr_support_200
  }
}
