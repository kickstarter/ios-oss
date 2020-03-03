import KsApi
import Prelude
import ReactiveSwift

public protocol CreatorBylineViewModelInputs {
  func configureWith(project: Project)
}

public protocol CreatorBylineViewModelOutputs {
  /// Emits an image url to be loaded into the creator's image view.
  var creatorImageUrl: Signal<URL?, Never> { get }

  /// Emits text to be put into the creator label.
  var creatorLabelText: Signal<String, Never> { get }
}

public protocol CreatorBylineViewModelType {
  var inputs: CreatorBylineViewModelInputs { get }
  var outputs: CreatorBylineViewModelOutputs { get }
}

public final class CreatorBylineViewModel: CreatorBylineViewModelType,
  CreatorBylineViewModelInputs, CreatorBylineViewModelOutputs {
  public init() {
    let project = self.projectProperty.signal.skipNil()

    self.creatorLabelText = project.map {
      Strings.project_creator_by_creator(creator_name: $0.creator.name)
    }

    self.creatorImageUrl = project.map { URL(string: $0.creator.avatar.small) }
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let creatorImageUrl: Signal<URL?, Never>
  public let creatorLabelText: Signal<String, Never>

  public var inputs: CreatorBylineViewModelInputs { return self }
  public var outputs: CreatorBylineViewModelOutputs { return self }
}
