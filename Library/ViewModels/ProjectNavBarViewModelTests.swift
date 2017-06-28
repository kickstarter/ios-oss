import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectNavBarViewModelTests: TestCase {
  fileprivate let vm: ProjectNavBarViewModelType = ProjectNavBarViewModel()

  fileprivate let backgroundAnimate = TestObserver<Bool, NoError>()
  fileprivate let backgroundOpaque = TestObserver<Bool, NoError>()
  fileprivate let categoryButtonText = TestObserver<String, NoError>()
  fileprivate let categoryButtonTintColor = TestObserver<UIColor, NoError>()
  fileprivate let categoryButtonTitleColor = TestObserver<UIColor, NoError>()
  fileprivate let categoryHidden = TestObserver<Bool, NoError>()
  fileprivate let categoryAnimate = TestObserver<Bool, NoError>()
  fileprivate let dismissViewController = TestObserver<(), NoError>()
  fileprivate let goToLoginTout = TestObserver<(), NoError>()
  fileprivate let projectName = TestObserver<String, NoError>()
  fileprivate let showProjectSavedPrompt = TestObserver<Void, NoError>()
  fileprivate let starButtonAccessibilityHint = TestObserver<String, NoError>()
  fileprivate let heartButtonEnabled = TestObserver<Bool, NoError>()
  fileprivate let heartButtonSelected = TestObserver<Bool, NoError>()
  fileprivate let titleAnimate = TestObserver<Bool, NoError>()
  fileprivate let titleHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backgroundOpaqueAndAnimate.map(second).observe(self.backgroundAnimate.observer)
    self.vm.outputs.backgroundOpaqueAndAnimate.map(first).observe(self.backgroundOpaque.observer)
    self.vm.outputs.categoryButtonText.observe(self.categoryButtonText.observer)
    self.vm.outputs.categoryButtonTintColor.observe(self.categoryButtonTintColor.observer)
    self.vm.outputs.categoryButtonTitleColor.observe(self.categoryButtonTitleColor.observer)
    self.vm.outputs.categoryHiddenAndAnimate.map(first).observe(self.categoryHidden.observer)
    self.vm.outputs.categoryHiddenAndAnimate.map(second).observe(self.categoryAnimate.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.goToLoginTout.observe(self.goToLoginTout.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.showProjectSavedPrompt.observe(self.showProjectSavedPrompt.observer)
    self.vm.outputs.heartButtonSelected.observe(self.heartButtonSelected.observer)
    self.vm.outputs.starButtonAccessibilityHint.observe(self.starButtonAccessibilityHint.observer)
    self.vm.outputs.heartButtonEnabled.observe(self.heartButtonEnabled.observer)
    self.vm.outputs.titleHiddenAndAnimate.map(second).observe(self.titleAnimate.observer)
    self.vm.outputs.titleHiddenAndAnimate.map(first).observe(self.titleHidden.observer)
  }

  func testBackgroundOpaqueAndAnimate() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.backgroundOpaque.assertValues([false])
    self.backgroundAnimate.assertValues([false])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.backgroundOpaque.assertValues([false, true])
    self.backgroundAnimate.assertValues([false, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.backgroundOpaque.assertValues([false, true, false])
    self.backgroundAnimate.assertValues([false, true, true])

    // start video
    self.vm.inputs.projectVideoDidStart()

    self.backgroundOpaque.assertValues([false, true, false])
    self.backgroundAnimate.assertValues([false, true, true])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.backgroundOpaque.assertValues([false, true, false, true])
    self.backgroundAnimate.assertValues([false, true, true, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.backgroundOpaque.assertValues([false, true, false, true, false])
    self.backgroundAnimate.assertValues([false, true, true, true, true])

    // finish video
    self.vm.inputs.projectVideoDidFinish()

    self.backgroundOpaque.assertValues([false, true, false, true, false])
    self.backgroundAnimate.assertValues([false, true, true, true, true])
  }

  func testCategoryButtonText() {
    self.vm.inputs.configureWith(
      project: .template |> Project.lens.category.name .~ "Some Category",
      refTag: nil
    )
    self.vm.inputs.viewDidLoad()

    self.categoryButtonText.assertValues(["Some Category"])
  }

  func testCategoryHiddenAndAnimate() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.categoryHidden.assertValues([false])
    self.categoryAnimate.assertValues([false])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.categoryHidden.assertValues([false, true])
    self.categoryAnimate.assertValues([false, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.categoryHidden.assertValues([false, true, false])
    self.categoryAnimate.assertValues([false, true, true])

    // start video
    self.vm.inputs.projectVideoDidStart()

    self.categoryHidden.assertValues([false, true, false, true])
    self.categoryAnimate.assertValues([false, true, true, true])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.categoryHidden.assertValues([false, true, false, true])
    self.categoryAnimate.assertValues([false, true, true, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.categoryHidden.assertValues([false, true, false, true])
    self.categoryAnimate.assertValues([false, true, true, true])

    // finish video
    self.vm.inputs.projectVideoDidFinish()

    self.categoryHidden.assertValues([false, true, false, true, false])
    self.categoryAnimate.assertValues([false, true, true, true, true])
  }

  func testCategoryHiddenAndAnimate_PlayVideoWithoutScrolling() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.categoryHidden.assertValues([false])
    self.categoryAnimate.assertValues([false])

    self.vm.inputs.projectVideoDidStart()

    self.categoryHidden.assertValues([false, true])
    self.categoryAnimate.assertValues([false, true])

    self.vm.inputs.projectVideoDidFinish()

    self.categoryHidden.assertValues([false, true, false])
    self.categoryAnimate.assertValues([false, true, true])
  }

  func testDismissViewController() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.dismissViewController.assertValueCount(0)

    self.vm.inputs.closeButtonTapped()

    self.dismissViewController.assertValueCount(1)
  }

  // Tests the flow of a logged out user trying to heart a project, and then going through the login flow.
  func testLoggedOutUser_HeartsProject() {
    let project = .template |> Project.lens.personalization.isStarred .~ false
    let toggleHeartResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ true)

    withEnvironment(apiService: MockService(toggleStarResponse: toggleHeartResponse)) {
      self.heartButtonEnabled.assertDidNotEmitValue()
      self.heartButtonSelected.assertDidNotEmitValue("No values emitted at first.")
      self.vm.inputs.configureWith(project: project, refTag: nil)
      self.vm.inputs.viewDidLoad()

      self.heartButtonSelected.assertValues([false], "Heart button is not selected at first")
      self.heartButtonEnabled.assertDidNotEmitValue()

      self.vm.inputs.heartButtonTapped()

      self.heartButtonSelected.assertValues([false], "Nothing is emitted when heart button tapped while logged out.")
      self.heartButtonEnabled.assertDidNotEmitValue()

      self.goToLoginTout.assertValueCount(1, "Prompt to login when hearting while logged out.")

      AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))
      self.vm.inputs.userSessionStarted()

      self.heartButtonSelected.assertValues([false, true], "Once logged in, the heart is selected immediately.")
      self.heartButtonEnabled.assertValues([false, true])

      self.scheduler.advance()

      self.heartButtonSelected.assertValues([false, true],
                                           "Heart button stays selected after API request.")
      self.heartButtonEnabled.assertValues([false, true])
      self.showProjectSavedPrompt.assertValueCount(0, "The save project prompt does not show.")
      XCTAssertEqual(["Project Star", "Starred Project"],
                     trackingClient.events, "A star koala event is tracked.")
    }
  }

  // Tests a logged in user hearting a project.
  func testLoggedInUser_HeartsAndUnheartsProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = Project.template
    let toggleHeartResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ true)

    withEnvironment(apiService: MockService(toggleStarResponse: toggleHeartResponse)) {
      self.vm.inputs.configureWith(project: project, refTag: nil)
      self.vm.inputs.viewDidLoad()

      self.heartButtonSelected.assertValues([false], "Heart button is not selected at first")
      self.heartButtonEnabled.assertDidNotEmitValue()

      self.vm.inputs.heartButtonTapped()

      self.heartButtonSelected.assertValues([false, true], "Heart button selects immediately.")
      self.heartButtonEnabled.assertValues([false, true])

      self.scheduler.advance()

      self.showProjectSavedPrompt.assertValueCount(1, "The save project prompt shows.")
      XCTAssertEqual(["Project Star", "Starred Project"],
                     trackingClient.events, "A star koala event is tracked.")

      let untoggleHeartResponse = .template
        |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ false)

      withEnvironment(apiService: MockService(toggleStarResponse: untoggleHeartResponse)) {
        self.vm.inputs.heartButtonTapped()

        self.heartButtonSelected.assertValues([false, true, false],
                                             "Heart button selects immediately.")
        self.heartButtonEnabled.assertValues([false, true, false, true])


        self.scheduler.advance()

        self.heartButtonSelected.assertValues([false, true, false],
                                             "The heart button stays unselected.")

        self.showProjectSavedPrompt.assertValueCount(1, "The save project prompt only showed for starring.")
        XCTAssertEqual(["Project Star", "Starred Project", "Project Unstar", "Unstarred Project"],
                       self.trackingClient.events,
                       "An unstar koala event is tracked.")
      }
    }
  }

  // Tests a logged in user hearting a project that ends soon.
  func testLoggedInUser_HeartEndingSoonProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = .template
      |> Project.lens.personalization.isStarred .~ false
      |> Project.lens.dates.deadline .~ (MockDate().date.timeIntervalSince1970 + 60.0 * 60.0 * 24.0)

    let toggleHeartResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ true)

    withEnvironment(apiService: MockService(toggleStarResponse: toggleHeartResponse)) {
      self.vm.inputs.configureWith(project: project, refTag: nil)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.heartButtonTapped()
      self.scheduler.advance()

      self.showProjectSavedPrompt.assertValueCount(
        0, "The save project prompt doesn't show cause it's less than 48hrs."
      )

      XCTAssertEqual(["Project Star", "Starred Project"], self.trackingClient.events,
                     "A star koala event is tracked.")
    }
  }

  // Tests a user unhearting a project.
  func testLoggedInUser_UnheartsProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = .template |> Project.lens.personalization.isStarred .~ true
    let toggleHeartResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ false)

    withEnvironment(apiService: MockService(toggleStarResponse: toggleHeartResponse)) {
      self.vm.inputs.configureWith(project: project, refTag: nil)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.heartButtonTapped()
      self.scheduler.advance()

      self.showProjectSavedPrompt.assertValueCount(0, "The save project prompt does not show.")

      XCTAssertEqual(["Project Unstar", "Unstarred Project"], self.trackingClient.events,
                     "An unstar koala event is tracked.")
    }
  }

  func testLoggedInHeartFailure() {
    /// CHECK THIS
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = .template |> Project.lens.personalization.isStarred .~ false

    self.vm.inputs.configureWith(project: project, refTag: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.heartButtonTapped()

    self.heartButtonSelected.assertValues([false, true])

    self.scheduler.advance()

    self.heartButtonSelected.assertValues([false, true, false])

    self.showProjectSavedPrompt.assertValueCount(1, "The save project prompt shows.")
    XCTAssertEqual([], trackingClient.events, "The star event does not track.")

    self.vm.inputs.heartButtonTapped()

    // fix:
    //    self.starButtonSelected.assertValues([false, true, false, true])
    //
    //    self.scheduler.advance()
    //
    //    self.starButtonSelected.assertValues([false, true, false, true, false])
  }

  func testTitleHiddenAndAnimate() {
    self.vm.inputs.configureWith(project: .template, refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.titleHidden.assertValues([true])
    self.titleAnimate.assertValues([false])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.titleHidden.assertValues([true, false])
    self.titleAnimate.assertValues([false, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.titleHidden.assertValues([true, false, true])
    self.titleAnimate.assertValues([false, true, true])

    // start video
    self.vm.inputs.projectVideoDidStart()

    self.titleHidden.assertValues([true, false, true])
    self.titleAnimate.assertValues([false, true, true])

    // scroll image off screen
    self.vm.inputs.projectImageIsVisible(false)

    self.titleHidden.assertValues([true, false, true, false])
    self.titleAnimate.assertValues([false, true, true, true])

    // scroll image back on screen
    self.vm.inputs.projectImageIsVisible(true)

    self.titleHidden.assertValues([true, false, true, false, true])
    self.titleAnimate.assertValues([false, true, true, true, true])

    // finish video
    self.vm.inputs.projectVideoDidFinish()

    self.titleHidden.assertValues([true, false, true, false, true])
    self.titleAnimate.assertValues([false, true, true, true, true])
  }
}
