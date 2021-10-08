import KsApi
import Prelude
import ReactiveSwift

public enum NavigationSection: Int, CaseIterable {
  case overview
  case campaign
  case faq
  case environmentalCommitments

  // TODO: Internationalize strings
  public var displayString: String {
    switch self {
    case .campaign: return "CAMPAIGN"
    case .environmentalCommitments: return "ENVIRONMENTAL COMMITMENTS"
    case .faq: return Strings.profile_settings_about_faq_short()
    case .overview: return "OVERVIEW"
    }
  }
}

public protocol ProjectNavigationSelectorViewModelInputs {
  /// Called when a button on the project navigation selector is tapped
  func buttonTapped(index: Int)

  /// Called shortly after `viewDidLoad` on the `ProjectPageViewController`
  func configureNavigationSelector()
}

public protocol ProjectNavigationSelectorViewModelOutputs {
  /// Emits an `Int` of the index that the selectedButtonBottomBorder will animate to
  var animateButtonBottomBorderViewConstraints: Signal<Int, Never> { get }

  /// Emits `Void` when called to configure the selectedButonBottomBorderView
  var configureSelectedButtonBottomBorderView: Signal<Void, Never> { get }

  /// Emits `[NavigationSection]` to set up the buttons in the UIStackView
  var createButtons: Signal<[NavigationSection], Never> { get }

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
    self.animateButtonBottomBorderViewConstraints = self.buttonTappedProperty.signal.skipNil()

    self.configureSelectedButtonBottomBorderView = self.configureNavigationSelectorProperty.signal

    self.createButtons = self.configureNavigationSelectorProperty.signal.mapConst(NavigationSection.allCases)

    // Called when a button is tapped or when the view is configured and we default to the first index
    let setFirstIndexOnConfigurationOrButtonTapped = Signal.merge(
      self.configureNavigationSelectorProperty.signal.mapConst(0),
      self.buttonTappedProperty.signal.skipNil()
    )

    self.notifyDelegateProjectNavigationSelectorDidSelect = setFirstIndexOnConfigurationOrButtonTapped

    self.updateNavigationSelectorUI = setFirstIndexOnConfigurationOrButtonTapped
  }

  fileprivate let buttonTappedProperty = MutableProperty<Int?>(nil)
  public func buttonTapped(index: Int) {
    self.buttonTappedProperty.value = index
  }

  fileprivate let configureNavigationSelectorProperty = MutableProperty(())
  public func configureNavigationSelector() {
    self.configureNavigationSelectorProperty.value = ()
  }

  public let animateButtonBottomBorderViewConstraints: Signal<Int, Never>
  public let configureSelectedButtonBottomBorderView: Signal<Void, Never>
  public let createButtons: Signal<[NavigationSection], Never>
  public var notifyDelegateProjectNavigationSelectorDidSelect: Signal<Int, Never>
  public let updateNavigationSelectorUI: Signal<Int, Never>

  public var inputs: ProjectNavigationSelectorViewModelInputs { return self }
  public var outputs: ProjectNavigationSelectorViewModelOutputs { return self }
}
