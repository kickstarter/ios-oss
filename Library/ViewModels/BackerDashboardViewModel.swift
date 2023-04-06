import KsApi
import Prelude
import ReactiveSwift
import UIKit

public enum BackerDashboardTab {
  case backed
  case saved

  public static let allTabs: [BackerDashboardTab] = [.backed, .saved]
}

public protocol BackerDashboardViewModelInputs {
  /// Call when backed projects button is tapped.
  func backedProjectsButtonTapped()

  /// Call when the pan gesture begins with header top constraint constant and scroll view y offset values
  /// to calculate the starting point constant for the pan gesture.
  func beganPanGestureWith(headerTopConstant: CGFloat, scrollViewYOffset: CGFloat)

  /// Call after having invoked AppEnvironemt.updateCurrentUser with a fresh user.
  func currentUserUpdatedInEnvironment()

  /// Call when messages button is tapped.
  func messagesButtonTapped()

  /// Call when the UIPageViewController finishes transitioning.
  func pageTransition(completed: Bool)

  /// Call when the ksr_projectSaved notification is posted.
  func projectSaved()

  /// Call when saved projects button is tapped.
  func savedProjectsButtonTapped()

  /// Call when settings button is tapped.
  func settingsButtonTapped()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear(_ animated: Bool)

  /// Call when the UIPageViewController begins a transition sequence.
  func willTransition(toPage nextPage: Int)
}

public protocol BackerDashboardViewModelOutputs {
  /// Emits a URL for the avatar image view.
  var avatarURL: Signal<URL?, Never> { get }

  /// Emits a string for the backed button title label.
  var backedButtonTitleText: Signal<String, Never> { get }

  /// Emits a string for the backer name label.
  var backerNameText: Signal<String, Never> { get }

  /// Emits the initial BackerDashboardTab and a default Sort to configure the page view controller.
  var configurePagesDataSource: Signal<(BackerDashboardTab, DiscoveryParams.Sort), Never> { get }

  /// The currently selected tab.
  var currentSelectedTab: BackerDashboardTab { get }

  /// Emits a CGFloat to set the top constraint of the embedded views when the sort bar is hidden or not.
  var embeddedViewTopConstraintConstant: Signal<CGFloat, Never> { get }

  /// Emits when to present Messages.
  var goToMessages: Signal<(), Never> { get }

  /// Emits when to navigate to Settings.
  var goToSettings: Signal<(), Never> { get }

  /// The starting value of the header top constraint that is needed to calculate the distance panned.
  var initialTopConstant: CGFloat { get }

  /// Emits a BackerDashboardTab to navigate to.
  var navigateToTab: Signal<BackerDashboardTab, Never> { get }

  /// Emits a BackerDashboardTab to pin the indicator view to with or without animation.
  var pinSelectedIndicatorToTab: Signal<(BackerDashboardTab, Bool), Never> { get }

  /// Emits an Notification that should be immediately posted.
  var postNotification: Signal<Notification, Never> { get }

  /// Emits a string for the saved button title label.
  var savedButtonTitleText: Signal<String, Never> { get }

  /// Emits the selected BackerDashboardTab to set the selected button and update all button selected states.
  var setSelectedButton: Signal<BackerDashboardTab, Never> { get }

  /// Emits a boolean whether the sort bar is hidden or not.
  var sortBarIsHidden: Signal<Bool, Never> { get }

  /// Emits a fresh user to be updated in the app environment.
  var updateCurrentUserInEnvironment: Signal<User, Never> { get }
}

public protocol BackerDashboardViewModelType {
  var inputs: BackerDashboardViewModelInputs { get }
  var outputs: BackerDashboardViewModelOutputs { get }
}

