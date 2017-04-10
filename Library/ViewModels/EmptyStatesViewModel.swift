import KsApi
import Prelude
import ReactiveSwift
import Result

public enum EmptyState: String {
  case activity = "activity"
  case recommended = "recommended"
  case socialNoPledges = "social_no_pledges"
  case socialDisabled = "social_disabled"
  case starred = "starred"
}

public protocol EmptyStatesViewModelInputs {
  /// Call to configure with the view controller that needs an empty state.
  func configureWith(emptyState: EmptyState?)

  /// Call when main button is tapped.
  func mainButtonTapped()

  /// Call to set the empty state if it is not known at the time of instanciation.
  func setEmptyState(_ emptyState: EmptyState)

  /// Call when the view controller's viewWillAppear method is called.
  func viewWillAppear()
}

public protocol EmptyStatesViewModelOutputs {
  /// Emits the background gradient category color.
  var backgroundGradientColorId: Signal<Int?, NoError> { get }

  /// Emits the background strip view alpha.
  var backgroundStripViewAlpha: Signal<CGFloat, NoError> { get }

  /// Emits the background strip view color.
  var backgroundStripViewColor: Signal<UIColor, NoError> { get }

  /// Emits a constant float value for the bottom layout constraint.
  var bottomLayoutConstraintConstant: Signal<CGFloat, NoError> { get }

  /// Emits the button background color.
  var mainButtonBackgroundColor: Signal<UIColor, NoError> { get }

  /// Emits the button border color.
  var mainButtonBorderColor: Signal<CGColor, NoError> { get }

  /// Emits the button text.
  var mainButtonText: Signal<String, NoError> { get }

  /// Emits the button title color.
  var mainButtonTitleColor: Signal<UIColor, NoError> { get }

  /// Emits to notify the delegate to go to Discovery with params.
  var notifyDelegateToGoToDiscovery: Signal<DiscoveryParams?, NoError> { get }

  /// Emits to notify the delegate to go to Friends.
  var notifyDelegateToGoToFriends: Signal<(), NoError> { get }

  /// Emits the subtitle label text.
  var subtitleLabelText: Signal<String, NoError> { get }

  /// Emits the subtitle label color.
  var subtitleLabelColor: Signal<UIColor, NoError> { get }

  /// Emits the title label text.
  var titleLabelText: Signal<String, NoError> { get }

  /// Emits the title label color.
  var titleLabelColor: Signal<UIColor, NoError> { get }
}

public protocol EmptyStatesViewModelType {
  var inputs: EmptyStatesViewModelInputs { get }
  var outputs: EmptyStatesViewModelOutputs { get }
}

