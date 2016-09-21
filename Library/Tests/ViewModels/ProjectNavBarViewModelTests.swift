import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectNavBarViewModelTests: TestCase {
  private let vm: ProjectNavBarViewModelType = ProjectNavBarViewModel()

  private let categoryButtonBackgroundColor = TestObserver<UIColor, NoError>()
  private let categoryButtonText = TestObserver<String, NoError>()
  private let categoryButtonTintColor = TestObserver<UIColor, NoError>()
  private let categoryButtonTitleColor = TestObserver<UIColor, NoError>()
  private let categoryHidden = TestObserver<Bool, NoError>()
  private let categoryAnimate = TestObserver<Bool, NoError>()
  private let goToLoginTout = TestObserver<(), NoError>()
  private let projectName = TestObserver<String, NoError>()
  private let showProjectStarredPrompt = TestObserver<String, NoError>()
  private let starButtonAccessibilityHint = TestObserver<String, NoError>()
  private let starButtonSelected = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.categoryButtonBackgroundColor.observe(self.categoryButtonBackgroundColor.observer)
    self.vm.outputs.categoryButtonText.observe(self.categoryButtonText.observer)
    self.vm.outputs.categoryButtonTintColor.observe(self.categoryButtonTintColor.observer)
    self.vm.outputs.categoryButtonTitleColor.observe(self.categoryButtonTitleColor.observer)
    self.vm.outputs.categoryHiddenAndAnimate.map(first).observe(self.categoryHidden.observer)
    self.vm.outputs.categoryHiddenAndAnimate.map(second).observe(self.categoryAnimate.observer)
    self.vm.outputs.goToLoginTout.observe(self.goToLoginTout.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.showProjectStarredPrompt.observe(self.showProjectStarredPrompt.observer)
    self.vm.outputs.starButtonSelected.observe(self.starButtonSelected.observer)
    self.vm.outputs.starButtonAccessibilityHint.observe(self.starButtonAccessibilityHint.observer)
  }

  func testCategoryButtonBackgroundColor() {

  }

  func testCategoryButtonText() {
    self.vm.inputs.configureWith(project: .template |> Project.lens.category.name .~ "Some Category")
    self.vm.inputs.viewDidLoad()

    self.categoryButtonText.assertValues(["Some Category"])
  }

  // Tests the flow of a logged out user trying to star a project, and then going through the login flow.
  func testLoggedOutUser_StarsProject() {
    let project = .template |> Project.lens.personalization.isStarred .~ false
    let toggleStarResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ true)

    withEnvironment(apiService: MockService(toggleStarResponse: toggleStarResponse)) {
      self.starButtonSelected.assertDidNotEmitValue("No values emitted at first.")
      self.vm.inputs.configureWith(project: project)
      self.vm.inputs.viewDidLoad()

      self.starButtonSelected.assertValues([false], "Star button is not selected at first")

      self.vm.inputs.starButtonTapped()

      self.starButtonSelected.assertValues([false], "Nothing is emitted when starring while logged out.")
      self.goToLoginTout.assertValueCount(1, "Prompt to login when starring while logged out.")

      AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))
      self.vm.inputs.userSessionStarted()

      self.starButtonSelected.assertValues([false, true], "Once logged in, the project stars immediately.")

      self.scheduler.advance()

      self.starButtonSelected.assertValues([false, true],
                                           "Star stays selected after API request.")
      self.showProjectStarredPrompt.assertValueCount(1, "The star prompt shows.")
      XCTAssertEqual(["Project Star"], trackingClient.events, "A star koala event is tracked.")
    }
  }

  // Tests a logged in user starring a project.
  func testLoggedInUser_StarsAndUnstarsProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = Project.template
    let toggleStarResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ true)

    withEnvironment(apiService: MockService(toggleStarResponse: toggleStarResponse)) {
      self.vm.inputs.configureWith(project: project)
      self.vm.inputs.viewDidLoad()

      self.starButtonSelected.assertValues([false], "Star button is not selected at first")

      self.vm.inputs.starButtonTapped()

      self.starButtonSelected.assertValues([false, true], "Star button selects immediately.")
      self.scheduler.advance()

      self.showProjectStarredPrompt.assertValueCount(1, "The star prompt shows.")
      XCTAssertEqual(["Project Star"], trackingClient.events, "A star koala event is tracked.")

      let untoggleStarResponse = .template
        |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ false)

      withEnvironment(apiService: MockService(toggleStarResponse: untoggleStarResponse)) {
        self.vm.inputs.starButtonTapped()

        self.starButtonSelected.assertValues([false, true, false],
                                             "The project unstars immediately.")

        self.scheduler.advance()

        self.starButtonSelected.assertValues([false, true, false],
                                             "The star button stays unselected.")

        self.showProjectStarredPrompt.assertValueCount(1, "The star prompt only showed for starring.")
        XCTAssertEqual(["Project Star", "Project Unstar"], self.trackingClient.events,
                       "An unstar koala event is tracked.")
      }
    }
  }

  // Tests a logged in user starring a project that ends soon.
  func testLoggedInUser_StarsEndingSoonProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = .template
      |> Project.lens.personalization.isStarred .~ false
      |> Project.lens.dates.deadline .~ (NSDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)

    let toggleStarResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ true)

    withEnvironment(apiService: MockService(toggleStarResponse: toggleStarResponse)) {
      self.vm.inputs.configureWith(project: project)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.starButtonTapped()
      self.scheduler.advance()

      self.showProjectStarredPrompt.assertValueCount(
        0, "The star prompt doesn't show cause it's less than 48hrs."
      )

      XCTAssertEqual(["Project Star"], self.trackingClient.events,
                     "A star koala event is tracked.")
    }
  }

  // Tests a user unstarring a project.
  func testLoggedInUser_UnstarsProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = .template |> Project.lens.personalization.isStarred .~ true
    let toggleStarResponse = .template
      |> StarEnvelope.lens.project .~ (project |> Project.lens.personalization.isStarred .~ false)

    withEnvironment(apiService: MockService(toggleStarResponse: toggleStarResponse)) {
      self.vm.inputs.configureWith(project: project)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.starButtonTapped()
      self.scheduler.advance()

      self.showProjectStarredPrompt.assertValueCount(0, "The star prompt does not show.")

      XCTAssertEqual(["Project Unstar"], self.trackingClient.events,
                     "An unstar koala event is tracked.")
    }
  }

  func testLoggedInStarFailure() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: .template))

    let project = .template |> Project.lens.personalization.isStarred .~ false

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.starButtonTapped()

    self.starButtonSelected.assertValues([false, true])

    self.scheduler.advance()

    self.starButtonSelected.assertValues([false, true, false])

    self.showProjectStarredPrompt.assertValueCount(0, "The star prompt does not show.")
    XCTAssertEqual([], trackingClient.events, "The star event does not track.")

    self.vm.inputs.starButtonTapped()

    // fix:
    //    self.starButtonSelected.assertValues([false, true, false, true])
    //
    //    self.scheduler.advance()
    //
    //    self.starButtonSelected.assertValues([false, true, false, true, false])
  }
}
