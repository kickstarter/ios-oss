import KsApi
import Library
import Models
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

internal protocol ActitiviesViewModelInputs {
  /// Call when the view appears.
  func viewWillAppear()

  /// Call when the login button is pressed in the logged-out empty state.
  func loginButtonPressed()

  /// Call when a user session has started
  func userSessionStarted()

  // Call when a user session ends
  func userSessionEnded()
}

internal protocol ActivitiesViewModelOutputs {
  /// Emits an array of activities that should be displayed
  var activities: Signal<[Activity], NoError> { get }

  /// Emits `true` when the logged-out empty state should be shown, and `false` when it should be hidden.
  var showLoggedOutEmptyState: Signal<Bool, NoError> { get }

  /// Emits `true` when the logged-in empty state should be shown, and `false` when it should be hidden.
  var showLoggedInEmptyState: Signal<Bool, NoError> { get }
}

internal protocol ActivitiesViewModelType {
  var inputs: ActitiviesViewModelInputs { get }
  var outputs: ActivitiesViewModelOutputs { get }
}

internal final class ActivitiesViewModel: ViewModelType, ActivitiesViewModelType, ActitiviesViewModelInputs,
ActivitiesViewModelOutputs {
  typealias Model = Activity

  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  private let loginButtonPressedProperty = MutableProperty(())
  internal func loginButtonPressed() {
    self.loginButtonPressedProperty.value = ()
  }
  private let userSessionStartedProperty = MutableProperty(())
  internal func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  private let userSessionEndedProperty = MutableProperty(())
  func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  internal let activities: Signal<[Activity], NoError>
  internal let showLoggedInEmptyState: Signal<Bool, NoError>
  internal let showLoggedOutEmptyState: Signal<Bool, NoError>

  internal var inputs: ActitiviesViewModelInputs { return self }
  internal var outputs: ActivitiesViewModelOutputs { return self }

  init() {
    let koala = AppEnvironment.current.koala

    let apiService = Signal.merge([
      self.viewWillAppearProperty.signal,
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal
      ])
      .map { AppEnvironment.current.apiService }
      .skipRepeats(==)

    let isLoggedIn = apiService.map { $0.isAuthenticated }.skipRepeats()

    let loggedInActivities = apiService
      .filter { $0.isAuthenticated }
      .switchMap { $0.fetchActivities().demoteErrors() }
      .map { $0.activities }
      .skipRepeats(==)

    let clearedActivitiesOnSessionEnd = self.userSessionEndedProperty.signal.mapConst([Activity]())

    self.activities = combineLatest(
        self.viewWillAppearProperty.signal.take(1),
        Signal.merge([loggedInActivities, clearedActivitiesOnSessionEnd])
      )
      .map { _, activities in activities }

    let noActivities = self.activities.filter { $0.isEmpty }.ignoreValues()

    self.showLoggedInEmptyState = isLoggedIn
      .takeWhen(noActivities)
      .skipRepeats()

    self.showLoggedOutEmptyState = isLoggedIn
      .skipWhile { $0 }
      .map { !$0 }
      .skipRepeats()

    self.viewWillAppearProperty.signal
      .observeNext { koala.trackActivities() }
  }
}
