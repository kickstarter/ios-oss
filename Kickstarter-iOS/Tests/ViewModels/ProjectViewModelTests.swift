import XCTest
import ReactiveCocoa
import Result
@testable import Library
@testable import Kickstarter_iOS
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Models
@testable import Models_TestHelpers
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class ProjectViewModelTests: TestCase {
  let vm: ProjectViewModelType = ProjectViewModel()
  let project = TestObserver<Project, NoError>()
  let projectIsStarred = TestObserver<Bool?, NoError>()
  let showLoginTout = TestObserver<(), NoError>()
  let showProjectStarredPrompt = TestObserver<(), NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.project.observe(self.project.observer)
    self.vm.outputs.project.map { $0.personalization.isStarred }.observe(self.projectIsStarred.observer)
    self.vm.outputs.showLoginTout.observe(self.showLoginTout.observer)
    self.vm.outputs.showProjectStarredPrompt.observe(self.showProjectStarredPrompt.observer)
  }

  func testProjectEmissions() {
    self.vm.inputs.project(ProjectFactory.live())
    self.vm.inputs.refTag(nil)

    self.project.assertDidNotEmitValue("Does not emit project right away.")

    self.vm.inputs.viewWillAppear()

    self.project.assertValueCount(1, "Emits project immediately when appearing.")

    // Wait enough time for API request to finish.
    self.scheduler.advance()

    self.project.assertValueCount(2, "Emits refreshed project after some time passes.")
  }

  // Tests that ref tags and referral credit cookies are tracked in koala and saved like we expect.
  func testTracksRefTag() {
    let project = ProjectFactory.live()

    vm.inputs.viewWillAppear()
    vm.inputs.project(project)
    vm.inputs.refTag(RefTag.category)

    XCTAssertEqual([RefTag.category.stringTag],
                   self.trackingClient.properties.flatMap { $0["ref_tag"] as? String },
                   "The ref tag is tracked in the koala event.")
    XCTAssertEqual([RefTag.category.stringTag],
                   self.trackingClient.properties.flatMap { $0["referrer_credit"] as? String },
                   "The referral credit is tracked in the koala event.")
    XCTAssertEqual(1, self.cookieStorage.cookies?.count,
                   "A single cookie is set")
    XCTAssertEqual("ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
                   "A referral cookie is set for the project.")
    XCTAssertEqual("category?", String(self.cookieStorage.cookies!.last!.value.characters.prefix(9)),
                   "A referral cookie is set for the category ref tag.")

    // Start up another view model with the same project
    let newVm: ProjectViewModelType = ProjectViewModel()
    newVm.inputs.viewWillAppear()
    newVm.inputs.project(project)
    newVm.inputs.refTag(RefTag.recommended)

    XCTAssertEqual([RefTag.category.stringTag, RefTag.recommended.stringTag],
                   self.trackingClient.properties.flatMap { $0["ref_tag"] as? String },
                   "The new ref tag is tracked in koala event.")
    XCTAssertEqual([RefTag.category.stringTag, RefTag.category.stringTag],
                   self.trackingClient.properties.flatMap { $0["referrer_credit"] as? String },
                   "The referrer credit did not change, and is still category.")
    XCTAssertEqual(1, self.cookieStorage.cookies?.count,
                   "A single cookie has been set.")
  }

  // Tests the flow of a logged out user trying to star a project, and then going through the login flow.
  func testLoggedOutUser_StarsProject() {
    self.projectIsStarred.assertDidNotEmitValue("No projects emitted at first.")

    vm.inputs.project(ProjectFactory.notStarred)
    vm.inputs.refTag(nil)
    vm.inputs.viewWillAppear()
    self.scheduler.advance()

    self.projectIsStarred.assertValues([false, false],
                                       "Emits project immediately, and then again with update from the API.")
    XCTAssertEqual(["Project Page"], trackingClient.events, "A project page koala event is tracked.")

    vm.inputs.starButtonTapped()

    self.projectIsStarred.assertValues([false, false],
                                       "Nothing is emitted when starring while logged out.")
    self.showLoginTout.assertValueCount(1, "Prompt to login when starring while logged out.")

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))
    vm.inputs.userSessionStarted()

    self.projectIsStarred.assertValues([false, false, true],
                                       "Once logged in, the project stars immediately.")
    showProjectStarredPrompt.assertValueCount(1, "The star prompt shows.")
    XCTAssertEqual(["Project Page", "Project Star"], trackingClient.events, "A star koala event is tracked.")
  }

  // Tests a logged in user starring a project.
  func testLoggedInUser_StarsProject() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))

    self.projectIsStarred.assertDidNotEmitValue("No projects emitted at first.")

    vm.inputs.project(ProjectFactory.notStarred)
    vm.inputs.refTag(nil)
    vm.inputs.viewWillAppear()
    self.scheduler.advance()

    self.projectIsStarred.assertValues([false, false],
                                       "Emits project immediately, and then again with update from the API.")
    XCTAssertEqual(["Project Page"], trackingClient.events, "A project page koala event is tracked.")

    vm.inputs.starButtonTapped()

    self.projectIsStarred.assertValues([false, false, true],
                                       "Once logged in, the project stars immediately.")
    showProjectStarredPrompt.assertValueCount(1, "The star prompt shows.")
    XCTAssertEqual(["Project Page", "Project Star"], trackingClient.events, "A star koala event is tracked.")
  }

  // Tests a logged in user starring a project that ends soon.
  func testLoggedInUser_StarsEndingSoonProject() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))

    vm.inputs.project(ProjectFactory.endingSoon)
    vm.inputs.refTag(nil)
    vm.inputs.viewWillAppear()
    vm.inputs.starButtonTapped()

    XCTAssertEqual(["Project Page", "Project Star"], trackingClient.events, "A star koala event is tracked.")
  }

  // Tests a user unstarring a project.
  func testLoggedInUser_UnstarsProject() {
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user()))

    vm.inputs.project(ProjectFactory.starred)
    vm.inputs.refTag(nil)
    vm.inputs.viewWillAppear()
    vm.inputs.starButtonTapped()

    showProjectStarredPrompt.assertValueCount(0, "The star prompt does not show.")
    XCTAssertEqual(["Project Page", "Project Unstar"], trackingClient.events,
                   "An unstar koala event is tracked.")
  }
}
