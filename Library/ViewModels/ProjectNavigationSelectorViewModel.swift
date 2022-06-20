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
    case .environmentalCommitments: return Strings.Environmental_commitments()
    case .faq: return Strings.Faq()
    case .overview: return Strings.Overview()
    case .risks: return Strings.Risks()
    }
  }
}

public protocol ProjectNavigationSelectorViewModelInputs {
  /// Called when a button on the project navigation selector is tapped
  func buttonTapped(index: Int)

  /// Called with a `(Project, RefTag?)` instance when `viewDidLoad` is called on the `ProjectPageViewController`
  func configureNavigationSelector(with: (Project, RefTag?))
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

    let displayableTabs: (Project) -> [NavigationSection] = { project in
      let baseTabs: [NavigationSection] = [.overview]

      guard let extendedProjectProperties = project.extendedProjectProperties else {
        return baseTabs
      }

      let moreTabs: [NavigationSection] = featureProjectPageStoryTabEnabled() ? [.campaign, .faq, .risks] :
        [.faq, .risks]

      guard !extendedProjectProperties.environmentalCommitments.isEmpty else {
        return baseTabs + moreTabs
      }

      return baseTabs + moreTabs + [.environmentalCommitments]
    }

    self.configureNavigationSelectorUI = self.configureNavigationSelectorProperty.signal
      .skipNil()
      .map(first)
      .map(displayableTabs)

    let configureNavigationSelector = self.configureNavigationSelectorProperty.signal.skipNil()

    // Called when a button is tapped or when the view is configured and we default to the first index
    let setFirstIndexOnConfigurationOrButtonTapped = Signal.merge(
      configureNavigationSelector.mapConst(0),
      self.buttonTappedProperty.signal
    )

    self.notifyDelegateProjectNavigationSelectorDidSelect = setFirstIndexOnConfigurationOrButtonTapped

    self.updateNavigationSelectorUI = setFirstIndexOnConfigurationOrButtonTapped

    let projectTabSelectedAfterFirstLoad = configureNavigationSelector
      .takePairWhen(self.buttonTappedProperty.signal.skip(while: { $0 == 0 }).skipRepeats())

    projectTabSelectedAfterFirstLoad
      .map { projectAndRefTag, index in (projectAndRefTag.0, projectAndRefTag.1, index) }
      .observeValues { [weak self] project, refTag, index in
        self?.trackPageViewedProjectTab(index: index, project: project, refTag: refTag)
      }
  }

  // MARK: Helpers

  private func trackPageViewedProjectTab(index: Int, project: Project, refTag: RefTag?) {
    guard let contextValue = self.navigationTabContext(index: index) else { return }

    AppEnvironment.current.ksrAnalytics.trackProjectViewed(
      project,
      refTag: refTag,
      sectionContext: contextValue
    )
  }

  private func navigationTabContext(index: Int) -> KSRAnalytics.SectionContext? {
    switch index {
    case 0: return .tabSelected(.overview)
    case 1: return .tabSelected(.campaign)
    case 2: return .tabSelected(.faqs)
    case 3: return .tabSelected(.risks)
    case 4: return .tabSelected(.environmentalCommitments)
    default: return nil
    }
  }

  fileprivate let buttonTappedProperty = MutableProperty<Int>(0)
  public func buttonTapped(index: Int) {
    self.buttonTappedProperty.value = index
  }

  fileprivate let configureNavigationSelectorProperty = MutableProperty<(Project, RefTag?)?>(nil)
  public func configureNavigationSelector(with projectProperties: (Project, RefTag?)) {
    self.configureNavigationSelectorProperty.value = projectProperties
  }

  public let animateButtonBottomBorderViewConstraints: Signal<Int, Never>
  public let configureNavigationSelectorUI: Signal<[NavigationSection], Never>
  public var notifyDelegateProjectNavigationSelectorDidSelect: Signal<Int, Never>
  public let updateNavigationSelectorUI: Signal<Int, Never>

  public var inputs: ProjectNavigationSelectorViewModelInputs { return self }
  public var outputs: ProjectNavigationSelectorViewModelOutputs { return self }
}
