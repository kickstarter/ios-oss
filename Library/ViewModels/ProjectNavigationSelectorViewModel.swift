import KsApi
import Prelude
import ReactiveSwift

public enum NavigationSection: Int, CaseIterable {
  case overview
  case campaign
  case faq
  case risks
  case environmentalCommitments

  public var displayString: String {
    switch self {
    case .campaign: return Strings.Campaign()
    case .environmentalCommitments: return Strings.Environmental_Commitments()
    case .faq: return Strings.Faq()
    case .overview: return Strings.Overview()
    case .risks: return Strings.Risks()
    }
  }
}

public protocol ProjectNavigationSelectorViewModelInputs {
  /// Called when a button on the project navigation selector is tapped
  func buttonTapped(index: Int)

  /// Called with a `ExtendedProjectProperties` instance when `viewDidLoad` is called on the `ProjectPageViewController`
  func configureNavigationSelector(with: ExtendedProjectProperties)
}

public protocol ProjectNavigationSelectorViewModelOutputs {
  /// Emits an `Int` of the index that the selectedButtonBottomBorder will animate to
  var animateButtonBottomBorderViewConstraints: Signal<Int, Never> { get }

  /// Emits `[NavigationSection]` when called to configure the selectedButonBottomBorderView
  var configureNavigationSelectorUI: Signal<[NavigationSection], Never> { get }

  /// Emits `Int` of a button index being selected
  var notifyDelegateProjectNavigationSelectorDidSelect: Signal<Int, Never> { get }

  /// Emits an `Int` which is the index of the button being selected
  var updateNavigationSelectorUI: Signal<Int, Never> { get }
}

public protocol ProjectNavigationSelectorViewModelType {
  var inputs: ProjectNavigationSelectorViewModelInputs { get }
  var outputs: ProjectNavigationSelectorViewModelOutputs { get }
}

public final class ProjectNavigationSelectorViewModel: ProjectNavigationSelectorViewModelType,
  ProjectNavigationSelectorViewModelInputs, ProjectNavigationSelectorViewModelOutputs {
  public init() {
    self.animateButtonBottomBorderViewConstraints = self.buttonTappedProperty.signal

    self.configureNavigationSelectorUI = self.configureNavigationSelectorProperty.signal
      .skipNil()
      .map { projectProperties in
        guard !projectProperties.environmentalCommitments.isEmpty else {
          return [.overview, .campaign, .faq, .risks]
        }
        return NavigationSection.allCases
      }

    // Called when a button is tapped or when the view is configured and we default to the first index
    let setFirstIndexOnConfigurationOrButtonTapped = Signal.merge(
      self.configureNavigationSelectorProperty.signal.mapConst(0),
      self.buttonTappedProperty.signal
    )

    self.notifyDelegateProjectNavigationSelectorDidSelect = setFirstIndexOnConfigurationOrButtonTapped

    self.updateNavigationSelectorUI = setFirstIndexOnConfigurationOrButtonTapped
  }

  fileprivate let buttonTappedProperty = MutableProperty<Int>(0)
  public func buttonTapped(index: Int) {
    self.buttonTappedProperty.value = index
  }

  fileprivate let configureNavigationSelectorProperty = MutableProperty<ExtendedProjectProperties?>(nil)
  public func configureNavigationSelector(with projectProperties: ExtendedProjectProperties) {
    self.configureNavigationSelectorProperty.value = projectProperties
  }

  public let animateButtonBottomBorderViewConstraints: Signal<Int, Never>
  public let configureNavigationSelectorUI: Signal<[NavigationSection], Never>
  public var notifyDelegateProjectNavigationSelectorDidSelect: Signal<Int, Never>
  public let updateNavigationSelectorUI: Signal<Int, Never>

  public var inputs: ProjectNavigationSelectorViewModelInputs { return self }
  public var outputs: ProjectNavigationSelectorViewModelOutputs { return self }
}
