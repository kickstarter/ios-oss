import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectFAQsCellViewModelInputs {
  /// Call to configure with a tuple of `ProjectFAQ, Bool`. The `Bool` represents whether the cell is expanded.
  func configureWith(value: (ProjectFAQ, Bool))
}

public protocol ProjectFAQsCellViewModelOutputs {
  /// Emits a `String` of the answer from the FAQ object
  var answerLabelText: Signal<String, Never> { get }

  /// Emits a `Bool` for determining whether the stackview containing the answer is hidden
  var answerStackViewIsHidden: Signal<Bool, Never> { get }

  /// Emits a `Bool` to determine if the chevron image view should point up or down
  var configureChevronImageView: Signal<Bool, Never> { get }

  /// Emits a `String` of the question from the FAQ object
  var questionLabelText: Signal<String, Never> { get }

  /// Emits a `String` of the time stamp from the FAQ object
  var updatedLabelText: Signal<String, Never> { get }
}

public protocol ProjectFAQsCellViewModelType {
  var inputs: ProjectFAQsCellViewModelInputs { get }
  var outputs: ProjectFAQsCellViewModelOutputs { get }
}

public final class ProjectFAQsCellViewModel:
  ProjectFAQsCellViewModelType, ProjectFAQsCellViewModelInputs, ProjectFAQsCellViewModelOutputs {
  public init() {
    let faq = self.configureWithProperty.signal
      .skipNil()
      .map(first)

    let isExpanded = self.configureWithProperty.signal
      .skipNil()
      .map(second)

    self.answerLabelText = faq.map(\.answer)
    self.answerStackViewIsHidden = isExpanded.negate()
    self.configureChevronImageView = isExpanded
    self.questionLabelText = faq.map(\.question)
    self.updatedLabelText = faq
      .map(\.createdAt)
      .skipNil()
      .map { createdAt in
        "Updated \(Format.date(secondsInUTC: createdAt, template: "MMM d, yyyy"))"
      }
  }

  fileprivate let configureWithProperty = MutableProperty<(ProjectFAQ, Bool)?>(nil)
  public func configureWith(value: (ProjectFAQ, Bool)) {
    self.configureWithProperty.value = value
  }

  public let answerLabelText: Signal<String, Never>
  public let answerStackViewIsHidden: Signal<Bool, Never>
  public let configureChevronImageView: Signal<Bool, Never>
  public let questionLabelText: Signal<String, Never>
  public let updatedLabelText: Signal<String, Never>

  public var inputs: ProjectFAQsCellViewModelInputs { self }
  public var outputs: ProjectFAQsCellViewModelOutputs { self }
}
