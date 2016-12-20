import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol MostPopularSearchProjectCellViewModelInputs {
  func configureWith(project: Project)
}

public protocol MostPopularSearchProjectCellViewModelOutputs {
  var fundingLabelText: Signal<String, NoError> { get }
  var fundingProgress: Signal<Float, NoError> { get }
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

    self.fundingLabelText = project.map {
      Strings.percentage_funded(percentage: Format.percentage($0.stats.percentFunded))
    }

    self.fundingProgress = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.projectImageUrl = project.map { URL(string: $0.photo.full) }

    self.projectNameLabelText = project.map(Project.lens.name.view)
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let fundingLabelText: Signal<String, NoError>
  public let fundingProgress: Signal<Float, NoError>
  public let projectImageUrl: Signal<URL?, NoError>
  public let projectNameLabelText: Signal<String, NoError>

  public var inputs: MostPopularSearchProjectCellViewModelInputs { return self }
  public var outputs: MostPopularSearchProjectCellViewModelOutputs { return self }
}
