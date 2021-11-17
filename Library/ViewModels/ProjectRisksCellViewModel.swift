import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectRisksCellViewModelInputs {
  /// Call to configure with a `String` of the risks.
  func configureWith(value: String)
}

public protocol ProjectRisksCellViewModelOutputs {
  /// Emits a `String` of the risks.
  var descriptionLabelText: Signal<String, Never> { get }
}

public protocol ProjectRisksCellViewModelType {
  var inputs: ProjectRisksCellViewModelInputs { get }
  var outputs: ProjectRisksCellViewModelOutputs { get }
}

public final class ProjectRisksCellViewModel:
  ProjectRisksCellViewModelType, ProjectRisksCellViewModelInputs,
  ProjectRisksCellViewModelOutputs {
  public init() {
    self.descriptionLabelText = self.configureWithProperty.signal.skipNil()
  }

  fileprivate let configureWithProperty = MutableProperty<String?>(nil)
  public func configureWith(value: String) {
    self.configureWithProperty.value = value
  }

  public let descriptionLabelText: Signal<String, Never>

  public var inputs: ProjectRisksCellViewModelInputs { self }
  public var outputs: ProjectRisksCellViewModelOutputs { self }
}
