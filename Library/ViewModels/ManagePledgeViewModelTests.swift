import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ManagePledgeViewModelTests: TestCase {
  private let vm = ManagePledgeViewModel()

  private let configurePaymentMethodView = TestObserver<GraphUserCreditCard.CreditCard, Never>()
  private let configurePledgeSummaryView = TestObserver<Project, Never>()
  private let configureRewardSummaryView = TestObserver<Reward, Never>()
  private let goToCancelPledge = TestObserver<Void, Never>()
  private let goToChangePaymentMethod = TestObserver<Void, Never>()
  private let goToContactCreator = TestObserver<Void, Never>()
  private let goToRewards = TestObserver<Project, Never>()
  private let goToUpdatePledge = TestObserver<Project, Never>()
  private let showActionSheetMenuWithOptions = TestObserver<[ManagePledgeAlertAction], Never>()
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
    self.vm.outputs.goToCancelPledge.observe(self.goToCancelPledge.observer)
    self.vm.outputs.goToChangePaymentMethod.observe(self.goToChangePaymentMethod.observer)
    self.vm.outputs.goToContactCreator.observe(self.goToContactCreator.observer)
    self.vm.outputs.goToRewards.observe(self.goToRewards.observer)
    self.vm.outputs.goToUpdatePledge.observe(self.goToUpdatePledge.observer)
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

    let backing = Backing.template

    let project = Project.template
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project, reward: .template)

    self.vm.inputs.viewDidLoad()

    self.configurePaymentMethodView.assertValue(GraphUserCreditCard.visa)
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

  func testGoToCancelPledge() {
    self.vm.inputs.configureWith(Project.template, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.goToCancelPledge.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .cancelPledge)

    self.goToCancelPledge.assertValueCount(1)
  }

  func testGoToChangePaymentMethod() {
    self.vm.inputs.configureWith(Project.template, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.goToChangePaymentMethod.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .changePaymentMethod)

    self.goToChangePaymentMethod.assertValueCount(1)
  }

  func testGoToContactCreator() {
    self.vm.inputs.configureWith(Project.template, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.goToContactCreator.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .contactCreator)

    self.goToContactCreator.assertValueCount(1)
  }

  func testGoToRewards() {
    self.vm.inputs.configureWith(Project.template, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.goToRewards.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .chooseAnotherReward)

    self.goToRewards.assertValues([Project.template])
  }

  func testGoToUpdatePledge() {
    self.vm.inputs.configureWith(Project.template, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.goToUpdatePledge.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .updatePledge)

    self.goToUpdatePledge.assertValues([Project.template])
  }
}
