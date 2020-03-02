import KsApi
import Prelude
import ReactiveSwift

public protocol CreatorByLineViewViewModelInputs {
  func configureWith(project: Project)
}

public protocol CreatorByLineViewViewModelOutputs {
  /// Emits an image url to be loaded into the creator's image view.
  var creatorImageUrl: Signal<URL?, Never> { get }

  /// Emits text to be put into the creator label.
  var creatorLabelText: Signal<String, Never> { get }
}

public protocol CreatorByLineViewViewModelType {
  var inputs: CreatorByLineViewViewModelInputs { get }
  var outputs: CreatorByLineViewViewModelOutputs { get }
}

public final class CreatorByLineViewViewModel: CreatorByLineViewViewModelType,
CreatorByLineViewViewModelInputs, CreatorByLineViewViewModelOutputs {
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

  public var inputs: CreatorByLineViewViewModelInputs { return self }
  public var outputs: CreatorByLineViewViewModelOutputs { return self }
}
