import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ManagePledgeViewModelTests: TestCase {
  private var vm: ManagePledgeViewModelType!

  private let configurePaymentMethodView = TestObserver<ManagePledgePaymentMethodViewData, Never>()
  private let configurePledgeSummaryView = TestObserver<ManagePledgeSummaryViewData, Never>()
  private let configureRewardReceivedWithData = TestObserver<ManageViewPledgeRewardReceivedViewData, Never>()
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
  private let loadProjectAndRewardsIntoDataSourceProject = TestObserver<Project, Never>()
  private let loadProjectAndRewardsIntoDataSourceReward = TestObserver<[Reward], Never>()
  private let loadPullToRefreshHeaderView = TestObserver<(), Never>()
  private let notifyDelegateManagePledgeViewControllerFinishedWithMessage
    = TestObserver<String?, Never>()
  private let paymentMethodViewHidden = TestObserver<Bool, Never>()
  private let pledgeDetailsSectionLabelText = TestObserver<String, Never>()
  private let pledgeDisclaimerViewHidden = TestObserver<Bool, Never>()
  private let rewardReceivedViewControllerViewIsHidden = TestObserver<Bool, Never>()
  private let rightBarButtonItemHidden = TestObserver<Bool, Never>()
  private let showActionSheetMenuWithOptions = TestObserver<[ManagePledgeAlertAction], Never>()
  private let showErrorBannerWithMessage = TestObserver<String, Never>()
  private let showSuccessBannerWithMessage = TestObserver<String, Never>()
  private let startRefreshing = TestObserver<(), Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm = ManagePledgeViewModel()

    self.vm.outputs.title.observe(self.title.observer)
    self.vm.outputs.configurePaymentMethodView
      .observe(self.configurePaymentMethodView.observer)
    self.vm.outputs.configurePledgeSummaryView
      .observe(self.configurePledgeSummaryView.observer)
    self.vm.outputs.configureRewardReceivedWithData
      .observe(self.configureRewardReceivedWithData.observer)
    self.vm.outputs.loadProjectAndRewardsIntoDataSource.map(first)
      .observe(self.loadProjectAndRewardsIntoDataSourceProject.observer)
    self.vm.outputs.loadProjectAndRewardsIntoDataSource.map(second)
      .observe(self.loadProjectAndRewardsIntoDataSourceReward.observer)
    self.vm.outputs.loadPullToRefreshHeaderView.observe(self.loadPullToRefreshHeaderView.observer)
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
    self.vm.outputs.paymentMethodViewHidden.observe(self.paymentMethodViewHidden.observer)
    self.vm.outputs.pledgeDetailsSectionLabelText.observe(self.pledgeDetailsSectionLabelText.observer)
    self.vm.outputs.pledgeDisclaimerViewHidden.observe(self.pledgeDisclaimerViewHidden.observer)
    self.vm.outputs.rewardReceivedViewControllerViewIsHidden.observe(
      self.rewardReceivedViewControllerViewIsHidden.observer
    )
    self.vm.outputs.rightBarButtonItemHidden.observe(self.rightBarButtonItemHidden.observer)
    self.vm.outputs.showActionSheetMenuWithOptions.observe(self.showActionSheetMenuWithOptions.observer)
    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)
    self.vm.outputs.showSuccessBannerWithMessage.observe(self.showSuccessBannerWithMessage.observer)
    self.vm.outputs.startRefreshing.observe(self.startRefreshing.observer)
  }

  func testNavigationBarTitle_LiveProject() {
    self.title.assertDidNotEmitValue()

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: .template
    )

    withEnvironment(apiService: mockService) {
      self.title.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
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

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: finishedProject
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.title.assertValue("Your pledge")
    }
  }

  func testConfigurePaymentMethodViewController() {
    self.configurePaymentMethodView.assertDidNotEmitValue()

    let project = Project.template

    let envelope = ManagePledgeViewBackingEnvelope.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: project
    )

    let pledgePaymentMethodViewData = ManagePledgePaymentMethodViewData(
      backingState: .pledged,
      expirationDate: "2020-01-01",
      lastFour: "1234",
      creditCardType: .visa,
      paymentType: .creditCard
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))

      self.vm.inputs.viewDidLoad()

      self.configurePaymentMethodView.assertDidNotEmitValue()

      self.scheduler.advance()

      self.configurePaymentMethodView.assertValues([pledgePaymentMethodViewData])
    }
  }

  func testConfigurePledgeSummaryViewController() {
    self.configurePledgeSummaryView.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.noReward
          |> Backing.lens.rewardId .~ Reward.noReward.id
      )

    let envelope = ManagePledgeViewBackingEnvelope.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: project
    )

    let pledgeViewSummaryData = ManagePledgeSummaryViewData(
      backerId: envelope.backing.backer.uid,
      backerName: envelope.backing.backer.name,
      backerSequence: envelope.backing.sequence,
      backingState: BackingState.pledged,
      bonusAmount: nil,
      currentUserIsCreatorOfProject: false,
      isNoReward: true,
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
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))

      self.vm.inputs.viewDidLoad()

      self.configurePledgeSummaryView.assertDidNotEmitValue()

      self.scheduler.advance()

      self.configurePledgeSummaryView.assertValues([pledgeViewSummaryData])
    }
  }

  func testloadProjectAndRewardsIntoDataSource() {
    self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
    self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.rewards .~ [.template]

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing .~ (.template |> \.addOns .~ nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadProjectAndRewardsIntoDataSourceProject.assertValue(project)
      self.loadProjectAndRewardsIntoDataSourceReward.assertValue([Reward.template])
    }
  }

  func testConfigureRewardReceived() {
    self.configureRewardReceivedWithData.assertDidNotEmitValue()

    let project = Project.template
      |> \.rewards .~ [.template]

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing .~ (.template |> \.addOns .~ nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    let expectedData = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_506_897_315.0,
      backingState: .pledged
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.configureRewardReceivedWithData.assertValue(expectedData)
    }
  }

  func testMenuButtonTapped_WhenProject_IsLive() {
    let project = Project.template
      |> Project.lens.state .~ .live

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

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
  }

  func testMenuButtonTapped_WhenProject_IsSuccessful_CreatorContext() {
    let user = User.template
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.creator .~ user

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([[.viewRewards]])
    }
  }

  func testMenuButtonTapped_WhenProject_IsNotLive() {
    let project = Project.template
      |> Project.lens.state .~ .successful

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([[.viewRewards, .contactCreator]])
    }
  }

  func testMenuButtonTapped_WhenProject_IsLive_BackingStatus_IsPreAuth() {
    let project = Project.template
      |> Project.lens.state .~ .live

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing.status .~ .preauth

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([[.contactCreator]])
    }
  }

  func testMenuButtonTapped_WhenProject_IsLive_BackingStatus_IsPreAuth_CreatorContext() {
    let user = User.template
    let project = Project.template
      |> Project.lens.creator .~ user
      |> Project.lens.state .~ .live

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing.status .~ .preauth

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([[.viewRewards]])
    }
  }

  func testGoToCancelPledge() {
    let project = Project.template

    let envelope = ManagePledgeViewBackingEnvelope.template

    let expectedId = envelope.backing.id
    let expectedAmount = envelope.backing.amount.amount

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
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
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResponse: .template
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
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
      |> Project.lens.rewards .~ [.template]

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToChangePaymentMethodProject.assertDidNotEmitValue()
      self.goToChangePaymentMethodReward.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .changePaymentMethod)

      self.goToChangePaymentMethodProject.assertValues([project])
      self.goToChangePaymentMethodReward.assertValues([Reward.template])
    }
  }

  func testGoToContactCreator() {
    let project = Project.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToContactCreatorSubject.assertDidNotEmitValue()
      self.goToContactCreatorContext.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .contactCreator)

      self.goToContactCreatorSubject.assertValues([.project(project)])
      self.goToContactCreatorContext.assertValues([.backerModal])
    }
  }

  func testGoToRewards() {
    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: .template
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToRewards.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .chooseAnotherReward)

      self.goToRewards.assertValues([Project.template])
    }
  }

  func testGoToUpdatePledge() {
    let project = Project.template
      |> Project.lens.rewards .~ [.template]

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToUpdatePledgeProject.assertDidNotEmitValue()
      self.goToUpdatePledgeReward.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .updatePledge)

      self.goToUpdatePledgeProject.assertValues([project])
      self.goToUpdatePledgeReward.assertValues([Reward.template])
    }
  }

  func testRewardReceivedViewControllerIsHidden_EstimatedDeliveryOnIsNil() {
    let reward = Reward.noReward

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing .~ (.template |> \.addOns .~ nil)

    let backing = Backing.template
      |> Backing.lens.status .~ .canceled
      |> Backing.lens.reward .~ reward

    let project = Project.template
      |> Project.lens.rewards .~ [reward]
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.rewardReceivedViewControllerViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_EstimatedDeliveryOnIsNotNil() {
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ 1_475_361_315

    let backing = Backing.template
      |> Backing.lens.status .~ .collected
      |> Backing.lens.reward .~ reward

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ [reward]
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.rewardReceivedViewControllerViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([false])
    }
  }

  func testNotifyDelegateManagePledgeViewControllerFinishedWithMessage_CancellingPledge() {
    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: .template
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.notifyDelegateManagePledgeViewControllerFinishedWithMessage.assertDidNotEmitValue()

      self.vm.inputs.cancelPledgeDidFinish(with: "You cancelled your pledge.")

      self.notifyDelegateManagePledgeViewControllerFinishedWithMessage
        .assertValues(["You cancelled your pledge."])
    }
  }

  func testNotifyDelegateManagePledgeViewControllerFinishedWithMessage_UpdatingPledge() {
    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: .template
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.notifyDelegateManagePledgeViewControllerFinishedWithMessage.assertDidNotEmitValue()

      self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Pledge updated.")

      self.notifyDelegateManagePledgeViewControllerFinishedWithMessage
        .assertValues([], "The delegate doesn't send message when updating a pledge.")
    }
  }

  func testPledgeViewControllerDidUpdatePledge() {
    let project = Project.cosmicSurgery
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.noReward
          |> Backing.lens.rewardId .~ Reward.noReward.id
      )

    let envelope = ManagePledgeViewBackingEnvelope.template
      |> \.backing .~ (.template |> \.addOns .~ nil)

    // Pledge amount 25
    let initialPledgeViewSummaryData = ManagePledgeSummaryViewData(
      backerId: envelope.backing.backer.uid,
      backerName: envelope.backing.backer.name,
      backerSequence: envelope.backing.sequence,
      backingState: BackingState.pledged,
      bonusAmount: nil,
      currentUserIsCreatorOfProject: false,
      isNoReward: true,
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
      bonusAmount: nil,
      currentUserIsCreatorOfProject: false,
      isNoReward: true,
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

    let initialBackingEnvelope = envelope
      |> \.backing.amount.amount .~ 25
    let updatedBackingEnvelope = envelope
      |> \.backing.amount.amount .~ 50

    let mockService1 = MockService(
      fetchManagePledgeViewBackingResult: .success(initialBackingEnvelope),
      fetchProjectResponse: project
    )

    let expectedRewardReceivedData = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: false,
      estimatedDeliveryOn: 1_506_897_315.0,
      backingState: .pledged
    )

    withEnvironment(apiService: mockService1) {
      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.configurePaymentMethodView.assertDidNotEmitValue()
      self.configurePledgeSummaryView.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.configureRewardReceivedWithData.assertDidNotEmitValue()
      self.title.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.configurePaymentMethodView.assertValues([pledgePaymentMethodViewData])
      self.configurePledgeSummaryView.assertValues([initialPledgeViewSummaryData])

      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[.template]])
      self.configureRewardReceivedWithData.assertValues([expectedRewardReceivedData])
      self.title.assertValues(["Manage your pledge"])
    }

    let mockService2 = MockService(
      fetchManagePledgeViewBackingResult: .success(updatedBackingEnvelope),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService2) {
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

      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[.template], [.template], [.template]])
      self.configureRewardReceivedWithData.assertValues([
        expectedRewardReceivedData,
        expectedRewardReceivedData,
        expectedRewardReceivedData,
        expectedRewardReceivedData
      ])
      self.title.assertValues(["Manage your pledge", "Manage your pledge"])
    }
  }

  func testTrackingEvents() {
    let project = Project.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      XCTAssertEqual([], self.trackingClient.events)

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .updatePledge)

      XCTAssertEqual(["Manage Pledge Option Clicked"], self.trackingClient.events)
    }
  }

  func testFixPaymentTrackingEvents() {
    let project = Project.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      XCTAssertEqual([], self.trackingClient.events)

      self.vm.inputs.fixButtonTapped()

      XCTAssertEqual(["Fix Pledge Button Clicked"], self.trackingClient.events)
    }
  }

  func testRefreshing_ProjectErrorThenSuccess() {
    let mockService = MockService(
      fetchProjectError: .couldNotParseJSON
    )

    withEnvironment(apiService: mockService) {
      self.startRefreshing.assertDidNotEmitValue()
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1, "Refreshing ends after project fails")
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
      self.loadPullToRefreshHeaderView.assertValueCount(1)

      let reward = Reward.template
      let project = Project.template
        |> \.rewards .~ [reward]

      let env = ManagePledgeViewBackingEnvelope.template
        |> \.backing .~ (.template |> \.addOns .~ nil)

      let successMockService = MockService(
        fetchManagePledgeViewBackingResult: .success(env),
        fetchProjectResponse: project
      )

      withEnvironment(apiService: successMockService) {
        // User pulls to refresh
        self.vm.inputs.beginRefresh()

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(1)
        self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
        self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
        self.rightBarButtonItemHidden.assertValues([true])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertValueCount(1)

        // Network request completes
        self.scheduler.advance()

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(1, "Does not end refreshing, fetching backing")
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertValueCount(1)

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(3, "Ends refreshing for project and backing")
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertValueCount(1)
      }
    }
  }

  func testRefreshing_BackingErrorThenSuccess() {
    let reward = Reward.template
    let project = Project.template
      |> \.rewards .~ [reward]

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .failure(.invalidInput),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.startRefreshing.assertDidNotEmitValue()
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
      self.loadPullToRefreshHeaderView.assertValueCount(1)

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1)
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
      self.loadPullToRefreshHeaderView.assertValueCount(1)

      let env = ManagePledgeViewBackingEnvelope.template
        |> \.backing .~ (.template |> \.addOns .~ nil)

      let successMockService = MockService(
        fetchManagePledgeViewBackingResult: .success(env),
        fetchProjectResponse: .template
      )

      withEnvironment(apiService: successMockService) {
        // User pulls to refresh
        self.vm.inputs.beginRefresh()

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(1)
        self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
        self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
        self.rightBarButtonItemHidden.assertValues([true])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertValueCount(1)

        // Network request completes
        self.scheduler.advance()

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(1)
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertValueCount(1)

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(2)
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertValueCount(1)
      }
    }
  }

  func testRefreshing_BackingSuccessThenError() {
    let reward = Reward.template
    let project = Project.template
      |> \.rewards .~ [reward]

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing .~ (.template |> \.addOns .~ nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.startRefreshing.assertDidNotEmitValue()
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // Pledge view completed a change
      self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Updated")

      self.startRefreshing.assertValueCount(2)
      self.endRefreshing.assertValueCount(1)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(2)
      self.endRefreshing.assertValueCount(1)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward], [reward], [reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(2)
      self.endRefreshing.assertValueCount(2)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward], [reward], [reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // User pulls to refresh
      self.vm.inputs.beginRefresh()

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(3)
      self.endRefreshing.assertValueCount(2)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
        [project, project, project, project, project]
      )
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
        [reward], [reward], [reward], [reward], [reward]
      ])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(3)
      self.endRefreshing.assertValueCount(3)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
        [project, project, project, project, project]
      )
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
        [reward], [reward], [reward], [reward], [reward]
      ])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      let failureMockService = MockService(
        fetchManagePledgeViewBackingResult: .failure(.invalidInput),
        fetchProjectResponse: project
      )

      withEnvironment(apiService: failureMockService) {
        // User pulls to refresh
        self.vm.inputs.beginRefresh()

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(3)
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
          [project, project, project, project, project]
        )
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
          [reward], [reward], [reward], [reward], [reward]
        ])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertDidNotEmitValue()
        self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

        // Network request completes
        self.scheduler.advance()

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(3)
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
          [project, project, project, project, project]
        )
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
          [reward], [reward], [reward], [reward], [reward]
        ])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(4, "End refresh on errors")
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
          [project, project, project, project, project]
        )
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
          [reward], [reward], [reward], [reward], [reward]
        ])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertDidNotEmitValue()
      }
    }
  }

  func testRefreshing_ProjectId_NilBackingId() {
    let reward = Reward.template
    let project = Project.template
      |> Project.lens.personalization.backing .~ .template
      |> Project.lens.rewards .~ [reward]

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing .~ (.template |> \.addOns .~ nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.startRefreshing.assertDidNotEmitValue()
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), nil))
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // Project request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // Backing request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()
    }
  }

  func testFixButtonTapped() {
    self.goToChangePaymentMethodReward.assertDidNotEmitValue()
    self.goToChangePaymentMethodProject.assertDidNotEmitValue()

    let project = Project.cosmicSurgery
    let reward = Project.cosmicSurgery.rewards.filter { $0.id == Backing.template.rewardId }.first!

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.fixButtonTapped()

      self.goToFixPaymentMethodProject.assertValues([project])
      self.goToFixPaymentMethodReward.assertValues([reward])
    }
  }

  func testPaymentMethodViewHidden_UserIsCreatorOfProject() {
    self.paymentMethodViewHidden.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.paymentMethodViewHidden.assertDidNotEmitValue()

      self.scheduler.advance()

      self.paymentMethodViewHidden.assertValues([true])
    }
  }

  func testPaymentMethodViewHidden_UserIsNotCreatorOfProject() {
    self.paymentMethodViewHidden.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (user |> User.lens.id .~ 999)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.paymentMethodViewHidden.assertDidNotEmitValue()

      self.scheduler.advance()

      self.paymentMethodViewHidden.assertValues([false])
    }
  }

  func testPledgeDisclaimerViewHidden_Shipping_UserIsCreatorOfProject() {
    self.pledgeDisclaimerViewHidden.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.pledgeDisclaimerViewHidden.assertDidNotEmitValue()

      self.scheduler.advance()

      self.pledgeDisclaimerViewHidden.assertValues([true])
    }
  }

  func testPledgeDisclaimerViewHidden_NoShipping_UserIsNotCreatorOfProject() {
    self.pledgeDisclaimerViewHidden.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (user |> User.lens.id .~ 999)
      |> \.rewards .~ [.template |> Reward.lens.estimatedDeliveryOn .~ nil]

    let addOn = ManagePledgeViewBackingEnvelope.Backing.Reward.template
      |> \.estimatedDeliveryOn .~ nil

    let reward = ManagePledgeViewBackingEnvelope.Backing.Reward.template
      |> \.estimatedDeliveryOn .~ nil

    let backing = ManagePledgeViewBackingEnvelope.Backing.template
      |> \.reward .~ reward
      |> \.addOns .~ .init(nodes: [addOn])

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.pledgeDisclaimerViewHidden.assertDidNotEmitValue()

      self.scheduler.advance()
      self.scheduler.advance(by: .milliseconds(300))

      self.pledgeDisclaimerViewHidden.assertValues([true])
    }
  }

  func testPledgeDisclaimerViewHidden_Shipping_UserIsNotCreatorOfProject() {
    self.pledgeDisclaimerViewHidden.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (user |> User.lens.id .~ 999)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.pledgeDisclaimerViewHidden.assertDidNotEmitValue()

      self.scheduler.advance()

      self.pledgeDisclaimerViewHidden.assertValues([false])
    }
  }

  func testPledgeDetailsSectionLabelText_UserIsNotCreatorOfProject() {
    self.pledgeDetailsSectionLabelText.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (user |> User.lens.id .~ 999)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.pledgeDetailsSectionLabelText.assertDidNotEmitValue()

      self.scheduler.advance()

      self.pledgeDetailsSectionLabelText.assertValues(["Your pledge details"])
    }
  }

  func testPledgeDetailsSectionLabelText_UserIsCreatorOfProject() {
    self.pledgeDetailsSectionLabelText.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.pledgeDetailsSectionLabelText.assertDidNotEmitValue()

      self.scheduler.advance()

      self.pledgeDetailsSectionLabelText.assertValues(["Pledge details"])
    }
  }
}
