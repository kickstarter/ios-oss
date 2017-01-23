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
  var fundingLabelText: Signal<String, NoError> { get }
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

    self.fundingLabelText = project.map {
      Strings.percentage_funded(percentage: Format.percentage($0.stats.percentFunded))
    }

    self.projectNameLabelText = project.map { $0.name }

    self.projectImageUrl = project.map { URL(string: $0.photo.med)}
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let deadlineSubtitleLabelText: Signal<String, NoError>
  public let deadlineTitleLabelText: Signal<String, NoError>
  public let fundingLabelText: Signal<String, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let projectNameLabelText: Signal<String, NoError>

  public var inputs: SearchProjectCellViewModelInputs { return self }
  public var outputs: SearchProjectCellViewModelOutputs { return self }
}
