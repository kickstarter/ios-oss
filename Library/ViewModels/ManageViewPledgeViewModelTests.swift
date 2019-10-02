import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ManageViewPledgeViewModelTests: TestCase {
  private let vm = ManageViewPledgeViewModel()

  private let configurePaymentMethodView = TestObserver<Project, Never>()
  private let configurePledgeSummaryView = TestObserver<Project, Never>()
  private let configureRewardSummaryViewProject = TestObserver<Project, Never>()
  private let configureRewardSummaryViewReward = TestObserver<Reward, Never>()
  private let showActionSheetMenuWithOptions = TestObserver<[ManagePledgeAlertAction], Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.configurePaymentMethodView
      .observe(self.configurePaymentMethodView.observer)
    self.vm.outputs.configurePledgeSummaryView
      .observe(self.configurePledgeSummaryView.observer)
    self.vm.outputs.configureRewardSummaryView.map(first)
      .observe(self.configureRewardSummaryViewProject.observer)
    self.vm.outputs.configureRewardSummaryView
      .map { $0.1.left }
      .skipNil()
      .observe(self.configureRewardSummaryViewReward.observer)
    self.vm.outputs.showActionSheetMenuWithOptions.observe(self.showActionSheetMenuWithOptions.observer)
  }

  func testNavigationBarTitle_LiveProject() {
    self.title.assertDidNotEmitValue()

    let project = Project.template
    self.vm.inputs.configureWith(project, reward: .template)

    self.vm.inputs.viewDidLoad()

    self.title.assertValue("Manage your pledge")
  }

  func testNavigationBarTitle_FinishedProject() {
    self.title.assertDidNotEmitValue()

    let finishedProject = Project.template
      |> \.state .~ .successful
    self.vm.inputs.configureWith(finishedProject, reward: .template)

    self.vm.inputs.viewDidLoad()

    self.title.assertValue("Your pledge")
  }

  func testConfigurePaymentMethodViewController() {
    self.configurePaymentMethodView.assertDidNotEmitValue()

    let project = Project.template
    self.vm.inputs.configureWith(project, reward: .template)

    self.vm.inputs.viewDidLoad()

    self.configurePaymentMethodView.assertValue(project)
  }

  func testConfigurePledgeSummaryViewController() {
    self.configurePledgeSummaryView.assertDidNotEmitValue()

    let project = Project.template
    self.vm.inputs.configureWith(project, reward: .template)

    self.vm.inputs.viewDidLoad()

    self.configurePledgeSummaryView.assertValue(project)
  }

  func testConfigureRewardSummaryViewController() {
    self.configureRewardSummaryViewProject.assertDidNotEmitValue()
    self.configureRewardSummaryViewReward.assertDidNotEmitValue()

    let reward = Reward.template
    let project = Project.template
    self.vm.inputs.configureWith(project, reward: reward)

    self.vm.inputs.viewDidLoad()

    self.configureRewardSummaryViewProject.assertValue(project)
    self.configureRewardSummaryViewReward.assertValue(reward)
  }

  func testMenuButtonTapped_WhenProject_IsLive() {
    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()

    self.showActionSheetMenuWithOptions.assertValues([ManagePledgeAlertAction.allCases])
  }

  func testMenuButtonTapped_WhenProject_IsNotLive() {
    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()

    self.showActionSheetMenuWithOptions.assertValues([[.contactCreator]])
  }
}
