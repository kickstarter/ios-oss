import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ManagePledgeViewModelTests: TestCase {
  private let vm = ManagePledgeViewModel()

  private let configurePaymentMethodView = TestObserver<Backing.PaymentSource, Never>()
  private let configurePledgeSummaryView = TestObserver<Project, Never>()
  private let configureRewardReceivedWithProject = TestObserver<Project, Never>()
  private let configureRewardSummaryViewProject = TestObserver<Project, Never>()
  private let configureRewardSummaryViewReward = TestObserver<Reward, Never>()
  private let endRefreshing = TestObserver<Void, Never>()
  private let goToCancelPledgeProject = TestObserver<Project, Never>()
  private let goToCancelPledgeBacking = TestObserver<Backing, Never>()
  private let goToChangePaymentMethodProject = TestObserver<Project, Never>()
  private let goToChangePaymentMethodReward = TestObserver<Reward, Never>()
  private let goToContactCreatorSubject = TestObserver<MessageSubject, Never>()
  private let goToContactCreatorContext = TestObserver<Koala.MessageDialogContext, Never>()
  private let goToRewards = TestObserver<Project, Never>()
  private let goToUpdatePledgeProject = TestObserver<Project, Never>()
  private let goToUpdatePledgeReward = TestObserver<Reward, Never>()
  private let notifyDelegateManagePledgeViewControllerFinishedWithMessage
    = TestObserver<String?, Never>()
  private let rewardReceivedViewControllerViewIsHidden = TestObserver<Bool, Never>()
  private let showActionSheetMenuWithOptions = TestObserver<[ManagePledgeAlertAction], Never>()
  private let showErrorBannerWithMessage = TestObserver<String, Never>()
  private let showSuccessBannerWithMessage = TestObserver<String, Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.configurePaymentMethodView
      .observe(self.configurePaymentMethodView.observer)
    self.vm.outputs.configurePledgeSummaryView
      .observe(self.configurePledgeSummaryView.observer)
    self.vm.outputs.configureRewardReceivedWithProject
      .observe(self.configureRewardReceivedWithProject.observer)
    self.vm.outputs.configureRewardSummaryView.map(first)
      .observe(self.configureRewardSummaryViewProject.observer)
    self.vm.outputs.configureRewardSummaryView.map(second).map { Either.left($0) }.skipNil()
      .observe(self.configureRewardSummaryViewReward.observer)
    self.vm.outputs.endRefreshing.observe(self.endRefreshing.observer)
    self.vm.outputs.goToCancelPledge.map(first).observe(self.goToCancelPledgeProject.observer)
    self.vm.outputs.goToCancelPledge.map(second).observe(self.goToCancelPledgeBacking.observer)
    self.vm.outputs.goToChangePaymentMethod.map(first).observe(self.goToChangePaymentMethodProject.observer)
    self.vm.outputs.goToChangePaymentMethod.map(second).observe(self.goToChangePaymentMethodReward.observer)
    self.vm.outputs.goToContactCreator.map(first).observe(self.goToContactCreatorSubject.observer)
    self.vm.outputs.goToContactCreator.map(second).observe(self.goToContactCreatorContext.observer)
    self.vm.outputs.goToRewards.observe(self.goToRewards.observer)
    self.vm.outputs.goToUpdatePledge.map(first).observe(self.goToUpdatePledgeProject.observer)
    self.vm.outputs.goToUpdatePledge.map(second).observe(self.goToUpdatePledgeReward.observer)
    self.vm.outputs.notifyDelegateManagePledgeViewControllerFinishedWithMessage
      .observe(self.notifyDelegateManagePledgeViewControllerFinishedWithMessage.observer)
    self.vm.outputs.rewardReceivedViewControllerViewIsHidden.observe(
      self.rewardReceivedViewControllerViewIsHidden.observer
    )
    self.vm.outputs.showActionSheetMenuWithOptions.observe(self.showActionSheetMenuWithOptions.observer)
    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)
    self.vm.outputs.showSuccessBannerWithMessage.observe(self.showSuccessBannerWithMessage.observer)
  }

  func testNavigationBarTitle_LiveProject() {
    self.title.assertDidNotEmitValue()

    let project = Project.template
    self.vm.inputs.configureWith(project)

    self.vm.inputs.viewDidLoad()

    self.title.assertValue("Manage your pledge")
  }

  func testNavigationBarTitle_FinishedProject() {
    self.title.assertDidNotEmitValue()

    let finishedProject = Project.template
      |> \.state .~ .successful
    self.vm.inputs.configureWith(finishedProject)

    self.vm.inputs.viewDidLoad()

    self.title.assertValue("Your pledge")
  }

  func testConfigurePaymentMethodViewController() {
    self.configurePaymentMethodView.assertDidNotEmitValue()

    let backing = Backing.template

    let project = Project.template
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)

    self.vm.inputs.viewDidLoad()

    self.configurePaymentMethodView.assertValue(Backing.PaymentSource.template)
  }

  func testConfigurePledgeSummaryViewController() {
    self.configurePledgeSummaryView.assertDidNotEmitValue()

    let project = Project.template
    self.vm.inputs.configureWith(project)

    self.vm.inputs.viewDidLoad()

    self.configurePledgeSummaryView.assertValue(project)
  }

  func testConfigureRewardSummaryViewController() {
    self.configureRewardSummaryViewProject.assertDidNotEmitValue()
    self.configureRewardSummaryViewReward.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(project)

    self.vm.inputs.viewDidLoad()

    self.configureRewardSummaryViewProject.assertValue(project)
    self.configureRewardSummaryViewReward.assertValue(Reward.template)
  }

  func testConfigureRewardReceived() {
    self.configureRewardReceivedWithProject.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(project)

    self.vm.inputs.viewDidLoad()

    self.configureRewardReceivedWithProject.assertValue(project)
  }

  func testMenuButtonTapped_WhenProject_IsLive() {
    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()

    self.showActionSheetMenuWithOptions.assertValues([
      [
        ManagePledgeAlertAction.updatePledge,
        ManagePledgeAlertAction.changePaymentMethod,
        ManagePledgeAlertAction.chooseAnotherReward,
        ManagePledgeAlertAction.contactCreator,
        ManagePledgeAlertAction.cancelPledge
      ]
    ])
  }

  func testMenuButtonTapped_WhenProject_IsNotLive() {
    let project = Project.template
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()

    self.showActionSheetMenuWithOptions.assertValues([[.viewRewards, .contactCreator]])
  }

  func testMenuButtonTapped_WhenProject_IsLive_BackingStatus_IsPreAuth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()

    self.showActionSheetMenuWithOptions.assertValues([[.contactCreator]])
  }

  func testGoToCancelPledge() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.goToCancelPledgeProject.assertDidNotEmitValue()
    self.goToCancelPledgeBacking.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .cancelPledge)

    self.goToCancelPledgeProject.assertValues([project])
    self.goToCancelPledgeBacking.assertValues([Backing.template])
    self.showErrorBannerWithMessage.assertDidNotEmitValue()
  }

  func testBackingNotCancellable() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ (Backing.template |> Backing.lens.cancelable .~ false)

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.showErrorBannerWithMessage.assertDidNotEmitValue()
    self.goToCancelPledgeProject.assertDidNotEmitValue()
    self.goToCancelPledgeBacking.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .cancelPledge)

    self.goToCancelPledgeProject.assertDidNotEmitValue()
    self.goToCancelPledgeBacking.assertDidNotEmitValue()
    self.showErrorBannerWithMessage.assertValues([
      // swiftlint:disable:next line_length
      "We don’t allow cancelations that will cause a project to fall short of its goal within the last 24 hours."
    ])
  }

  func testGoToChangePaymentMethod() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.goToChangePaymentMethodProject.assertDidNotEmitValue()
    self.goToChangePaymentMethodReward.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .changePaymentMethod)

    self.goToChangePaymentMethodProject.assertValues([project])
    self.goToChangePaymentMethodReward.assertValues([Reward.template])
  }

  func testGoToContactCreator() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.goToContactCreatorSubject.assertDidNotEmitValue()
    self.goToContactCreatorContext.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .contactCreator)

    self.goToContactCreatorSubject.assertValues([.project(project)])
    self.goToContactCreatorContext.assertValues([.backerModal])
  }

  func testGoToRewards() {
    self.vm.inputs.configureWith(Project.template)
    self.vm.inputs.viewDidLoad()

    self.goToRewards.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .chooseAnotherReward)

    self.goToRewards.assertValues([Project.template])
  }

  func testGoToUpdatePledge() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.goToUpdatePledgeProject.assertDidNotEmitValue()
    self.goToUpdatePledgeReward.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .updatePledge)

    self.goToUpdatePledgeProject.assertValues([project])
    self.goToUpdatePledgeReward.assertValues([Reward.template])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Canceled() {
    let backing = Backing.template
      |> Backing.lens.status .~ .canceled
      |> Backing.lens.reward .~ Reward.noReward

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Collected() {
    let backing = Backing.template
      |> Backing.lens.status .~ .collected
      |> Backing.lens.reward .~ Reward.noReward

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Dropped() {
    let backing = Backing.template
      |> Backing.lens.reward .~ Reward.noReward
      |> Backing.lens.status .~ .dropped

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Errored() {
    let backing = Backing.template
      |> Backing.lens.reward .~ Reward.noReward
      |> Backing.lens.status .~ .errored

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Pledged() {
    let backing = Backing.template
      |> Backing.lens.reward .~ Reward.noReward
      |> Backing.lens.status .~ .pledged

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Preauth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Canceled() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Collected() {
    let backing = Backing.template
      |> Backing.lens.status .~ .collected

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([false])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Dropped() {
    let backing = Backing.template
      |> Backing.lens.status .~ .dropped

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Errored() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Pledged() {
    let backing = Backing.template
      |> Backing.lens.status .~ .pledged

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Preauth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testNotifyDelegateManagePledgeViewControllerFinishedWithMessage_CancellingPledge() {
    self.vm.inputs.configureWith(Project.template)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateManagePledgeViewControllerFinishedWithMessage.assertDidNotEmitValue()

    self.vm.inputs.cancelPledgeDidFinish(with: "You cancelled your pledge.")

    self.notifyDelegateManagePledgeViewControllerFinishedWithMessage
      .assertValues(["You cancelled your pledge."])
  }

  func testNotifyDelegateManagePledgeViewControllerFinishedWithMessage_UpdatingPledge() {
    self.vm.inputs.configureWith(Project.template)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateManagePledgeViewControllerFinishedWithMessage.assertDidNotEmitValue()

    self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Pledge updated.")

    self.notifyDelegateManagePledgeViewControllerFinishedWithMessage
      .assertValues([], "The delegate doesn't send message when updating a pledge.")
  }

  func testPledgeViewControllerDidUpdatePledge() {
    let backing = Backing.template
      |> Backing.lens.amount .~ 5.00
    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ backing
    let updatedProject = project
      |> Project.lens.personalization.backing .~ (backing |> Backing.lens.amount .~ 10.00)

    let mockService = MockService(fetchProjectResponse: updatedProject)

    withEnvironment(apiService: mockService) {
      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.configurePaymentMethodView.assertDidNotEmitValue()
      self.configurePledgeSummaryView.assertDidNotEmitValue()
      self.configureRewardSummaryViewProject.assertDidNotEmitValue()
      self.configureRewardSummaryViewReward.assertDidNotEmitValue()
      self.configureRewardReceivedWithProject.assertDidNotEmitValue()
      self.title.assertDidNotEmitValue()

      self.vm.inputs.configureWith(project)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Got it! Your changes have been saved.")

      self.scheduler.run()

      self.showSuccessBannerWithMessage.assertValues(["Got it! Your changes have been saved."])
      self.configurePaymentMethodView.assertValues([
        Backing.PaymentSource.template,
        Backing.PaymentSource.template
      ])
      self.configurePledgeSummaryView.assertValues([project, updatedProject])
      self.configureRewardSummaryViewProject.assertValues([project, updatedProject])
      self.configureRewardSummaryViewReward.assertValues([.template, .template])
      self.configureRewardReceivedWithProject.assertValues([project, updatedProject])
      self.title.assertValueCount(2)
    }
  }

  func testTrackingEvents() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .updatePledge)

    XCTAssertEqual(["Manage Pledge Option Clicked"], self.trackingClient.events)
  }

  func testEndRefreshing() {
    let project = Project.template |> Project.lens.personalization.backing .~ .template
    let mockService = MockService(fetchProjectResponse: project)

    withEnvironment(apiService: mockService) {
      self.endRefreshing.assertDidNotEmitValue()

      self.vm.inputs.configureWith(.template)
      self.vm.inputs.viewDidLoad()

      self.endRefreshing.assertDidNotEmitValue()

      self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Updated")

      self.scheduler.run()

      self.endRefreshing.assertValueCount(1, "End refreshing is called on success")

      self.vm.inputs.beginRefresh()

      self.scheduler.run()

      self.endRefreshing.assertValueCount(2, "End refreshing is called on success")

      let failureMockService = MockService(fetchProjectError: .couldNotParseJSON)

      withEnvironment(apiService: failureMockService) {
        self.vm.inputs.beginRefresh()

        self.scheduler.run()

        self.endRefreshing.assertValueCount(3, "End refreshing is called on error")
      }
    }
  }
}
