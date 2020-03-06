import Foundation
import ReactiveSwift

public enum HeaderViewContext {
  case categorySelection
  case curatedProjects

  var stepLabelText: String {
    switch self {
    case .categorySelection:
      return Strings.Step_number(current_step: "1", total_steps: "2")
    case .curatedProjects:
      return Strings.Step_number(current_step: "2", total_steps: "2")
    }
  }

  var subtitleLabelText: String? {
    switch self {
    case .categorySelection:
      return Strings.Select_up_to_five()
    case .curatedProjects:
      return nil
    }
  }

  var titleLabelText: String {
    switch self {
    case .categorySelection:
      return Strings.Which_categories_interest_you()
    case .curatedProjects:
      return Strings.Check_out_these_handpicked_projects()
    }
  }
}

public protocol CategorySelectionHeaderViewModelInputs {
  func configure(with context: HeaderViewContext)
}

public protocol CategorySelectionHeaderViewModelOutputs {
  var stepLabelText: Signal<String, Never> { get }
  var subtitleLabelText: Signal<String, Never> { get }
  var titleLabelText: Signal<String, Never> { get }
}

public protocol CategorySelectionHeaderViewModelType {
  var inputs: CategorySelectionHeaderViewModelInputs { get }
  var outputs: CategorySelectionHeaderViewModelOutputs { get }
}

public final class CategorySelectionHeaderViewModel: CategorySelectionHeaderViewModelType,
  CategorySelectionHeaderViewModelInputs, CategorySelectionHeaderViewModelOutputs {
  public init() {
    self.stepLabelText = self.contextSignal
      .map(\.stepLabelText)

    self.subtitleLabelText = self.contextSignal
      .map(\.subtitleLabelText)
      .skipNil()

    self.titleLabelText = self.contextSignal
      .map(\.titleLabelText)
  }

  private let (contextSignal, contextObserver) = Signal<HeaderViewContext, Never>.pipe()
  public func configure(with context: HeaderViewContext) {
    self.contextObserver.send(value: context)
  }

  public let stepLabelText: Signal<String, Never>
  public let subtitleLabelText: Signal<String, Never>
  public let titleLabelText: Signal<String, Never>

  public var inputs: CategorySelectionHeaderViewModelInputs { return self }
  public var outputs: CategorySelectionHeaderViewModelOutputs { return self }
}
