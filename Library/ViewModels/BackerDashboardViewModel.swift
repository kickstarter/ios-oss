import KsApi
import Prelude
import ReactiveSwift
import Result

public enum BackerDashboardTab {
  case backed
  case saved

  public static let allTabs: [BackerDashboardTab] = [.backed, .saved]
}

public protocol BackerDashboardViewModelInputs {
  /// Call when backed projects button is tapped.
  func backedProjectsButtonTapped()

  /// Call when messages button is tapped.
  func messagesButtonTapped()

  /// Call when saved projects button is tapped.
  func savedProjectsButtonTapped()

  /// Call when settings button is tapped.
  func settingsButtonTapped()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view will appear.
  func viewWillAppear(_ animated: Bool)
}

public protocol BackerDashboardViewModelOutputs {
  /// Emits a URL for the avatar image view.
  var avatarURL: Signal<URL?, NoError> { get }

  /// Emits a string for the backed button title label.
  var backedButtonTitleText: Signal<String, NoError> { get }

  /// Emits a string for the backer location label.
  var backerLocationText: Signal<String, NoError> { get }

  /// Emits a string for the backer name label.
  var backerNameText: Signal<String, NoError> { get }

  /// Emits the initial BackerDashboardTab and a default Sort to configure the page view controller.
  var configurePagesDataSource: Signal<(BackerDashboardTab, DiscoveryParams.Sort), NoError> { get }

  /// Emits a CGFloat to set the top constraint of the embedded views when the sort bar is hidden or not.
  var embeddedViewTopConstraintConstant: Signal<CGFloat, NoError> { get }

  /// Emits when to present Messages.
  var goToMessages: Signal<(), NoError> { get }

  /// Emits when to navigate to Settings.
  var goToSettings: Signal<(), NoError> { get }

  /// Emits a BackerDashboardTab to navigate to.
  var navigateToTab: Signal<BackerDashboardTab, NoError> { get }

  /// Emits a BackerDashboardTab to pin the indicator view to with or without animation.
  var pinSelectedIndicatorToTab: Signal<(BackerDashboardTab, Bool), NoError> { get }

  /// Emits a string for the saved button title label.
  var savedButtonTitleText: Signal<String, NoError> { get }

  /// Emits the selected BackerDashboardTab to set the selected button and update all button selected states.
  var setSelectedButton: Signal<BackerDashboardTab, NoError> { get }

  /// Emits a boolean whether the sort bar is hidden or not.
  var sortBarIsHidden: Signal<Bool, NoError> { get }
}

public protocol BackerDashboardViewModelType {
  var inputs: BackerDashboardViewModelInputs { get }
  var outputs: BackerDashboardViewModelOutputs { get }
}

public final class BackerDashboardViewModel: BackerDashboardViewModelType, BackerDashboardViewModelInputs,
  BackerDashboardViewModelOutputs {

  // swiftlint:disable:next function_body_length
  public init() {
    self.configurePagesDataSource = self.viewDidLoadProperty.signal
      .map { (.backed, DiscoveryParams.Sort.endingSoon) }

    let user = self.viewWillAppearProperty.signal.filter(isFalse).ignoreValues()
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchUserSelf()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .prefix(SignalProducer([AppEnvironment.current.currentUser].compact()))
          .demoteErrors()
    }

    self.avatarURL = user.map { URL(string: $0.avatar.large ?? $0.avatar.medium) }

    self.backedButtonTitleText = user.map { user in
        Strings.projects_count_newline_backed(projects_count: user.stats.backedProjectsCount ?? 0)
    }

    self.backerLocationText = user.map { $0.location?.displayableName ?? "" }

    self.backerNameText = user.map { $0.name }

    self.savedButtonTitleText = user.map { user in
      Strings.projects_count_newline_saved(projects_count: user.stats.starredProjectsCount ?? 0)
    }

    self.navigateToTab = Signal.merge(
      self.backedProjectsButtonTappedProperty.signal.mapConst(.backed),
      self.savedProjectsButtonTappedProperty.signal.mapConst(.saved)
    )

    self.setSelectedButton = Signal.merge(
      self.backedButtonTitleText.skip(first: 1).mapConst(.backed),
      self.navigateToTab
    )

    self.pinSelectedIndicatorToTab = Signal.merge(
      self.backedButtonTitleText.skip(first: 1).mapConst((.backed, false)),
      self.navigateToTab.map { ($0, true) }.skipRepeats(==)
    )

    self.goToMessages = self.messagesButtonTappedProperty.signal

    self.goToSettings = self.settingsButtonTappedProperty.signal

    self.sortBarIsHidden = self.viewDidLoadProperty.signal.mapConst(true)

    self.embeddedViewTopConstraintConstant = self.sortBarIsHidden
      .map { $0 ? 0.0 : Styles.grid(2) }

    self.viewWillAppearProperty.signal.filter(isFalse)
      .observeValues { _ in AppEnvironment.current.koala.trackProfileView() }
  }

  private let backedProjectsButtonTappedProperty = MutableProperty()
  public func backedProjectsButtonTapped() {
    self.backedProjectsButtonTappedProperty.value = ()
  }

  private let messagesButtonTappedProperty = MutableProperty()
  public func messagesButtonTapped() {
    self.messagesButtonTappedProperty.value = ()
  }

  private let savedProjectsButtonTappedProperty = MutableProperty()
  public func savedProjectsButtonTapped() {
    self.savedProjectsButtonTappedProperty.value = ()
  }

  private let settingsButtonTappedProperty = MutableProperty()
  public func settingsButtonTapped() {
    self.settingsButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(false)
  public func viewWillAppear(_ animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  public let avatarURL: Signal<URL?, NoError>
  public let backedButtonTitleText: Signal<String, NoError>
  public let backerLocationText: Signal<String, NoError>
  public let backerNameText: Signal<String, NoError>
  public let configurePagesDataSource: Signal<(BackerDashboardTab, DiscoveryParams.Sort), NoError>
  public let embeddedViewTopConstraintConstant: Signal<CGFloat, NoError>
  public let goToMessages: Signal<(), NoError>
  public let goToSettings: Signal<(), NoError>
  public let navigateToTab: Signal<BackerDashboardTab, NoError>
  public let pinSelectedIndicatorToTab: Signal<(BackerDashboardTab, Bool), NoError>
  public let savedButtonTitleText: Signal<String, NoError>
  public let setSelectedButton: Signal<BackerDashboardTab, NoError>
  public let sortBarIsHidden: Signal<Bool, NoError>

  public var inputs: BackerDashboardViewModelInputs { return self }
  public var outputs: BackerDashboardViewModelOutputs { return self }
}
