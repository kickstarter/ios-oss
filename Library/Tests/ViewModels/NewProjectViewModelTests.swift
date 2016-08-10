import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectMagazineViewModelTests: TestCase {
  private let vm: ProjectMagazineViewModelType = ProjectMagazineViewModel()

  private let backProjectButtonHidden = TestObserver<Bool, NoError>()
  private let bottomShareButtonHidden = TestObserver<Bool, NoError>()
  private let configureChildViewControllersWithProject = TestObserver<Project, NoError>()
  private let descriptionViewHidden = TestObserver<Bool, NoError>()
  private let goToLoginTout = TestObserver<(), NoError>()
  private let managePledgeButtonHidden = TestObserver<Bool, NoError>()
  private let notifyDescriptionToExpand = TestObserver<(), NoError>()
  private let rewardsViewHidden = TestObserver<Bool, NoError>()
  private let showProjectStarredPrompt = TestObserver<String, NoError>()
  private let starButtonAccessibilityHint = TestObserver<String, NoError>()
  private let starButtonSelected = TestObserver<Bool, NoError>()
  private let transferFooterAndHeaderToDescriptionController = TestObserver<(), NoError>()
  private let transferFooterAndHeaderToRewardsController = TestObserver<(), NoError>()
  private let viewPledgeButtonHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.backProjectButtonHidden.observe(self.backProjectButtonHidden.observer)
    self.vm.outputs.bottomShareButtonHidden.observe(self.bottomShareButtonHidden.observer)
    self.vm.outputs.configureChildViewControllersWithProject
      .observe(self.configureChildViewControllersWithProject.observer)
    self.vm.outputs.descriptionViewHidden.observe(self.descriptionViewHidden.observer)
    self.vm.outputs.goToLoginTout.observe(self.goToLoginTout.observer)
    self.vm.outputs.managePledgeButtonHidden.observe(self.managePledgeButtonHidden.observer)
    self.vm.outputs.notifyDescriptionToExpand.observe(self.notifyDescriptionToExpand.observer)
    self.vm.outputs.rewardsViewHidden.observe(self.rewardsViewHidden.observer)
    self.vm.outputs.showProjectStarredPrompt.observe(self.showProjectStarredPrompt.observer)
    self.vm.outputs.starButtonSelected.observe(self.starButtonSelected.observer)
    self.vm.outputs.starButtonAccessibilityHint.observe(self.starButtonAccessibilityHint.observer)
    self.vm.outputs.transferFooterAndHeaderToDescriptionController
      .observe(self.transferFooterAndHeaderToDescriptionController.observer)
    self.vm.outputs.transferFooterAndHeaderToRewardsController
      .observe(self.transferFooterAndHeaderToRewardsController.observer)
    self.vm.outputs.viewPledgeButtonHidden.observe(self.viewPledgeButtonHidden.observer)
  }

  func testBackProjectButtonHidden_LiveProject_NotBacking() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ false,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.backProjectButtonHidden.assertValues([false])
  }

  func testBackProjectButtonHidden_LiveProject_Backing() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.backProjectButtonHidden.assertValues([true])
  }

  func testBackProjectButtonHidden_NotLiveProject_NotBacking() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ false,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.backProjectButtonHidden.assertValues([true])
  }

  func testBackProjectButtonHidden_NotLiveProject_Backing() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ true,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.backProjectButtonHidden.assertValues([true])
  }

  func testBottomShareButtonHidden_LiveProject_NotBacking() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ false,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.bottomShareButtonHidden.assertValues([true])
  }

  func testBottomShareButtonHidden_LiveProject_Backing() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.bottomShareButtonHidden.assertValues([true])
  }

  func testBottomShareButtonHidden_NotLiveProject_NotBacking() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ false,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.bottomShareButtonHidden.assertValues([false])
  }

  func testBottomShareButtonHidden_NotLiveProject_Backing() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ true,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.bottomShareButtonHidden.assertValues([true])
  }

  func testConfigureChildViewControllers() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    self.configureChildViewControllersWithProject.assertValues([project])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project])
  }

  func testDescriptionAndRewardsViewHidden() {
    self.vm.inputs.configureWith(project: .template, refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    self.descriptionViewHidden.assertValues([false])
    self.rewardsViewHidden.assertValues([true])

    self.vm.inputs.showRewardsTab()

    self.descriptionViewHidden.assertValues([false, true])
    self.rewardsViewHidden.assertValues([true, false])

    self.vm.inputs.showCampaignTab()

    self.descriptionViewHidden.assertValues([false, true, false])
    self.rewardsViewHidden.assertValues([true, false, true])

    self.vm.inputs.showCampaignTab()

    self.descriptionViewHidden.assertValues([false, true, false])
    self.rewardsViewHidden.assertValues([true, false, true])
  }

  func testNotifyDescriptionToExpand() {
    self.vm.inputs.configureWith(project: .template, refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    self.notifyDescriptionToExpand.assertValueCount(0)

    self.vm.inputs.expandDescription()

    self.notifyDescriptionToExpand.assertValueCount(1)
  }

  func testTransferFooterAndHeaderToDescriptionController() {
    self.vm.inputs.configureWith(project: .template, refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    self.transferFooterAndHeaderToDescriptionController.assertValueCount(1)

    self.vm.inputs.showRewardsTab()

    self.transferFooterAndHeaderToDescriptionController.assertValueCount(1)

    self.vm.inputs.showCampaignTab()

    self.transferFooterAndHeaderToDescriptionController.assertValueCount(2)

    self.vm.inputs.showCampaignTab()

    self.transferFooterAndHeaderToDescriptionController.assertValueCount(2)
  }

  func testTransferFooterAndHeaderToRewardsController() {
    self.vm.inputs.configureWith(project: .template, refTag: .discovery)
    self.vm.inputs.viewDidLoad()

    self.transferFooterAndHeaderToRewardsController.assertValueCount(0)

    self.vm.inputs.showRewardsTab()

    self.transferFooterAndHeaderToRewardsController.assertValueCount(1)

    self.vm.inputs.showRewardsTab()

    self.transferFooterAndHeaderToRewardsController.assertValueCount(1)

    self.vm.inputs.showCampaignTab()

    self.transferFooterAndHeaderToRewardsController.assertValueCount(1)
  }

  func testManagePledgeButtonHidden_LiveProject_NotBacking() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ false,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.managePledgeButtonHidden.assertValues([true])
  }

  func testManagePledgeButtonHidden_LiveProject_Backing() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.managePledgeButtonHidden.assertValues([false])
  }

  func testManagePledgeButtonHidden_NotLiveProject_NotBacking() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ false,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.managePledgeButtonHidden.assertValues([true])
  }

  func testManagePledgeButtonHidden_NotLiveProject_Backing() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ true,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.managePledgeButtonHidden.assertValues([true])
  }

  func testViewPledgeButtonHidden_LiveProject_NotBacking() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ false,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.viewPledgeButtonHidden.assertValues([true])
  }

  func testViewPledgeButtonHidden_LiveProject_Backing() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.viewPledgeButtonHidden.assertValues([true])
  }

  func testViewPledgeButtonHidden_NotLiveProject_NotBacking() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ false,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.viewPledgeButtonHidden.assertValues([true])
  }

  func testViewPledgeButtonHidden_NotLiveProject_Backing() {
    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ true,
      refTag: .discovery
    )
    self.vm.inputs.viewDidLoad()

    self.viewPledgeButtonHidden.assertValues([false])
  }

  // Tests that ref tags and referral credit cookies are tracked in koala and saved like we expect.
  func testTracksRefTag() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, refTag: .category)
    self.vm.inputs.viewDidLoad()

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
    XCTAssertEqual("category?",
                   (self.cookieStorage.cookies?.last?.value.characters.prefix(9)).map(String.init),
                   "A referral cookie is set for the category ref tag.")

    // Start up another view model with the same project
    let newVm: ProjectMagazineViewModelType = ProjectMagazineViewModel()
    newVm.inputs.configureWith(project: project, refTag: .recommended)
    newVm.inputs.viewDidLoad()

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
    self.starButtonSelected.assertDidNotEmitValue("No projects emitted at first.")

    self.vm.inputs.configureWith(
      project: .template |> Project.lens.personalization.isStarred .~ false,
      refTag: nil
    )
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.starButtonSelected.assertValues(
      [false], "Emits project immediately, and then again with update from the API."
    )
    XCTAssertEqual(["Project Page"], trackingClient.events, "A project page koala event is tracked.")

    self.vm.inputs.starButtonTapped()

    self.starButtonSelected.assertValues([false],
                                         "Nothing is emitted when starring while logged out.")
    self.goToLoginTout.assertValueCount(1, "Prompt to login when starring while logged out.")

    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.template))
    self.vm.inputs.userSessionStarted()

    self.starButtonSelected.assertValues([false, true],
                                         "Once logged in, the project stars immediately.")
    self.showProjectStarredPrompt.assertValueCount(1, "The star prompt shows.")
    XCTAssertEqual(["Project Page", "Project Star"], trackingClient.events, "A star koala event is tracked.")
  }

  // Tests a logged in user starring a project.
  func testLoggedInUser_StarsProject() {
    let project = Project.template

    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.template))

    self.starButtonSelected.assertDidNotEmitValue("No projects emitted at first.")

    self.vm.inputs.configureWith(project: project, refTag: nil)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.starButtonSelected.assertValues(
      [false], "Emits project immediately, and then again with update from the API."
    )
    XCTAssertEqual(["Project Page"], trackingClient.events, "A project page koala event is tracked.")

    self.vm.inputs.starButtonTapped()

    self.starButtonSelected.assertValues([false, true],
                                         "Once logged in, the project stars immediately.")
    self.showProjectStarredPrompt.assertValueCount(1, "The star prompt shows.")
    XCTAssertEqual(["Project Page", "Project Star"], trackingClient.events, "A star koala event is tracked.")
  }

  // Tests a logged in user starring a project that ends soon.
  func testLoggedInUser_StarsEndingSoonProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.template))

    self.vm.inputs.configureWith(
      project: .template
        |> Project.lens.dates.deadline .~ (NSDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0),
      refTag: nil
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.starButtonTapped()

    self.showProjectStarredPrompt.assertValueCount(
      0, "The star prompt doesn't show cause it's less than 48hrs."
    )

    XCTAssertEqual(["Project Page", "Project Star"],
                   self.trackingClient.events,
                   "A star koala event is tracked.")
  }

  // Tests a user unstarring a project.
  func testLoggedInUser_UnstarsProject() {
    AppEnvironment.login(.init(accessToken: "deadbeef", user: User.template))

    self.vm.inputs.configureWith(
      project: .template |> Project.lens.personalization.isStarred .~ true,
      refTag: nil
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.starButtonTapped()

    self.showProjectStarredPrompt.assertValueCount(0, "The star prompt does not show.")
    XCTAssertEqual(["Project Page", "Project Unstar"], trackingClient.events,
                   "An unstar koala event is tracked.")
  }
}
