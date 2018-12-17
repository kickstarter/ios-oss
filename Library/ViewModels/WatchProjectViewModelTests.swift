import Prelude
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class WatchProjectViewModelTests: TestCase {
  internal let vm = WatchProjectViewModel()

  internal let generateImpactFeedback = TestObserver<(), NoError>()
  internal let generateSelectionFeedback = TestObserver<(), NoError>()
  internal let generateSuccessFeedback = TestObserver<(), NoError>()
  internal let goToLoginTout = TestObserver<(), NoError>()
  internal let postNotificationWithProject = TestObserver<Project, NoError>() //fixme: test
  internal let saveButtonAccessibilityValue = TestObserver<String, NoError>()
  internal let saveButtonSelected = TestObserver<Bool, NoError>()
  internal let showNotificationDialog = TestObserver<Notification.Name, NoError>()
  internal let showProjectSavedAlert = TestObserver<Void, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.generateImpactFeedback.observe(self.generateImpactFeedback.observer)
    self.vm.outputs.generateSelectionFeedback.observe(self.generateSelectionFeedback.observer)
    self.vm.outputs.generateSuccessFeedback.observe(self.generateSuccessFeedback.observer)
    self.vm.outputs.goToLoginTout.observe(self.goToLoginTout.observer)
    self.vm.outputs.saveButtonAccessibilityValue.observe(self.saveButtonAccessibilityValue.observer)
    self.vm.outputs.saveButtonSelected.observe(self.saveButtonSelected.observer)
    self.vm.outputs.showNotificationDialog.map { $0.name }.observe(self.showNotificationDialog.observer)
    self.vm.outputs.showProjectSavedAlert.observe(self.showProjectSavedAlert.observer)
  }

  func testSaveAlertNotification() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configure(with: .template)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.saveButtonTapped(selected: true)
      self.scheduler.advance(by: .seconds(1))
      self.showProjectSavedAlert.assertValueCount(1)
    }
  }

  func testGenerateImpactFeedback() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configure(with: .template)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.saveButtonTouched()
      self.generateImpactFeedback.assertValueCount(1)
    }
  }

  func testGenerateSelectionFeedback() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configure(with: .template)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.saveButtonTapped(selected: true)
      self.scheduler.advance()
      self.generateSelectionFeedback.assertValueCount(1)
      self.generateSuccessFeedback.assertValueCount(0)
    }
  }

  func testGenerateSuccessFeedback() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configure(with: .template)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.saveButtonTapped(selected: false)
      self.scheduler.advance()
      self.generateSelectionFeedback.assertValueCount(0)
      self.generateSuccessFeedback.assertValueCount(1)
    }
  }

  func testWatchProject_WithError() {
    let project = Project.template

    withEnvironment(apiService: MockService(watchProjectMutationResult: .failure(.invalidInput)),
                    currentUser: .template) {

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.saveButtonSelected.assertValues([false], "Save button is not selected at first.")

      self.vm.inputs.saveButtonTapped(selected: false)

      self.saveButtonSelected.assertValues([false, true],
                                           "Emits true because it's toggled immmediately.")

      self.scheduler.advance(by: .milliseconds(500))

      self.saveButtonSelected.assertValues([false, true, false],
                                           "Returns to false on error.")
    }
  }

  func testUnwatchProject_LoggedIn_User() {
    let project = Project.template
      |> Project.lens.personalization.isStarred .~ true

    withEnvironment(apiService: MockService(unwatchProjectMutationResult: .success(.unwatchTemplate)),
                    currentUser: .template) {

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.saveButtonSelected.assertValues([true], "Save button is selected at first.")

      self.vm.inputs.saveButtonTapped(selected: true)

      self.saveButtonSelected.assertValues([true, false], "Emits false immediately.")

      self.scheduler.advance(by: .milliseconds(500))

      self.saveButtonSelected.assertValues(
        [true, false],
        "Save button remains deselected after request."
      )
    }
  }

  func testUnwatchProject_LoggedIn_User_Debouncing() {
    let project = Project.template
      |> Project.lens.personalization.isStarred .~ true

    withEnvironment(
      apiService: MockService(unwatchProjectMutationResult: .success(.unwatchTemplate)),
      currentUser: .template) {

        self.vm.inputs.configure(with: project)
        self.vm.inputs.viewDidLoad()

        self.saveButtonSelected.assertValues([true], "Save button is selected at first.")

        self.vm.inputs.saveButtonTapped(selected: true)

        self.saveButtonSelected.assertValues([true, false], "Emits false immediately.")

        self.vm.inputs.saveButtonTapped(selected: false)
        self.scheduler.advance(by: .milliseconds(250))

        self.vm.inputs.saveButtonTapped(selected: true)
        self.scheduler.advance(by: .milliseconds(250))

        self.vm.inputs.saveButtonTapped(selected: false)
        self.scheduler.advance(by: .milliseconds(250))

        self.saveButtonSelected.assertValues(
          [true, false, true, false, true], "State flips back and forth as button is tapped."
        )

        self.vm.inputs.saveButtonTapped(selected: true)
        self.scheduler.advance(by: .milliseconds(500))

        self.saveButtonSelected.assertValues(
          [true, false, true, false, true, false],
          "Network call is made after 0.5 seconds of no taps, value from response is always used"
        )
    }
  }

  func testWatchProject_LoggedOut_User() {
    let project = Project.template
      |> Project.lens.personalization.isStarred .~ false

    withEnvironment(apiService: MockService(watchProjectMutationResult: .success(.watchTemplate))) {

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.saveButtonSelected.assertValues([false], "Save button is not selected for logged out user.")

      self.vm.inputs.saveButtonTapped(selected: false)

      self.saveButtonSelected.assertValues([false],
                                           "Nothing is emitted when save button tapped while logged out.")

      self.goToLoginTout.assertValueCount(1,
                                          "Prompt to login when save button tapped while logged out.")

      AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))
      self.vm.inputs.userSessionStarted()

      self.saveButtonSelected.assertValues([false, true],
                                           "Once logged in, the save button is selected immediately.")

      self.scheduler.advance(by: .milliseconds(500))

      self.saveButtonSelected.assertValues([false, true],
                                           "Save button stays selected after API request.")

      withEnvironment(apiService: MockService(watchProjectMutationResult: .success(.watchTemplate))) {
        self.vm.inputs.saveButtonTapped(selected: true)

        self.saveButtonSelected.assertValues([false, true, false],
                                             "Save button is deselected.")

        self.scheduler.advance(by: .milliseconds(500))

        self.saveButtonSelected.assertValues([false, true, false],
                                             "The save button remains unselected.")
      }
    }
  }

  func testWatchProjectFromPamphlet() {
    let project = Project.template
      |> Project.lens.personalization.isStarred .~ false
    let projectUpdated = project
      |> Project.lens.personalization.isStarred .~ true

    self.vm.inputs.configure(with: project)
    self.vm.inputs.viewDidLoad()

    self.saveButtonSelected.assertValues([false])

    self.vm.inputs.projectFromNotification(project: projectUpdated)

    self.saveButtonSelected.assertValues([false, true])
  }

  func testShowNotificationDialogEmits_IfStarredProjectsCountIsZero() {
    let user = User.template |> \.stats.starredProjectsCount .~ 0

    withEnvironment(currentUser: user) {
      self.vm.inputs.configure(with: .template)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.saveButtonTapped(selected: false)
      self.scheduler.advance(by: .milliseconds(500))

      self.showNotificationDialog.assertDidEmitValue()
    }
  }

  func testShowNotificationDialogDoesNotEmit_IfStarredProjectsCountIsNotZero() {
    let project = Project.template
    let user = User.template |> \.stats.starredProjectsCount .~ 3

    withEnvironment(currentUser: user) {
      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.saveButtonTapped(selected: true)
      self.scheduler.advance(by: .milliseconds(500))

      self.showNotificationDialog.assertDidNotEmitValue()
    }
  }

  func testLoggedInUser_WatchesAndUnwatchesProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = Project.template
      |> Project.lens.personalization.isStarred .~ false

    withEnvironment(apiService: MockService(watchProjectMutationResult: .success(.watchTemplate))) {
      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.saveButtonSelected.assertValues([false], "Save button is not selected at first")
      self.saveButtonAccessibilityValue.assertValues(["Unsaved"])

      self.vm.inputs.saveButtonTapped(selected: false)

      self.saveButtonSelected.assertValues([false, true], "Save button selects immediately.")
      self.saveButtonAccessibilityValue.assertValues(["Unsaved", "Saved"])

      self.scheduler.advance(by: .milliseconds(500))

      self.saveButtonSelected.assertValues([false, true],
                                           "Save button remains selected.")

      self.showProjectSavedAlert.assertValueCount(1, "The save project prompt shows.")
      XCTAssertEqual(["Project Star", "Starred Project", "Saved Project"],
                     trackingClient.events, "A star koala event is tracked.")

      withEnvironment(apiService: MockService(unwatchProjectMutationResult: .success(.unwatchTemplate))) {
        self.vm.inputs.saveButtonTapped(selected: true)

        self.saveButtonSelected.assertValues([false, true, false],
                                             "Save button deselects immediately.")
        self.saveButtonAccessibilityValue.assertValues(["Unsaved", "Saved", "Unsaved"])

        self.scheduler.advance(by: .milliseconds(500))

        self.saveButtonSelected.assertValues([false, true, false],
                                             "The save button remains unselected.")
        self.saveButtonAccessibilityValue.assertValues(["Unsaved", "Saved", "Unsaved"])

        self.showProjectSavedAlert.assertValueCount(1, "The save project prompt only showed for starring.")
        XCTAssertEqual(["Project Star", "Starred Project", "Saved Project", "Project Unstar",
                        "Unstarred Project", "Unsaved Project"],
                       self.trackingClient.events, "An unstar koala event is tracked.")
      }
    }
  }

  func testLoggedInUser_WatchEndingSoonProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = .template
      |> Project.lens.personalization.isStarred .~ false
      |> Project.lens.dates.deadline .~ (MockDate().date.timeIntervalSince1970 + 60.0 * 60.0 * 24.0)

    withEnvironment(apiService: MockService(watchProjectMutationResult: .success(.watchTemplate))) {
      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.saveButtonTapped(selected: false)
      self.scheduler.advance(by: .milliseconds(500))

      self.showProjectSavedAlert.assertValueCount(
        0, "The save project prompt doesn't show cause it's less than 48hrs."
      )

      XCTAssertEqual(["Project Star", "Starred Project", "Saved Project"], self.trackingClient.events,
                     "A star koala event is tracked.")
    }
  }
}
