@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectPamphletViewModelTests: TestCase {
  fileprivate var vm: ProjectPamphletViewModelType!

  private let configureChildViewControllersWithProject = TestObserver<Project, Never>()
  private let configureChildViewControllersWithRefTag = TestObserver<RefTag?, Never>()
  private let configurePledgeCTAViewProject = TestObserver<Project, Never>()
  private let configurePledgeCTAViewIsLoading = TestObserver<Bool, Never>()
  private let goToDeprecatedRewardsProject = TestObserver<Project, Never>()
  private let goToDeprecatedRewardsRefTag = TestObserver<RefTag?, Never>()
  private let goToRewardsProject = TestObserver<Project, Never>()
  private let goToRewardsRefTag = TestObserver<RefTag?, Never>()
  private let setNavigationBarHidden = TestObserver<Bool, Never>()
  private let setNavigationBarAnimated = TestObserver<Bool, Never>()
  private let setNeedsStatusBarAppearanceUpdate = TestObserver<(), Never>()
  private let topLayoutConstraintConstant = TestObserver<CGFloat, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm = ProjectPamphletViewModel()
    self.vm.outputs.configureChildViewControllersWithProject.map(first)
      .observe(self.configureChildViewControllersWithProject.observer)
    self.vm.outputs.configureChildViewControllersWithProject.map(second)
      .observe(self.configureChildViewControllersWithRefTag.observer)
    self.vm.outputs.configurePledgeCTAView.map(first).observe(self.configurePledgeCTAViewProject.observer)
    self.vm.outputs.configurePledgeCTAView.map(second).observe(self.configurePledgeCTAViewIsLoading.observer)
    self.vm.outputs.goToDeprecatedRewards.map(first).observe(self.goToDeprecatedRewardsProject.observer)
    self.vm.outputs.goToDeprecatedRewards.map(second).observe(self.goToDeprecatedRewardsRefTag.observer)
    self.vm.outputs.goToRewards.map(first).observe(self.goToRewardsProject.observer)
    self.vm.outputs.goToRewards.map(second).observe(self.goToRewardsRefTag.observer)
    self.vm.outputs.setNavigationBarHiddenAnimated.map(first)
      .observe(self.setNavigationBarHidden.observer)
    self.vm.outputs.setNavigationBarHiddenAnimated.map(second)
      .observe(self.setNavigationBarAnimated.observer)
    self.vm.outputs.setNeedsStatusBarAppearanceUpdate.observe(self.setNeedsStatusBarAppearanceUpdate.observer)
    self.vm.outputs.topLayoutConstraintConstant.observe(self.topLayoutConstraintConstant.observer)
  }

  func testConfigureChildViewControllersWithProject_ConfiguredWithProject() {
    let project = Project.template
    let refTag = RefTag.category
    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: refTag)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.configureChildViewControllersWithProject.assertValues([project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag, refTag])

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project, project])
    self.configureChildViewControllersWithRefTag.assertValues([refTag, refTag, refTag])
  }

  func testConfigureChildViewControllersWithProject_ConfiguredWithParam() {
    let project = .template |> Project.lens.id .~ 42

    self.vm.inputs.configureWith(projectOrParam: .right(.id(project.id)), refTag: nil)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.configureChildViewControllersWithProject.assertValues([])
    self.configureChildViewControllersWithRefTag.assertValues([])

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project])
    self.configureChildViewControllersWithRefTag.assertValues([nil])

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    self.configureChildViewControllersWithProject.assertValues([project, project])
    self.configureChildViewControllersWithRefTag.assertValues([nil, nil])
  }

  func testNavigationBar() {
    self.vm.inputs.configureWith(projectOrParam: .left(.template), refTag: nil)
    self.vm.inputs.viewDidLoad()

    self.setNavigationBarHidden.assertValues([true])
    self.setNavigationBarAnimated.assertValues([false])

    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.setNavigationBarHidden.assertValues([true])
    self.setNavigationBarAnimated.assertValues([false])

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.setNavigationBarHidden.assertValues([true, true])
    self.setNavigationBarAnimated.assertValues([false, true])

    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: true)

    self.setNavigationBarHidden.assertValues([true, true, true])
    self.setNavigationBarAnimated.assertValues([false, true, false])
  }

  // Tests that ref tags and referral credit cookies are tracked in koala and saved like we expect.
  func testTracksRefTag() {
    let project = Project.template

    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .category)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Project Page", "Viewed Project Page"],
      self.trackingClient.events, "A project page koala event is tracked."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag, RefTag.category.stringTag],
      self.trackingClient.properties.compactMap { $0["ref_tag"] as? String },
      "The ref tag is tracked in the koala event."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag, RefTag.category.stringTag],
      self.trackingClient.properties.compactMap { $0["referrer_credit"] as? String },
      "The referral credit is tracked in the koala event."
    )
    XCTAssertEqual(
      1, self.cookieStorage.cookies?.count,
      "A single cookie is set"
    )
    XCTAssertEqual(
      "ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
      "A referral cookie is set for the project."
    )
    XCTAssertEqual(
      "category?",
      (self.cookieStorage.cookies?.last?.value.prefix(9)).map(String.init),
      "A referral cookie is set for the category ref tag."
    )

    // Start up another view model with the same project
    let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
    newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
    newVm.inputs.viewDidLoad()
    newVm.inputs.viewWillAppear(animated: true)
    newVm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Project Page", "Viewed Project Page", "Project Page", "Viewed Project Page"],
      self.trackingClient.events, "A project page koala event is tracked."
    )
    XCTAssertEqual(
      [
        RefTag.category.stringTag, RefTag.category.stringTag, RefTag.recommended.stringTag,
        RefTag.recommended.stringTag
      ],
      self.trackingClient.properties.compactMap { $0["ref_tag"] as? String },
      "The new ref tag is tracked in koala event."
    )
    XCTAssertEqual(
      [
        RefTag.category.stringTag, RefTag.category.stringTag, RefTag.category.stringTag,
        RefTag.category.stringTag
      ],
      self.trackingClient.properties.compactMap { $0["referrer_credit"] as? String },
      "The referrer credit did not change, and is still category."
    )
    XCTAssertEqual(
      1, self.cookieStorage.cookies?.count,
      "A single cookie has been set."
    )
  }

  func testMockCookieStorageSet_SeparateSchedulers() {
    let project = Project.template
    let scheduler1 = TestScheduler(startDate: MockDate().date)
    let scheduler2 = TestScheduler(startDate: scheduler1.currentDate.addingTimeInterval(1))

    withEnvironment(scheduler: scheduler1) {
      let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .category)
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewWillAppear(animated: true)
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(1, self.cookieStorage.cookies?.count, "A single cookie has been set.")
    }

    withEnvironment(scheduler: scheduler2) {
      let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewWillAppear(animated: true)
      newVm.inputs.viewDidAppear(animated: true)

      scheduler2.advance()

      XCTAssertEqual(2, self.cookieStorage.cookies?.count, "Two cookies are set on separate schedulers.")
    }
  }

  func testMockCookieStorageSet_SameScheduler() {
    let project = Project.template
    let scheduler1 = TestScheduler(startDate: MockDate().date)

    withEnvironment(scheduler: scheduler1) {
      let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .category)
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewWillAppear(animated: true)
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(1, self.cookieStorage.cookies?.count, "A single cookie has been set.")
    }

    withEnvironment(scheduler: scheduler1) {
      let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
      newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
      newVm.inputs.viewDidLoad()
      newVm.inputs.viewWillAppear(animated: true)
      newVm.inputs.viewDidAppear(animated: true)

      scheduler1.advance()

      XCTAssertEqual(
        1, self.cookieStorage.cookies?.count,
        "A single cookie has been set on the same scheduler."
      )
    }
  }

  func testTopLayoutConstraints_AfterRotation() {
    self.vm.inputs.initial(topConstraint: 30.0)
    XCTAssertNil(self.topLayoutConstraintConstant.lastValue)

    self.vm.inputs.willTransition(toNewCollection: UITraitCollection(horizontalSizeClass: .compact))
    XCTAssertEqual(30.0, self.topLayoutConstraintConstant.lastValue)
  }

  func testTracksRefTag_WithBadData() {
    let project = Project.template

    self.vm.inputs.configureWith(
      projectOrParam: .left(project), refTag: RefTag.unrecognized("category%3F1232")
    )
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Project Page", "Viewed Project Page"],
      self.trackingClient.events, "A project page koala event is tracked."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag, RefTag.category.stringTag],
      self.trackingClient.properties.compactMap { $0["ref_tag"] as? String },
      "The ref tag is tracked in the koala event."
    )
    XCTAssertEqual(
      [RefTag.category.stringTag, RefTag.category.stringTag],
      self.trackingClient.properties.compactMap { $0["referrer_credit"] as? String },
      "The referral credit is tracked in the koala event."
    )
    XCTAssertEqual(
      1, self.cookieStorage.cookies?.count,
      "A single cookie is set"
    )
    XCTAssertEqual(
      "ref_\(project.id)", self.cookieStorage.cookies?.last?.name,
      "A referral cookie is set for the project."
    )
    XCTAssertEqual(
      "category?",
      (self.cookieStorage.cookies?.last?.value.prefix(9)).map(String.init),
      "A referral cookie is set for the category ref tag."
    )

    // Start up another view model with the same project
    let newVm: ProjectPamphletViewModelType = ProjectPamphletViewModel()
    newVm.inputs.configureWith(projectOrParam: .left(project), refTag: .recommended)
    newVm.inputs.viewDidLoad()
    newVm.inputs.viewWillAppear(animated: true)
    newVm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Project Page", "Viewed Project Page", "Project Page", "Viewed Project Page"],
      self.trackingClient.events, "A project page koala event is tracked."
    )
    XCTAssertEqual(
      [
        RefTag.category.stringTag, RefTag.category.stringTag, RefTag.recommended.stringTag,
        RefTag.recommended.stringTag
      ],
      self.trackingClient.properties.compactMap { $0["ref_tag"] as? String },
      "The new ref tag is tracked in koala event."
    )
    XCTAssertEqual(
      [
        RefTag.category.stringTag, RefTag.category.stringTag, RefTag.category.stringTag,
        RefTag.category.stringTag
      ],
      self.trackingClient.properties.compactMap { $0["referrer_credit"] as? String },
      "The referrer credit did not change, and is still category."
    )
    XCTAssertEqual(
      1, self.cookieStorage.cookies?.count,
      "A single cookie has been set."
    )
  }

  func testTrackingDoesNotOccurOnLoad() {
    let project = Project.template

    self.vm.inputs.configureWith(
      projectOrParam: .left(project), refTag: RefTag.unrecognized("category%3F1232")
    )
    self.vm.inputs.viewDidLoad()

    self.scheduler.advance()

    XCTAssertEqual([], self.trackingClient.events)
  }

  func testGoToRewards() {
    let config = Config.template
      |> \.features .~ [Feature.nativeCheckoutPledgeView.rawValue: true]

    withEnvironment(config: config) {
      let project = Project.template

      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.goToDeprecatedRewardsProject.assertDidNotEmitValue()
      self.goToDeprecatedRewardsRefTag.assertDidNotEmitValue()
      self.goToRewardsProject.assertDidNotEmitValue()
      self.goToRewardsRefTag.assertDidNotEmitValue()

      self.vm.inputs.backThisProjectTapped()

      self.goToDeprecatedRewardsProject.assertDidNotEmitValue()
      self.goToDeprecatedRewardsRefTag.assertDidNotEmitValue()
      self.goToRewardsProject.assertValues([project], "Tapping 'Back this project' emits the project")
      self.goToRewardsRefTag.assertValues([.discovery], "Tapping 'Back this project' emits the refTag")
    }
  }

  func testGoToDeprecatedRewards() {
    let project = Project.template

    self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.goToDeprecatedRewardsProject.assertDidNotEmitValue()
    self.goToDeprecatedRewardsRefTag.assertDidNotEmitValue()
    self.goToRewardsProject.assertDidNotEmitValue()
    self.goToRewardsRefTag.assertDidNotEmitValue()

    self.vm.inputs.backThisProjectTapped()

    self.goToDeprecatedRewardsProject
      .assertValues([project], "Tapping 'Back this project' emits the project")
    self.goToDeprecatedRewardsRefTag
      .assertValues([.discovery], "Tapping 'Back this project' emits the refTag")
  }

  func testConfigurePledgeCTAView_fetchProjectSuccess_featureEnabled() {
    let config = Config.template |> \.features .~ [Feature.nativeCheckout.rawValue: true]
    let project = Project.template
    let projectFull = Project.template
      |> \.id .~ 2
      |> Project.lens.personalization.isBacking .~ true

    let mockService = MockService(fetchProjectResponse: projectFull)

    withEnvironment(apiService: mockService, apiDelayInterval: .seconds(1), config: config) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()

      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.configurePledgeCTAViewProject.assertValues([project])
      self.configurePledgeCTAViewIsLoading.assertValues([true])

      self.scheduler.run()

      self.configurePledgeCTAViewProject.assertValues([project, projectFull, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false])
    }
  }

  func testConfigurePledgeCTAView_fetchProjectFailure_featureEnabled() {
    let config = Config.template |> \.features .~ [Feature.nativeCheckout.rawValue: true]
    let project = Project.template
    let mockService = MockService(fetchProjectError: .couldNotParseJSON)

    withEnvironment(apiService: mockService, apiDelayInterval: .seconds(1), config: config) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()

      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.configurePledgeCTAViewProject.assertValues([project])
      self.configurePledgeCTAViewIsLoading.assertValues([true])

      self.scheduler.run()

      self.configurePledgeCTAViewProject.assertValues([project, project])
      self.configurePledgeCTAViewIsLoading.assertValues([true, false])
    }
  }

  func testConfigurePledgeCTAView_reloadsUponReturnToView_featureEnabled() {
    let config = Config.template |> \.features .~ [Feature.nativeCheckout.rawValue: true]
    let project = Project.template
    let projectFull = Project.template
      |> \.id .~ 2
      |> Project.lens.personalization.isBacking .~ true
    let projectFull2 = Project.template
      |> \.id .~ 3

    let mockService = MockService(fetchProjectResponse: projectFull)

    withEnvironment(apiService: mockService, config: config) {
      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()

      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeCTAViewProject.assertValues([project])
      self.configurePledgeCTAViewIsLoading.assertValues([true])

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertValues([project, projectFull, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false])
    }

    withEnvironment(
      apiService: MockService(fetchProjectResponse: projectFull2),
      config: config
    ) {
      self.vm.inputs.viewWillAppear(animated: true)
      self.vm.inputs.viewDidAppear(animated: true)

      self.configurePledgeCTAViewProject.assertValues([project, projectFull, projectFull, projectFull])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false, true])

      self.scheduler.advance()

      self.configurePledgeCTAViewProject.assertValues(
        [project, projectFull, projectFull, projectFull, projectFull2, projectFull2])
      self.configurePledgeCTAViewIsLoading.assertValues([true, true, false, true, true, false])
    }
  }

  func testConfigurePledgeCTAView_featureDisabled() {
    let config = Config.template |> \.features .~ [Feature.nativeCheckout.rawValue: false]
    let project = Project.template

    withEnvironment(config: config) {
      self.vm.inputs.configureWith(projectOrParam: .left(project), refTag: .discovery)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.configurePledgeCTAViewProject.assertDidNotEmitValue()
      self.configurePledgeCTAViewIsLoading.assertDidNotEmitValue()
    }
  }
}
