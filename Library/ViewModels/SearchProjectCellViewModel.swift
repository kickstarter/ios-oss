import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SearchProjectCellViewModelInputs {
  func configureWith(project: Project)
}

public protocol SearchProjectCellViewModelOutputs {
  var deadlineSubtitleLabelText: Signal<String, NoError> { get }
  var deadlineTitleLabelText: Signal<String, NoError> { get }
  var fundingSmallLabelText: Signal<NSAttributedString, NoError> { get }
  var fundingLargeLabelText: Signal<NSAttributedString, NoError> { get }
  var projectImageUrlFull: Signal<URL?, NoError> { get }
  var projectImageUrlMed: Signal<URL?, NoError> { get }
  var projectName: Signal<String, NoError> { get }
  var projectNameLabelText: Signal<NSAttributedString, NoError> { get }
  var progress: Signal<Float, NoError> { get }
  var progressBarColor: Signal<UIColor, NoError> { get }
  var percentFundedText: Signal<NSAttributedString, NoError> { get }
  var metadataText: Signal<String, NoError> { get }
}

public protocol SearchProjectCellViewModelType {
  var inputs: SearchProjectCellViewModelInputs { get }
  var outputs: SearchProjectCellViewModelOutputs { get }
}

public final class SearchProjectCellViewModel: SearchProjectCellViewModelType,
SearchProjectCellViewModelInputs, SearchProjectCellViewModelOutputs {

  public init() {
    let project = self.projectProperty.signal.skipNil()

    let deadlineTitleAndSubtitle = project
      .map { Format.duration(secondsInUTC: $0.dates.deadline, useToGo: true) }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

    self.fundingLargeLabelText = project.map {
      let string = Strings.percentage_funded(
        percentage: "<b>\(Format.percentage($0.stats.percentFunded))</b>")
      return string.simpleHtmlAttributedString(base: [
        NSFontAttributeName: UIFont.ksr_subhead(size: 14.0),
        NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
        ],
        bold: [
          NSFontAttributeName: UIFont.ksr_headline(size: 14.0),
          NSForegroundColorAttributeName: UIColor.ksr_text_green_700
        ]) ?? NSAttributedString(string: "")
    }

    self.fundingSmallLabelText = project.map {
      let string = Strings.percentage_funded(
        percentage: "<b>\(Format.percentage($0.stats.percentFunded))</b>")
      return string.simpleHtmlAttributedString(base: [
        NSFontAttributeName: UIFont.ksr_subhead(size: 13.0),
        NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
        ],
                                               bold: [
                                                NSFontAttributeName: UIFont.ksr_headline(size: 13.0),
                                                NSForegroundColorAttributeName: UIColor.ksr_text_green_700
        ]) ?? NSAttributedString(string: "")
    }

    self.projectImageUrlMed = project.map { URL(string: $0.photo.med) }

    self.projectImageUrlFull = project.map { URL(string: $0.photo.full) }

    self.projectNameLabelText = project.map(titleString(for:))

    self.projectName = project.map { $0.name }

    self.progress = project.map { $0.stats.fundingProgress }

    self.progressBarColor = project.map(progressBarColor(for:))

    self.percentFundedText = project.map(percentFundedString(for:))

    self.metadataText = project.map(metadataString(for:))

  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let fundingLargeLabelText: Signal<NSAttributedString, NoError>
  public let fundingSmallLabelText: Signal<NSAttributedString, NoError>
  public let projectImageUrlMed: Signal<URL?, NoError>
  public let projectImageUrlFull: Signal<URL?, NoError>
  public let projectNameLabelText: Signal<NSAttributedString, NoError>

  public let percentFundedText: Signal<NSAttributedString, NoError>
  public let progress: Signal<Float, NoError>
  public let progressBarColor: Signal<UIColor, NoError>
  public let projectName: Signal<String, NoError>
  public let metadataText: Signal<String, NoError>

  public var inputs: SearchProjectCellViewModelInputs { return self }
  public var outputs: SearchProjectCellViewModelOutputs { return self }
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
