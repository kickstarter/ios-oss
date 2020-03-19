import KsApi
import Prelude
import ReactiveSwift

public protocol CreatorBylineViewModelInputs {
  func configureWith(project: Project, creatorDetails: ProjectCreatorDetailsEnvelope)
}

public protocol CreatorBylineViewModelOutputs {
  /// Emits an image url to be loaded into the creator's image view.
  var creatorImageUrl: Signal<URL?, Never> { get }

  /// Emits text to be put into the creator label.
  var creatorLabelText: Signal<String, Never> { get }

  /// Emits number of projects launched by creator.
  var creatorStatsText: Signal<String, Never> { get }
}

public protocol CreatorBylineViewModelType {
  var inputs: CreatorBylineViewModelInputs { get }
  var outputs: CreatorBylineViewModelOutputs { get }
}

public final class CreatorBylineViewModel: CreatorBylineViewModelType,
  CreatorBylineViewModelInputs, CreatorBylineViewModelOutputs {
  public init() {
    let project = self.projectProperty.signal.skipNil()
    let creatorDetails = self.creatorDetailsProperty.signal.skipNil()
      .map { $0 }

    self.creatorLabelText = project.map {
      Strings.project_creator_by_creator(creator_name: $0.creator.name)
    }

    self.creatorImageUrl = project.map { URL(string: $0.creator.avatar.small) }
    self.creatorStatsText = creatorDetails.map { creatorDetails in
      Strings.projects_launched_count_created_projects_backed_count_backed(
        projects_launched_count: Format.wholeNumber(creatorDetails.launchedProjectsCount),
        projects_backed_count: Format.wholeNumber(creatorDetails.backingsCount)
      )
    }
  }

  fileprivate let creatorDetailsProperty = MutableProperty<ProjectCreatorDetailsEnvelope?>(nil)
  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project, creatorDetails: ProjectCreatorDetailsEnvelope) {
    self.projectProperty.value = project
    self.creatorDetailsProperty.value = creatorDetails
  }

  public let creatorImageUrl: Signal<URL?, Never>
  public let creatorLabelText: Signal<String, Never>
  public let creatorStatsText: Signal<String, Never>

  public var inputs: CreatorBylineViewModelInputs { return self }
  public var outputs: CreatorBylineViewModelOutputs { return self }
}