public final class EmptyStatesViewModel: EmptyStatesViewModelType, EmptyStatesViewModelInputs,
  EmptyStatesViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let emptyState = Signal.combineLatest(
      self.emptyStateProperty.signal.skipNil(),
      self.viewWillAppearProperty.signal.take(first: 1)
    )
    .map(first)

    self.backgroundGradientColorId = emptyState
      .map { emptyState -> Int? in
        emptyState == .activity ? RootCategory.comics.rawValue : nil
    }

    self.mainButtonBackgroundColor = emptyState
      .map { emptyState -> UIColor in emptyState == .activity
        ? UIColor.ksr_forest_500.withAlphaComponent(0.1)
        : UIColor.ksr_green_500.withAlphaComponent(0.1)
    }

    self.mainButtonBorderColor = emptyState
      .map { $0 == .activity
        ? UIColor.ksr_forest_500.withAlphaComponent(0.2).cgColor
        : UIColor.ksr_green_700.withAlphaComponent(0.2).cgColor
    }

    self.mainButtonText = emptyState.map(buttonText(emptyState:))

    self.mainButtonTitleColor = emptyState
      .map { $0 == .activity ? UIColor.ksr_forest_600 : UIColor.ksr_text_green_700 }

    self.subtitleLabelText = emptyState.map(textForSubtitle(emptyState:))

    self.subtitleLabelColor = emptyState
      .map { $0 == .activity ? UIColor.ksr_forest_500 : UIColor.ksr_text_navy_700 }

    self.titleLabelText = emptyState.map(textForTitle(emptyState:))

    self.titleLabelColor = emptyState
      .map { $0 == .activity ? UIColor.ksr_forest_600 : UIColor.ksr_text_navy_700 }

    self.backgroundStripViewAlpha = emptyState
      .map { $0 == .activity ? 0.45 : 1.0 }

    self.backgroundStripViewColor = emptyState
      .map { $0 == .activity ? UIColor.white : UIColor.ksr_grey_100 }

    self.notifyDelegateToGoToDiscovery = emptyState
      .takeWhen(self.mainButtonTappedProperty.signal)
      .filter { $0 != .socialDisabled && $0 != .socialNoPledges }
      .map { emptyState -> DiscoveryParams? in
        guard emptyState != .activity else { return nil }
        return DiscoveryParams.defaults |> DiscoveryParams.lens.sort .~ .magic
    }

    self.notifyDelegateToGoToFriends = emptyState
      .takeWhen(self.mainButtonTappedProperty.signal)
      .filter { $0 == .socialDisabled || $0 == .socialNoPledges }
      .ignoreValues()

    self.bottomLayoutConstraintConstant = emptyState
      .map { $0 == .activity ? 50.0 + Styles.grid(3) : Styles.grid(3) }

    emptyState
      .observeValues { AppEnvironment.current.koala.trackEmptyStateViewed(type: $0) }

    emptyState
      .takeWhen(self.mainButtonTappedProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackEmptyStateButtonTapped(type: $0) }
  }
  // swiftlint:enable function_body_length

  fileprivate let emptyStateProperty = MutableProperty<EmptyState?>(nil)
  public func configureWith(emptyState: EmptyState?) {
    self.emptyStateProperty.value = emptyState
  }
  fileprivate let mainButtonTappedProperty = MutableProperty()
  public func mainButtonTapped() {
    self.mainButtonTappedProperty.value = ()
  }
  public func setEmptyState(_ emptyState: EmptyState) {
    self.emptyStateProperty.value = emptyState
  }
  fileprivate let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let backgroundGradientColorId: Signal<Int?, NoError>
  public let backgroundStripViewAlpha: Signal<CGFloat, NoError>
  public let backgroundStripViewColor: Signal<UIColor, NoError>
  public let bottomLayoutConstraintConstant: Signal<CGFloat, NoError>
  public var mainButtonBackgroundColor: Signal<UIColor, NoError>
  public var mainButtonBorderColor: Signal<CGColor, NoError>
  public var mainButtonTitleColor: Signal<UIColor, NoError>
  public let mainButtonText: Signal<String, NoError>
  public let notifyDelegateToGoToDiscovery: Signal<DiscoveryParams?, NoError>
  public let notifyDelegateToGoToFriends: Signal<(), NoError>
  public let subtitleLabelText: Signal<String, NoError>
  public let subtitleLabelColor: Signal<UIColor, NoError>
  public let titleLabelText: Signal<String, NoError>
  public let titleLabelColor: Signal<UIColor, NoError>

  public var inputs: EmptyStatesViewModelInputs { return self }
  public var outputs: EmptyStatesViewModelOutputs { return self }
}

private func textForSubtitle(emptyState: EmptyState) -> String {
  switch emptyState {
  case .activity:
    return Strings.Find_projects_youll_love_in_art_design_film()
  case .socialDisabled:
    return Strings.Follow_your_Facebook_friends_and_keep_up_with_the_projects()
  case .socialNoPledges:
    return Strings.Your_friends_havent_backed_any_projects_yet()
  case .recommended:
    return Strings.Once_you_back_a_project_well_share()
  case .starred:
    return Strings.Tap_the_star_on_each_project_page_to_save_it()
  }
}

private func textForTitle(emptyState: EmptyState) -> String {
  switch emptyState {
  case .activity:
    return Strings.Bring_creative_projects_to_life()
  case .socialDisabled:
    return Strings.Its_better_with_friends()
  case .socialNoPledges:
    return Strings.No_pledges_from_friends_yet()
  case .recommended:
    return Strings.Just_for_you()
  case .starred:
    return Strings.Something_catch_your_eye()
  }
}

private func buttonText(emptyState: EmptyState) -> String {
  switch emptyState {
  case .socialDisabled:
    return Strings.Find_and_follow_friends()
  case .socialNoPledges:
    return Strings.Follow_more_friends()
  case .activity, .recommended, .starred:
    return Strings.Explore_projects()
  }
}
