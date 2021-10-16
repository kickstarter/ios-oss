import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectFAQsCellViewModelInputs {
  /// Call to configure with a `ProjectFAQ`
  func configureWith(faq: ProjectFAQ?)
}

public protocol ProjectFAQsCellViewModelOutputs {
  /// Emits a `String` of the answer from the FAQ object
  var answerLabelText: Signal<String, Never> { get }

  /// Emits a `Bool` for determining whether the stackview containing the answer is hidden
  var answerStackViewIsHidden: Signal<Bool, Never> { get }

  /// Emits a `String` of the question from the FAQ object
  var questionLabelText: Signal<String, Never> { get }
}

public protocol ProjectFAQsCellViewModelType {
  var inputs: ProjectFAQsCellViewModelInputs { get }
  var outputs: ProjectFAQsCellViewModelOutputs { get }
}

public final class ProjectFAQsCellViewModel:
  ProjectFAQsCellViewModelType, ProjectFAQsCellViewModelInputs, ProjectFAQsCellViewModelOutputs {
  public init() {
    let faq = self.configureWithProperty.signal.skipNil()

    self.answerLabelText = faq.map(\.answer)
    self.answerStackViewIsHidden = faq.mapConst(true)
    self.questionLabelText = faq.map(\.question)
  }

  fileprivate let configureWithProperty = MutableProperty<ProjectFAQ?>(nil)
  public func configureWith(faq: ProjectFAQ?) {
    self.configureWithProperty.value = faq
  }

  public let answerLabelText: Signal<String, Never>
  public let answerStackViewIsHidden: Signal<Bool, Never>
  public let questionLabelText: Signal<String, Never>

  public var inputs: ProjectFAQsCellViewModelInputs { self }
  public var outputs: ProjectFAQsCellViewModelOutputs { self }
}
