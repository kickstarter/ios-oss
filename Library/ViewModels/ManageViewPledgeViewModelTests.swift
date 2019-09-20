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
  private let configureRewardSummaryView = TestObserver<Reward, Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.configurePaymentMethodView
      .observe(self.configurePaymentMethodView.observer)
    self.vm.outputs.configurePledgeSummaryView
      .observe(self.configurePledgeSummaryView.observer)
    self.vm.outputs.configureRewardSummaryView
      .observe(self.configureRewardSummaryView.observer)
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

    self.title.assertValue("View your pledge")
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
    self.configureRewardSummaryView.assertDidNotEmitValue()

    let reward = Reward.template
    self.vm.inputs.configureWith(.template, reward: reward)

    self.vm.inputs.viewDidLoad()

    self.configureRewardSummaryView.assertValue(reward)
  }
}
