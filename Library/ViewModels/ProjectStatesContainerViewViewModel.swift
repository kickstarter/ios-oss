import KsApi
import Prelude
import Result
import ReactiveSwift
import ReactiveExtensions

public protocol ProjectStatesContainerViewViewModelInputs {

}

public protocol ProjectStatesContainerViewViewModelOutputs {
  var buttonTitleText: Signal<String, NoError> { get }
}

public protocol ProjectStatesContainerViewViewModelType {
  var inputs: ProjectStatesContainerViewViewModelInputs { get }
  var outputs: ProjectStatesContainerViewViewModelOutputs { get }
}

public final class ProjectStatesContainerViewViewModel: ProjectStatesContainerViewViewModelType,
  ProjectStatesContainerViewViewModelInputs, ProjectStatesContainerViewViewModelOutputs {

  public init() {
    self.buttonTitleText = .empty
  }

  public var inputs: ProjectStatesContainerViewViewModelInputs { return self }
  public var outputs: ProjectStatesContainerViewViewModelOutputs { return self }

  public let buttonTitleText: Signal<String, NoError>
}
