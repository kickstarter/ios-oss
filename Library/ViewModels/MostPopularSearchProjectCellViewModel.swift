import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol MostPopularSearchProjectCellViewModelInputs {
  func configureWith(project: Project)
}

public protocol MostPopularSearchProjectCellViewModelOutputs {
  var deadlineSubtitleLabelText: Signal<String, NoError> { get }
  var deadlineTitleLabelText: Signal<String, NoError> { get }
  var fundingSubtitleLabelText: Signal<String, NoError> { get }
  var fundingTitleLabelText: Signal<NSAttributedString, NoError> { get }
  var projectImageUrl: Signal<URL?, NoError> { get }
  var projectNameLabelText: Signal<String, NoError> { get }
}

public protocol MostPopularSearchProjectCellViewModelType {
  var inputs: MostPopularSearchProjectCellViewModelInputs { get }
  var outputs: MostPopularSearchProjectCellViewModelOutputs { get }
}

public final class MostPopularSearchProjectCellViewModel: MostPopularSearchProjectCellViewModelType,
MostPopularSearchProjectCellViewModelInputs, MostPopularSearchProjectCellViewModelOutputs {

  public init() {
    let project = self.projectProperty.signal.skipNil()

    let deadlineTitleAndSubtitle = project
      .map { Format.duration(secondsInUTC: $0.dates.deadline, useToGo: true) }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

   self.fundingTitleLabelText = project.map {
      let string = Strings.percentage_funded(
        percentage: "<b>\(Format.percentage($0.stats.percentFunded))</b>")
      return string.simpleHtmlAttributedString(base: [
        NSFontAttributeName: UIFont.ksr_subhead(size: 14.0),
        NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
        ],
        bold: [
          NSFontAttributeName: UIFont.ksr_headline(size: 14.0),
          NSForegroundColorAttributeName: UIColor.ksr_text_navy_700
        ]) ?? NSAttributedString(string: "")
    }

    self.fundingSubtitleLabelText = .empty

    self.projectImageUrl = project.map { URL(string: $0.photo.full) }

    self.projectNameLabelText = project.map(Project.lens.name.view)
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let fundingSubtitleLabelText: Signal<String, NoError>
  public let fundingTitleLabelText: Signal<NSAttributedString, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let projectNameLabelText: Signal<String, NoError>

  public var inputs: MostPopularSearchProjectCellViewModelInputs { return self }
  public var outputs: MostPopularSearchProjectCellViewModelOutputs { return self }
}
