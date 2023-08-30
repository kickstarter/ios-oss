import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectTabAIGenerationCellViewModelInputs {
  /// Call to configure with a value of `String`, `String`. The first `String` represents the question being asked in the cell. The second represents the answer.
  func configureWith(value: (String, String))
}

public protocol ProjectTabAIGenerationCellViewModelOutputs {
  /// Emits a `String` of the question from the question itself
  var questionLabelText: Signal<String, Never> { get }

  /// Emits a `String` of the answer from the question itself
  var answerLabelText: Signal<String, Never> { get }
}

public protocol ProjectAIGenerationAnswerCellViewModelType {
  var inputs: ProjectTabAIGenerationCellViewModelInputs { get }
  var outputs: ProjectTabAIGenerationCellViewModelOutputs { get }
}

public final class ProjectTabAIGenerationCellViewModel:
  ProjectAIGenerationAnswerCellViewModelType, ProjectTabAIGenerationCellViewModelInputs,
  ProjectTabAIGenerationCellViewModelOutputs {
  public init() {
    self.questionLabelText = self.configureWithProperty.signal
      .skipNil()
      .map(first)

    self.answerLabelText = self.configureWithProperty.signal
      .skipNil()
      .map(second)
  }

  fileprivate let configureWithProperty = MutableProperty<(String, String)?>(nil)
  public func configureWith(value: (String, String)) {
    self.configureWithProperty.value = value
  }

  public let questionLabelText: Signal<String, Never>
  public let answerLabelText: Signal<String, Never>

  public var inputs: ProjectTabAIGenerationCellViewModelInputs { self }
  public var outputs: ProjectTabAIGenerationCellViewModelOutputs { self }
}
