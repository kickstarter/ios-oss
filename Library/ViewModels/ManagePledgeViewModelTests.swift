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
  private let configureRewardSummaryViewProject = TestObserver<Project, Never>()
  private let configureRewardSummaryViewReward = TestObserver<Reward, Never>()
  private let goToCancelPledgeProject = TestObserver<Project, Never>()
  private let goToCancelPledgeBacking = TestObserver<Backing, Never>()
  private let goToChangePaymentMethod = TestObserver<Void, Never>()
  private let goToContactCreator = TestObserver<Void, Never>()
  private let goToRewards = TestObserver<Project, Never>()
  private let goToUpdatePledgeProject = TestObserver<Project, Never>()
  private let goToUpdatePledgeReward = TestObserver<Reward, Never>()
  private let notifyDelegateShouldDismissAndShowSuccessBannerWithMessage
    = TestObserver<String, Never>()
  private let rewardReceivedViewControllerViewIsHidden = TestObserver<Bool, Never>()
  private let showActionSheetMenuWithOptions = TestObserver<[ManagePledgeAlertAction], Never>()
  private let showSuccessBannerWithMessage = TestObserver<String, Never>()
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
    self.vm.outputs.configureRewardSummaryView.map(second).map { Either.left($0) }.skipNil()
      .observe(self.configureRewardSummaryViewReward.observer)

    self.vm.outputs.goToCancelPledge.map(first).observe(self.goToCancelPledgeProject.observer)
    self.vm.outputs.goToCancelPledge.map(second).observe(self.goToCancelPledgeBacking.observer)
    self.vm.outputs.goToChangePaymentMethod.observe(self.goToChangePaymentMethod.observer)
    self.vm.outputs.goToContactCreator.observe(self.goToContactCreator.observer)
    self.vm.outputs.goToRewards.observe(self.goToRewards.observer)
    self.vm.outputs.goToUpdatePledge.map(first).observe(self.goToUpdatePledgeProject.observer)
    self.vm.outputs.goToUpdatePledge.map(second).observe(self.goToUpdatePledgeReward.observer)
    self.vm.outputs.notifyDelegateShouldDismissAndShowSuccessBannerWithMessage
      .observe(self.notifyDelegateShouldDismissAndShowSuccessBannerWithMessage.observer)
    self.vm.outputs.rewardReceivedViewControllerViewIsHidden.observe(
      self.rewardReceivedViewControllerViewIsHidden.observer
    )
    self.vm.outputs.showActionSheetMenuWithOptions.observe(self.showActionSheetMenuWithOptions.observer)
    self.vm.outputs.showSuccessBannerWithMessage.observe(self.showSuccessBannerWithMessage.observer)
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

  func testGoToCancelPledge() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.goToCancelPledgeProject.assertDidNotEmitValue()
    self.goToCancelPledgeBacking.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .cancelPledge)

    self.goToCancelPledgeProject.assertValues([project])
    self.goToCancelPledgeBacking.assertValues([Backing.template])
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

    self.goToUpdatePledgeProject.assertDidNotEmitValue()
    self.goToUpdatePledgeReward.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .updatePledge)

    self.goToUpdatePledgeProject.assertValues([Project.template])
    self.goToUpdatePledgeReward.assertValues([Reward.template])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Canceled() {
    let backing = Backing.template
      |> Backing.lens.status .~ .canceled

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: Reward.noReward)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Collected() {
    let backing = Backing.template
      |> Backing.lens.status .~ .collected

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: Reward.noReward)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Dropped() {
    let backing = Backing.template
      |> Backing.lens.status .~ .dropped

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: Reward.noReward)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Errored() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: Reward.noReward)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Pledged() {
    let backing = Backing.template
      |> Backing.lens.status .~ .pledged

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: Reward.noReward)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Preauth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: Reward.noReward)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Canceled() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Collected() {
    let backing = Backing.template
      |> Backing.lens.status .~ .collected

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([false])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Dropped() {
    let backing = Backing.template
      |> Backing.lens.status .~ .dropped

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Errored() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Pledged() {
    let backing = Backing.template
      |> Backing.lens.status .~ .pledged

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Preauth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testCancelPledgeDidFinish() {
    self.vm.inputs.configureWith(Project.template, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateShouldDismissAndShowSuccessBannerWithMessage.assertDidNotEmitValue()

    self.vm.inputs.cancelPledgeDidFinish(with: "You cancelled your pledge.")

    self.notifyDelegateShouldDismissAndShowSuccessBannerWithMessage
      .assertValues(["You cancelled your pledge."])
  }

  func testPledgeViewControllerDidUpdatePledge() {
    self.showSuccessBannerWithMessage.assertDidNotEmitValue()

    self.vm.inputs.configureWith(.template, reward: .template)
    self.vm.inputs.viewDidLoad()

    self.showSuccessBannerWithMessage.assertDidNotEmitValue()

    self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Got it! Your changes have been saved.")

    self.showSuccessBannerWithMessage.assertValues(["Got it! Your changes have been saved."])
  }
}
