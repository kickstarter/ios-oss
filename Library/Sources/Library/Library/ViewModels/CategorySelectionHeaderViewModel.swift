import Foundation
import ReactiveSwift

public enum CuratedProjectsContext {
  case onboarding
  case discovery
}

public enum CategorySelectionOnboardingHeaderViewContext {
  case categorySelection
  case curatedProjects(CuratedProjectsContext)

  var stepLabelText: String? {
    switch self {
    case .categorySelection:
      return Strings.Step_number(current_step: "1", total_steps: "2")
    case let .curatedProjects(context):
      switch context {
      case .onboarding:
        return Strings.Step_number(current_step: "2", total_steps: "2")
      case .discovery:
        return nil
      }
    }
  }

  var stepLabelHidden: Bool {
    switch self {
    case .categorySelection:
      return false
    case let .curatedProjects(context):
      switch context {
      case .discovery:
        return true
      case .onboarding:
        return false
      }
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
  func configure(with context: CategorySelectionOnboardingHeaderViewContext)
}

public protocol CategorySelectionHeaderViewModelOutputs {
  var stepLabelIsHidden: Signal<Bool, Never> { get }
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
      .skipNil()

    self.subtitleLabelText = self.contextSignal
      .map(\.subtitleLabelText)
      .skipNil()

    self.titleLabelText = self.contextSignal
      .map(\.titleLabelText)

    self.stepLabelIsHidden = self.contextSignal
      .map(\.stepLabelHidden)
  }

  private let (contextSignal, contextObserver)
    = Signal<CategorySelectionOnboardingHeaderViewContext, Never>.pipe()
  public func configure(with context: CategorySelectionOnboardingHeaderViewContext) {
    self.contextObserver.send(value: context)
  }

  public let stepLabelIsHidden: Signal<Bool, Never>
  public let stepLabelText: Signal<String, Never>
  public let subtitleLabelText: Signal<String, Never>
  public let titleLabelText: Signal<String, Never>

  public var inputs: CategorySelectionHeaderViewModelInputs { return self }
  public var outputs: CategorySelectionHeaderViewModelOutputs { return self }
}
