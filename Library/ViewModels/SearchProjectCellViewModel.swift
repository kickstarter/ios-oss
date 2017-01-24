import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SearchProjectCellViewModelInputs {
  func configureWith(project: Project)
}

public protocol SearchProjectCellViewModelOutputs{
  var deadlineSubtitleLabelText: Signal<String, NoError> { get }
  var deadlineTitleLabelText: Signal<String, NoError> { get }
  var fundingTitleLabelText: Signal<String, NoError> { get }
  var fundingSubtitleLabelText: Signal<String, NoError> { get }
  var projectImageUrl: Signal<URL?, NoError> { get }
  var projectNameLabelText: Signal<String, NoError> {get}
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
      .map {
        $0.state == .live
          ? Format.duration(secondsInUTC: $0.dates.deadline, useToGo: true)
        : ("", "")
    }

    self.deadlineTitleLabelText = deadlineTitleAndSubtitle.map(first)
    self.deadlineSubtitleLabelText = deadlineTitleAndSubtitle.map(second)

    let fundingTitleAndSubtitleText = project.map { project -> (String?, String?) in
      let string = Strings.percentage_funded(percentage: Format.percentage(project.stats.percentFunded))
      let parts = string.characters.split(separator: " ").map(String.init)
      return (parts.first, parts.last)
    }

    self.fundingTitleLabelText = fundingTitleAndSubtitleText.map { title, _ in title ?? ""}
    self.fundingSubtitleLabelText = fundingTitleAndSubtitleText.map { _, subtitle in subtitle ?? "" }

    self.projectNameLabelText = project.map { $0.name }

    self.projectImageUrl = project.map { URL(string: $0.photo.med)}
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let fundingTitleLabelText: Signal<String, NoError>
  public let fundingSubtitleLabelText: Signal<String, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let projectNameLabelText: Signal<String, NoError>

  public var inputs: SearchProjectCellViewModelInputs { return self }
  public var outputs: SearchProjectCellViewModelOutputs { return self }
}
