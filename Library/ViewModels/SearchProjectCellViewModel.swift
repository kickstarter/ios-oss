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
  var fundingLargeLabelText: Signal<NSAttributedString, NoError> { get }
  var fundingSmallLabelText: Signal<NSAttributedString, NoError> { get }
  var projectImageUrlMed: Signal<URL?, NoError> { get }
  var projectImageUrlFull: Signal<URL?, NoError> { get }
  var projectNameLabelText: Signal<String, NoError> { get }
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
      let string = Strings.percentage_funded(percentage: "<b>\(Format.percentage($0.stats.percentFunded))</b>")
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
      let string = Strings.percentage_funded(percentage: "<b>\(Format.percentage($0.stats.percentFunded))</b>")
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

    self.projectNameLabelText = project.map { $0.name }
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
  public let projectNameLabelText: Signal<String, NoError>

  public var inputs: SearchProjectCellViewModelInputs { return self }
  public var outputs: SearchProjectCellViewModelOutputs { return self }
}
