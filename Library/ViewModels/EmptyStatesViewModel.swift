import KsApi
import Prelude
import ReactiveSwift
import UIKit

public enum EmptyState: String {
  case activity
  case recommended
  case socialNoPledges = "social_no_pledges"
  case socialDisabled = "social_disabled"
  case starred
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
  /// Emits a constant float value for the bottom layout constraint.
  var bottomLayoutConstraintConstant: Signal<CGFloat, Never> { get }

  /// Emits the button text.
  var mainButtonText: Signal<String, Never> { get }

  /// Emits to notify the delegate to go to Discovery with params.
  var notifyDelegateToGoToDiscovery: Signal<DiscoveryParams?, Never> { get }

  /// Emits to notify the delegate to go to Friends.
  var notifyDelegateToGoToFriends: Signal<(), Never> { get }

  /// Emits the subtitle label text.
  var subtitleLabelText: Signal<String, Never> { get }

  /// Emits the title label text.
  var titleLabelText: Signal<String, Never> { get }
}

public protocol EmptyStatesViewModelType {
  var inputs: EmptyStatesViewModelInputs { get }
  var outputs: EmptyStatesViewModelOutputs { get }
}

public final class EmptyStatesViewModel: EmptyStatesViewModelType, EmptyStatesViewModelInputs,
  EmptyStatesViewModelOutputs {
  public init() {
    let emptyState = Signal.combineLatest(
      self.emptyStateProperty.signal.skipNil(),
      self.viewWillAppearProperty.signal.take(first: 1)
    )
    .map(first)

    self.mainButtonText = emptyState.map(buttonText(emptyState:))

    self.subtitleLabelText = emptyState.map(textForSubtitle(emptyState:))

    self.titleLabelText = emptyState.map(textForTitle(emptyState:))

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
      .map { Styles.grid(5) + ($0 == .activity ? 50.0 : 0) }

    // Tracking

    self.mainButtonTappedProperty.signal.observeValues { _ in
      AppEnvironment.current.ksrAnalytics.trackExploreButtonClicked()
    }
  }

  fileprivate let emptyStateProperty = MutableProperty<EmptyState?>(nil)
  public func configureWith(emptyState: EmptyState?) {
    self.emptyStateProperty.value = emptyState
  }

  fileprivate let mainButtonTappedProperty = MutableProperty(())
  public func mainButtonTapped() {
    self.mainButtonTappedProperty.value = ()
  }

  public func setEmptyState(_ emptyState: EmptyState) {
    self.emptyStateProperty.value = emptyState
  }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let bottomLayoutConstraintConstant: Signal<CGFloat, Never>
  public let mainButtonText: Signal<String, Never>
  public let notifyDelegateToGoToDiscovery: Signal<DiscoveryParams?, Never>
  public let notifyDelegateToGoToFriends: Signal<(), Never>
  public let subtitleLabelText: Signal<String, Never>
  public let titleLabelText: Signal<String, Never>

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
