import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol MostPopularSearchProjectCellViewModelInputs {
  func configureWith(project: Project)
}

public protocol MostPopularSearchProjectCellViewModelOutputs {
  /// Emits text for metadata label.
  var metadataText: Signal<String, Never> { get }

  /// Emits the attributed string for the percent funded label.
  var percentFundedText: Signal<NSAttributedString, Never> { get }

  /// Emits the project's funding progress amount to be displayed.
  var progress: Signal<Float, Never> { get }

  /// Emits a color for the progress bar.
  var progressBarColor: Signal<UIColor, Never> { get }

  /// Emits the project's photo URL to be displayed.
  var projectImageUrl: Signal<URL?, Never> { get }

  /// Emits project name to be displayed.
  var projectName: Signal<NSAttributedString, Never> { get }
}

public protocol MostPopularSearchProjectCellViewModelType {
  var inputs: MostPopularSearchProjectCellViewModelInputs { get }
  var outputs: MostPopularSearchProjectCellViewModelOutputs { get }
}

public final class MostPopularSearchProjectCellViewModel: MostPopularSearchProjectCellViewModelType,
  MostPopularSearchProjectCellViewModelInputs, MostPopularSearchProjectCellViewModelOutputs {
  public init() {
    let project = self.projectProperty.signal.skipNil()

    self.projectImageUrl = project.map { URL(string: $0.photo.full) }

    self.projectName = project.map(titleString(for:))

    self.progress = project.map { $0.stats.fundingProgress }

    self.progressBarColor = project.map(progressBarColorForProject)

    self.percentFundedText = project.map(percentFundedString(for:))

    self.metadataText = project.map(metadataString(for:))
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let metadataText: Signal<String, Never>
  public let percentFundedText: Signal<NSAttributedString, Never>
  public let progress: Signal<Float, Never>
  public let progressBarColor: Signal<UIColor, Never>
  public let projectImageUrl: Signal<URL?, Never>
  public let projectName: Signal<NSAttributedString, Never>

  public var inputs: MostPopularSearchProjectCellViewModelInputs { return self }
  public var outputs: MostPopularSearchProjectCellViewModelOutputs { return self }
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
      NSAttributedString.Key.font: UIFont.ksr_caption1().bolded,
      NSAttributedString.Key.foregroundColor: UIColor.ksr_create_700
    ])
  default:
    return NSAttributedString(string: percentage, attributes: [
      NSAttributedString.Key.font: UIFont.ksr_caption1().bolded,
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400
    ])
  }
}

private func progressBarColorForProject(_ project: Project) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_create_700
  default:
    return .ksr_support_400
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
