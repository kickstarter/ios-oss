import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class ProjectPamphletViewModelTests: TestCase {
  private let vm: ProjectPamphletViewModelType = ProjectPamphletViewModel()

  private let configureChildViewControllersWithProject = TestObserver<Project, NoError>()
  private let setNavigationBarHidden = TestObserver<Bool, NoError>()
  private let setNavigationBarAnimated = TestObserver<Bool, NoError>()
  private let setNeedsStatusBarAppearanceUpdate = TestObserver<(), NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.configureChildViewControllersWithProject
      .observe(self.configureChildViewControllersWithProject.observer)
    self.vm.outputs.setNavigationBarHiddenAnimated.map(first)
      .observe(self.setNavigationBarHidden.observer)
    self.vm.outputs.setNavigationBarHiddenAnimated.map(second)
      .observe(self.setNavigationBarAnimated.observer)
    self.vm.outputs.setNeedsStatusBarAppearanceUpdate.observe(self.setNeedsStatusBarAppearanceUpdate.observer)
  }

  func testConfigureChildViewControllersWithProject_ConfiguredWithProject() {
    let project = Project.template
    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)

    self.configureChildViewControllersWithProject.assertValues([project])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project])
  }

  func testConfigureChildViewControllersWithProject_ConfiguredWithParam() {
    let project = .template |> Project.lens.id .~ 42

    self.vm.inputs.configureWith(projectOrParam: .right(.id(project.id)), refTag: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)

    self.configureChildViewControllersWithProject.assertValues([])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project])
  }

  func testStatusBar() {
    self.vm.inputs.configureWith(projectOrParam: .left(.template), refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(0)
    XCTAssertFalse(self.vm.outputs.prefersStatusBarHidden)

    self.vm.inputs.viewWillAppear(animated: true)

    self.setNeedsStatusBarAppearanceUpdate.assertValueCount(1)
    XCTAssertTrue(self.vm.outputs.prefersStatusBarHidden)
  }

  func testNavigationBar() {
    self.vm.inputs.configureWith(projectOrParam: .left(.template), refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.setNavigationBarHidden.assertValues([true])
    self.setNavigationBarAnimated.assertValues([false])

    self.vm.inputs.viewWillAppear(animated: true)

    self.setNavigationBarHidden.assertValues([true])
    self.setNavigationBarAnimated.assertValues([false])

    self.vm.inputs.viewWillAppear(animated: true)

    self.setNavigationBarHidden.assertValues([true, true])
    self.setNavigationBarAnimated.assertValues([false, true])

    self.vm.inputs.viewWillAppear(animated: false)

    self.setNavigationBarHidden.assertValues([true, true, true])
    self.setNavigationBarAnimated.assertValues([false, true, false])
  }

  // Tests that ref tags and referral credit cookies are tracked in koala and saved like we expect.
  func testTracksRefTag() {
    let project = Project.template

    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .category)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)

    XCTAssertEqual(["Project Page"], self.trackingClient.events, "A project page koala event is tracked.")
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
    let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
    newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
    newVm.inputs.viewDidLoad()
    newVm.inputs.viewWillAppear(animated: true)

    XCTAssertEqual(["Project Page", "Project Page"],
                   self.trackingClient.events, "A project page koala event is tracked.")
    XCTAssertEqual([RefTag.category.stringTag, RefTag.recommended.stringTag],
                   self.trackingClient.properties.flatMap { $0["ref_tag"] as? String },
                   "The new ref tag is tracked in koala event.")
    XCTAssertEqual([RefTag.category.stringTag, RefTag.category.stringTag],
                   self.trackingClient.properties.flatMap { $0["referrer_credit"] as? String },
                   "The referrer credit did not change, and is still category.")
    XCTAssertEqual(1, self.cookieStorage.cookies?.count,
                   "A single cookie has been set.")
  }
}
