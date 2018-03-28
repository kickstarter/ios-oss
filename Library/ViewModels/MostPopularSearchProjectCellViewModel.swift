import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol MostPopularSearchProjectCellViewModelInputs {
  func configureWith(project: Project)
}

public protocol MostPopularSearchProjectCellViewModelOutputs {
  /// Emits text for metadata label.
  var metadataText: Signal<String, NoError> { get }

  /// Emits the attributed string for the percent funded label.
  var percentFundedText: Signal<NSAttributedString, NoError> { get }

  /// Emits the project's funding progress amount to be displayed.
  var progress: Signal<Float, NoError> { get }

  /// Emits a color for the progress bar.
  var progressBarColor: Signal<UIColor, NoError> { get }

  /// Emits the project's photo URL to be displayed.
  var projectImageUrl: Signal<URL?, NoError> { get }

  /// Emits project name to be displayed.
  var projectName: Signal<NSAttributedString, NoError> { get }
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

    self.progressBarColor = project.map(progressBarColor(for:))

    self.percentFundedText = project.map(percentFundedString(for:))

    self.metadataText = project.map(metadataString(for:))
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let metadataText: Signal<String, NoError>
  public let percentFundedText: Signal<NSAttributedString, NoError>
  public let progress: Signal<Float, NoError>
  public let progressBarColor: Signal<UIColor, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let projectName: Signal<NSAttributedString, NoError>

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
      NSAttributedStringKey.font: UIFont.ksr_caption1().bolded,
      NSAttributedStringKey.foregroundColor: UIColor.ksr_text_green_700
      ])
  default:
    return NSAttributedString(string: percentage, attributes: [
      NSAttributedStringKey.font: UIFont.ksr_caption1().bolded,
      NSAttributedStringKey.foregroundColor: UIColor.ksr_text_dark_grey_400
      ])
  }
}

private func progressBarColor(for project: Project) -> UIColor {
  switch project.state {
  case .live, .successful:
    return .ksr_green_500
  default:
    return .ksr_dark_grey_400
  }
}

private func titleString(for project: Project) -> NSAttributedString {
  switch project.state {
  case .live, .successful:
    return NSAttributedString(string: project.name, attributes: [
      NSAttributedStringKey.font: UIFont.ksr_caption1(size: 13),
      NSAttributedStringKey.foregroundColor: UIColor.ksr_text_dark_grey_900
      ])
  default:
    return NSAttributedString(string: project.name, attributes: [
      NSAttributedStringKey.font: UIFont.ksr_caption1(size: 13),
      NSAttributedStringKey.foregroundColor: UIColor.ksr_text_dark_grey_400
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
