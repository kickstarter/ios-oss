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
  var fundingTitleLabelText: Signal<String, NoError> { get }
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

    let fundingTitleAndSubtitleText = project.map { project -> (String?, String?) in
      let string = Strings.percentage_funded(percentage: Format.percentage(project.stats.percentFunded))
      let parts = string.characters.split(separator: " ").map(String.init)
      return (parts.first, parts.last)
    }

    self.fundingTitleLabelText = fundingTitleAndSubtitleText.map { title, _ in title ?? ""}
    self.fundingSubtitleLabelText = fundingTitleAndSubtitleText.map { _, subtitle in subtitle ?? "" }

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
  public let fundingTitleLabelText: Signal<String, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let projectNameLabelText: Signal<String, NoError>

  public var inputs: MostPopularSearchProjectCellViewModelInputs { return self }
  public var outputs: MostPopularSearchProjectCellViewModelOutputs { return self }
}
