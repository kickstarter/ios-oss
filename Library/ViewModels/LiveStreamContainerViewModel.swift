import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public protocol LiveStreamContainerViewModelType {
  var inputs: LiveStreamContainerViewModelInputs { get }
  var outputs: LiveStreamContainerViewModelOutputs { get }
}

public protocol LiveStreamContainerViewModelInputs {
  func configureWith(project project: Project)
}

public protocol LiveStreamContainerViewModelOutputs {

}

public final class LiveStreamContainerViewModel: LiveStreamContainerViewModelType,
LiveStreamContainerViewModelInputs, LiveStreamContainerViewModelOutputs {

  public init() {

  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  public var inputs: LiveStreamContainerViewModelInputs { return self }
  public var outputs: LiveStreamContainerViewModelOutputs { return self }
}