public final class BackerDashboardViewModel: BackerDashboardViewModelType, BackerDashboardViewModelInputs,
  BackerDashboardViewModelOutputs {
  public init() {
    self.configurePagesDataSource = self.viewDidLoadProperty.signal
      .map { (.backed, DiscoveryParams.Sort.endingSoon) }

    let fetchedUserEvent = Signal.merge(
      self.projectSavedProperty.signal.ignoreValues(),
      self.viewWillAppearProperty.signal.ignoreValues()
    )
    .switchMap { _ in
      AppEnvironment.current.apiService.fetchUserSelf()
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .prefix(SignalProducer([AppEnvironment.current.currentUser].compact()))
        .materialize()
    }

    let user = fetchedUserEvent.values()

    self.updateCurrentUserInEnvironment = user.skip(first: 1)

    self.postNotification = self.currentUserUpdatedInEnvironmentProperty.signal
      .mapConst(Notification(name: .ksr_userUpdated, object: nil))

    self.avatarURL = user.map { URL(string: $0.avatar.large ?? $0.avatar.medium) }

    self.backedButtonTitleText = user.map { user in
      Strings.projects_count_newline_backed(projects_count: user.stats.backedProjectsCount ?? 0)
    }

    self.backerNameText = user.map { $0.name }

    self.savedButtonTitleText = user.map { user in
      Strings.projects_count_newline_saved(projects_count: user.stats.starredProjectsCount ?? 0)
    }

    let swipedToTab = self.willTransitionToPageProperty.signal
      .takeWhen(self.pageTransitionCompletedProperty.signal.filter(isTrue))
      .map { BackerDashboardTab.allTabs[$0] }

    self.navigateToTab = Signal.merge(
      swipedToTab,
      self.backedProjectsButtonTappedProperty.signal.mapConst(.backed),
      self.savedProjectsButtonTappedProperty.signal.mapConst(.saved)
    )

    self.currentSelectedTabProperty <~ self.navigateToTab

    self.setSelectedButton = Signal.merge(
      self.backedButtonTitleText.skip(first: 1).mapConst(.backed).take(first: 1),
      self.navigateToTab
    )

    self.pinSelectedIndicatorToTab = Signal.merge(
      self.backedButtonTitleText.skip(first: 1).mapConst((.backed, false)).take(first: 1),
      self.navigateToTab.map { ($0, true) }.skipRepeats(==)
    )

    self.goToMessages = self.messagesButtonTappedProperty.signal

    self.goToSettings = self.settingsButtonTappedProperty.signal

    self.sortBarIsHidden = self.viewDidLoadProperty.signal.mapConst(true)

    self.embeddedViewTopConstraintConstant = self.sortBarIsHidden
      .map { $0 ? 0.0 : Styles.grid(2) }

    self.initialTopConstantProperty <~ self.beganPanGestureProperty.signal
      .skipNil()
      // NB: This min value accounts for when the header is collapsed by panning the header view
      // instead of the tableView.
      .map { headerTopConstant, scrollViewYOffset in
        min(headerTopConstant, -scrollViewYOffset)
      }

    self.currentSelectedTabProperty
      .signal
      .filter { $0 == .saved }
      .observeValues { _ in
        let params = DiscoveryParams.defaults |> DiscoveryParams.lens.starred .~ true
        AppEnvironment.current.ksrAnalytics.trackProfilePageFilterSelected(
          params: params
        )
      }
  }

  private let backedProjectsButtonTappedProperty = MutableProperty(())
  public func backedProjectsButtonTapped() {
    self.backedProjectsButtonTappedProperty.value = ()
  }

  private let beganPanGestureProperty = MutableProperty<(CGFloat, CGFloat)?>(nil)
  public func beganPanGestureWith(headerTopConstant: CGFloat, scrollViewYOffset: CGFloat) {
    self.beganPanGestureProperty.value = (headerTopConstant, scrollViewYOffset)
  }

  private let currentSelectedTabProperty = MutableProperty<BackerDashboardTab>(.backed)
  public var currentSelectedTab: BackerDashboardTab {
    return self.currentSelectedTabProperty.value
  }

  private let currentUserUpdatedInEnvironmentProperty = MutableProperty(())
  public func currentUserUpdatedInEnvironment() {
    self.currentUserUpdatedInEnvironmentProperty.value = ()
  }

  private let initialTopConstantProperty = MutableProperty<CGFloat>(0.0)
  public var initialTopConstant: CGFloat {
    return self.initialTopConstantProperty.value
  }

  private let messagesButtonTappedProperty = MutableProperty(())
  public func messagesButtonTapped() {
    self.messagesButtonTappedProperty.value = ()
  }

  private let pageTransitionCompletedProperty = MutableProperty(false)
  public func pageTransition(completed: Bool) {
    self.pageTransitionCompletedProperty.value = completed
  }

  private let projectSavedProperty = MutableProperty(())
  public func projectSaved() {
    self.projectSavedProperty.value = ()
  }

  private let savedProjectsButtonTappedProperty = MutableProperty(())
  public func savedProjectsButtonTapped() {
    self.savedProjectsButtonTappedProperty.value = ()
  }

  private let settingsButtonTappedProperty = MutableProperty(())
  public func settingsButtonTapped() {
    self.settingsButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(false)
  public func viewWillAppear(_ animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  private let willTransitionToPageProperty = MutableProperty<Int>(0)
  public func willTransition(toPage nextPage: Int) {
    self.willTransitionToPageProperty.value = nextPage
  }

  public let avatarURL: Signal<URL?, Never>
  public let backedButtonTitleText: Signal<String, Never>
  public let backerNameText: Signal<String, Never>
  public let configurePagesDataSource: Signal<(BackerDashboardTab, DiscoveryParams.Sort), Never>
  public let embeddedViewTopConstraintConstant: Signal<CGFloat, Never>
  public let goToMessages: Signal<(), Never>
  public let goToSettings: Signal<(), Never>
  public let navigateToTab: Signal<BackerDashboardTab, Never>
  public let pinSelectedIndicatorToTab: Signal<(BackerDashboardTab, Bool), Never>
  public let postNotification: Signal<Notification, Never>
  public let savedButtonTitleText: Signal<String, Never>
  public let setSelectedButton: Signal<BackerDashboardTab, Never>
  public let sortBarIsHidden: Signal<Bool, Never>
  public let updateCurrentUserInEnvironment: Signal<User, Never>

  public var inputs: BackerDashboardViewModelInputs { return self }
  public var outputs: BackerDashboardViewModelOutputs { return self }
}
