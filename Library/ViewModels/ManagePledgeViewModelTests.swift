import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ManagePledgeViewModelTests: TestCase {
  private let vm = ManagePledgeViewModel()

  private let configurePaymentMethodView = TestObserver<ManagePledgePaymentMethodViewData, Never>()
  private let configurePledgeSummaryView = TestObserver<ManagePledgeSummaryViewData, Never>()
  private let configureRewardReceivedWithProject = TestObserver<Project, Never>()
  private let configureRewardSummaryViewProject = TestObserver<Project, Never>()
  private let configureRewardSummaryViewReward = TestObserver<Reward, Never>()
  private let endRefreshing = TestObserver<Void, Never>()
  private let goToCancelPledge = TestObserver<CancelPledgeViewData, Never>()
  private let goToChangePaymentMethodProject = TestObserver<Project, Never>()
  private let goToChangePaymentMethodReward = TestObserver<Reward, Never>()
  private let goToContactCreatorSubject = TestObserver<MessageSubject, Never>()
  private let goToContactCreatorContext = TestObserver<Koala.MessageDialogContext, Never>()
  private let goToFixPaymentMethodProject = TestObserver<Project, Never>()
  private let goToFixPaymentMethodReward = TestObserver<Reward, Never>()
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
    self.vm.outputs.goToCancelPledge.observe(self.goToCancelPledge.observer)
    self.vm.outputs.goToChangePaymentMethod.map(first).observe(self.goToChangePaymentMethodProject.observer)
    self.vm.outputs.goToChangePaymentMethod.map(second).observe(self.goToChangePaymentMethodReward.observer)
    self.vm.outputs.goToContactCreator.map(first).observe(self.goToContactCreatorSubject.observer)
    self.vm.outputs.goToContactCreator.map(second).observe(self.goToContactCreatorContext.observer)
    self.vm.outputs.goToFixPaymentMethod.map(first).observe(self.goToFixPaymentMethodProject.observer)
    self.vm.outputs.goToFixPaymentMethod.map(second).observe(self.goToFixPaymentMethodReward.observer)
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

    let mockService = MockService(fetchManagePledgeViewBackingResult: .success(.template))

    withEnvironment(apiService: mockService) {
      self.title.assertDidNotEmitValue()

      self.vm.inputs.configureWith(.left(project))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.title.assertValues(["Manage your pledge"])
    }
  }

  func testNavigationBarTitle_FinishedProject() {
    self.title.assertDidNotEmitValue()

    let finishedProject = Project.template
      |> \.state .~ .successful

    let envelope = ManagePledgeViewBackingEnvelope.template
      |> \.project.state .~ .successful

    let mockService = MockService(fetchManagePledgeViewBackingResult: .success(envelope))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(.left(finishedProject))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.title.assertValue("Your pledge")
    }
  }

  func testConfigurePaymentMethodViewController() {
    self.configurePaymentMethodView.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    let envelope = ManagePledgeViewBackingEnvelope.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope)
    )

    let pledgePaymentMethodViewData = ManagePledgePaymentMethodViewData(
      backingState: .pledged,
      expirationDate: "2020-01-01",
      lastFour: "1234",
      creditCardType: .visa,
      paymentType: .creditCard
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(.left(project))

      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodView.assertDidNotEmitValue()

      self.scheduler.advance()

      self.configurePaymentMethodView.assertValues([pledgePaymentMethodViewData])
    }
  }

  func testConfigurePledgeSummaryViewController() {
    self.configurePledgeSummaryView.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    let envelope = ManagePledgeViewBackingEnvelope.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope)
    )

    let pledgeViewSummaryData = ManagePledgeSummaryViewData(
      backerId: envelope.backing.backer.uid,
      backerName: envelope.backing.backer.name,
      backerSequence: envelope.backing.sequence,
      backingState: BackingState.pledged,
      currentUserIsCreatorOfProject: false,
      locationName: "Brooklyn, NY",
      needsConversion: false,
      omitUSCurrencyCode: true,
      pledgeAmount: envelope.backing.amount.amount,
      pledgedOn: envelope.backing.pledgedOn,
      projectCountry: Project.Country.us,
      projectDeadline: 1_476_657_315.0,
      projectState: ProjectState.live,
      shippingAmount: envelope.backing.shippingAmount?.amount
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(.left(project))

      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryView.assertDidNotEmitValue()

      self.scheduler.advance()

      self.configurePledgeSummaryView.assertValues([pledgeViewSummaryData])
    }
  }

  func testConfigureRewardSummaryViewController() {
    self.configureRewardSummaryViewProject.assertDidNotEmitValue()
    self.configureRewardSummaryViewReward.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(.left(project))

    self.vm.inputs.viewDidLoad()

    self.configureRewardSummaryViewProject.assertValue(project)
    self.configureRewardSummaryViewReward.assertValue(Reward.template)
  }

  func testConfigureRewardReceived() {
    self.configureRewardReceivedWithProject.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(.left(project))

    self.vm.inputs.viewDidLoad()

    self.configureRewardReceivedWithProject.assertValue(project)
  }

  func testMenuButtonTapped_WhenProject_IsLive() {
    let project = Project.template
      |> Project.lens.state .~ .live

    self.vm.inputs.configureWith(.left(project))
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

    self.vm.inputs.configureWith(.left(project))
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

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()

    self.showActionSheetMenuWithOptions.assertValues([[.contactCreator]])
  }

  func testGoToCancelPledge() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    let envelope = ManagePledgeViewBackingEnvelope.template

    let expectedId = envelope.backing.id
    let expectedAmount = envelope.backing.amount.amount

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope)
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(.left(project))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToCancelPledge.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .cancelPledge)

      XCTAssertEqual(self.goToCancelPledge.values.map { $0.project }, [project])
      XCTAssertEqual(self.goToCancelPledge.values.map { $0.backingId }, [expectedId])
      XCTAssertEqual(self.goToCancelPledge.values.map { $0.pledgeAmount }, [expectedAmount])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }

  func testBackingNotCancelable() {
    let envelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing.cancelable .~ false

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope)
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(.left(.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.goToCancelPledge.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .cancelPledge)

      self.goToCancelPledge.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertValues([
        "We don’t allow cancelations that will cause a project to fall short of its goal within the last 24 hours."
      ])
    }
  }

  func testGoToChangePaymentMethod() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(.left(project))
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

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.goToContactCreatorSubject.assertDidNotEmitValue()
    self.goToContactCreatorContext.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .contactCreator)

    self.goToContactCreatorSubject.assertValues([.project(project)])
    self.goToContactCreatorContext.assertValues([.backerModal])
  }

  func testGoToRewards() {
    self.vm.inputs.configureWith(.left(Project.template))
    self.vm.inputs.viewDidLoad()

    self.goToRewards.assertDidNotEmitValue()

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .chooseAnotherReward)

    self.goToRewards.assertValues([Project.template])
  }

  func testGoToUpdatePledge() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(.left(project))
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

    self.vm.inputs.configureWith(.left(project))
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

    self.vm.inputs.configureWith(.left(project))
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

    self.vm.inputs.configureWith(.left(project))
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

    self.vm.inputs.configureWith(.left(project))
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

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Preauth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Canceled() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Collected() {
    let backing = Backing.template
      |> Backing.lens.status .~ .collected

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([false])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Dropped() {
    let backing = Backing.template
      |> Backing.lens.status .~ .dropped

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Errored() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Pledged() {
    let backing = Backing.template
      |> Backing.lens.status .~ .pledged

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Preauth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
  }

  func testNotifyDelegateManagePledgeViewControllerFinishedWithMessage_CancellingPledge() {
    self.vm.inputs.configureWith(.left(Project.template))
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateManagePledgeViewControllerFinishedWithMessage.assertDidNotEmitValue()

    self.vm.inputs.cancelPledgeDidFinish(with: "You cancelled your pledge.")

    self.notifyDelegateManagePledgeViewControllerFinishedWithMessage
      .assertValues(["You cancelled your pledge."])
  }

  func testNotifyDelegateManagePledgeViewControllerFinishedWithMessage_UpdatingPledge() {
    self.vm.inputs.configureWith(.left(Project.template))
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

    let envelope = ManagePledgeViewBackingEnvelope.template

    // Pledge amount 25
    let initialPledgeViewSummaryData = ManagePledgeSummaryViewData(
      backerId: envelope.backing.backer.uid,
      backerName: envelope.backing.backer.name,
      backerSequence: envelope.backing.sequence,
      backingState: BackingState.pledged,
      currentUserIsCreatorOfProject: false,
      locationName: "Brooklyn, NY",
      needsConversion: true,
      omitUSCurrencyCode: true,
      pledgeAmount: 25,
      pledgedOn: envelope.backing.pledgedOn,
      projectCountry: project.country,
      projectDeadline: 1_476_657_315.0,
      projectState: ProjectState.live,
      shippingAmount: envelope.backing.shippingAmount?.amount
    )

    // Pledge amount 50
    let updatedPledgeViewSummaryData = ManagePledgeSummaryViewData(
      backerId: envelope.backing.backer.uid,
      backerName: envelope.backing.backer.name,
      backerSequence: envelope.backing.sequence,
      backingState: BackingState.pledged,
      currentUserIsCreatorOfProject: false,
      locationName: "Brooklyn, NY",
      needsConversion: true,
      omitUSCurrencyCode: true,
      pledgeAmount: 50,
      pledgedOn: envelope.backing.pledgedOn,
      projectCountry: project.country,
      projectDeadline: 1_476_657_315.0,
      projectState: ProjectState.live,
      shippingAmount: envelope.backing.shippingAmount?.amount
    )

    let pledgePaymentMethodViewData = ManagePledgePaymentMethodViewData(
      backingState: .pledged,
      expirationDate: "2020-01-01",
      lastFour: "1234",
      creditCardType: .visa,
      paymentType: .creditCard
    )

    let initialBackingEnvelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing.amount.amount .~ 25
    let updatedBackingEnvelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing.amount.amount .~ 50

    withEnvironment(
      apiService: MockService(fetchManagePledgeViewBackingResult: .success(initialBackingEnvelope))
    ) {
      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.configurePaymentMethodView.assertDidNotEmitValue()
      self.configurePledgeSummaryView.assertDidNotEmitValue()
      self.configureRewardSummaryViewProject.assertDidNotEmitValue()
      self.configureRewardSummaryViewReward.assertDidNotEmitValue()
      self.configureRewardReceivedWithProject.assertDidNotEmitValue()
      self.title.assertDidNotEmitValue()

      self.vm.inputs.configureWith(.left(project))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.configurePaymentMethodView.assertValues([pledgePaymentMethodViewData])
      self.configurePledgeSummaryView.assertValues([initialPledgeViewSummaryData])

      self.configureRewardSummaryViewProject.assertValues([project])
      self.configureRewardSummaryViewReward.assertValues([.template])
      self.configureRewardReceivedWithProject.assertValues([project])
      self.title.assertValues(["Manage your pledge"])
    }

    withEnvironment(
      apiService: MockService(fetchManagePledgeViewBackingResult: .success(updatedBackingEnvelope))
    ) {
      self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Got it! Your changes have been saved.")

      self.scheduler.run()

      self.showSuccessBannerWithMessage.assertValues(["Got it! Your changes have been saved."])

      self.configurePaymentMethodView.assertValues([
        pledgePaymentMethodViewData,
        pledgePaymentMethodViewData
      ])
      self.configurePledgeSummaryView.assertValues([
        initialPledgeViewSummaryData,
        updatedPledgeViewSummaryData
      ])

      self.configureRewardSummaryViewProject.assertValues([project])
      self.configureRewardSummaryViewReward.assertValues([.template])
      self.configureRewardReceivedWithProject.assertValues([project])
      self.title.assertValues(["Manage your pledge", "Manage your pledge"])
    }
  }

  func testTrackingEvents() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.menuButtonTapped()
    self.vm.inputs.menuOptionSelected(with: .updatePledge)

    XCTAssertEqual(["Manage Pledge Option Clicked"], self.trackingClient.events)
  }

  func testFixPaymentTrackingEvents() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ Backing.template

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.fixButtonTapped()

    XCTAssertEqual(["Fix Pledge Button Clicked"], self.trackingClient.events)
  }

  func testEndRefreshing() {
    let mockService = MockService(fetchManagePledgeViewBackingResult: .success(.template))

    withEnvironment(apiService: mockService) {
      self.endRefreshing.assertDidNotEmitValue()

      self.vm.inputs.configureWith(.left(.template))
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

  func testFixButtonTapped() {
    self.goToChangePaymentMethodReward.assertDidNotEmitValue()
    self.goToChangePaymentMethodProject.assertDidNotEmitValue()

    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ Backing.template
    let reward = Project.cosmicSurgery.rewards.filter { $0.id == Backing.template.rewardId }.first!

    self.vm.inputs.configureWith(.left(project))
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.fixButtonTapped()

    self.goToFixPaymentMethodProject.assertValues([project])
    self.goToFixPaymentMethodReward.assertValues([reward])
  }
}
