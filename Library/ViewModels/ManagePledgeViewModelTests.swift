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
  private let paymentMethodViewHidden = TestObserver<Bool, Never>()
  private let pullToRefreshStackViewHidden = TestObserver<Bool, Never>()
  private let rewardReceivedViewControllerViewIsHidden = TestObserver<Bool, Never>()
  private let rightBarButtonItemHidden = TestObserver<Bool, Never>()
  private let rootStackViewHidden = TestObserver<Bool, Never>()
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
    self.vm.outputs.paymentMethodViewHidden.observe(self.paymentMethodViewHidden.observer)
    self.vm.outputs.pullToRefreshStackViewHidden.observe(self.pullToRefreshStackViewHidden.observer)
    self.vm.outputs.rewardReceivedViewControllerViewIsHidden.observe(
      self.rewardReceivedViewControllerViewIsHidden.observer
    )
    self.vm.outputs.rightBarButtonItemHidden.observe(self.rightBarButtonItemHidden.observer)
    self.vm.outputs.rootStackViewHidden.observe(self.rootStackViewHidden.observer)
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
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))

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
      |> Project.lens.rewards .~ [.template]

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.configureRewardSummaryViewProject.assertValue(project)
      self.configureRewardSummaryViewReward.assertValue(Reward.template)
    }
  }

  func testConfigureRewardReceived() {
    self.configureRewardReceivedWithProject.assertDidNotEmitValue()

    let project = Project.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.configureRewardReceivedWithProject.assertValue(project)
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

  func testRewardReceivedViewControllerIsHidden_NoReward_Canceled() {
    let backing = Backing.template
      |> Backing.lens.status .~ .canceled
      |> Backing.lens.reward .~ Reward.noReward

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Collected() {
    let backing = Backing.template
      |> Backing.lens.status .~ .collected
      |> Backing.lens.reward .~ Reward.noReward

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Dropped() {
    let backing = Backing.template
      |> Backing.lens.reward .~ Reward.noReward
      |> Backing.lens.status .~ .dropped

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Errored() {
    let backing = Backing.template
      |> Backing.lens.reward .~ Reward.noReward
      |> Backing.lens.status .~ .errored

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Pledged() {
    let backing = Backing.template
      |> Backing.lens.reward .~ Reward.noReward
      |> Backing.lens.status .~ .pledged

    let project = Project.cosmicSurgery
      |> Project.lens.rewards .~ ([Reward.noReward] + Project.cosmicSurgery.rewards.suffix(from: 1))
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_NoReward_Preauth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Canceled() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Collected() {
    let project = Project.cosmicSurgery

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing.status .~ .collected

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([false])
    }
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Dropped() {
    let backing = Backing.template
      |> Backing.lens.status .~ .dropped

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Errored() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Pledged() {
    let backing = Backing.template
      |> Backing.lens.status .~ .pledged

    let project = Project.cosmicSurgery
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Preauth() {
    let backing = Backing.template
      |> Backing.lens.status .~ .preauth

    let project = Project.template
      |> Project.lens.personalization .. Project.Personalization.lens.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
    }
  }

  func testRewardReceivedViewControllerIsHidden_Reward_Collected_UserIsCreatorOfProject() {
    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user

    let env = ManagePledgeViewBackingEnvelope.template
      |> \.backing.status .~ .collected

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.rewardReceivedViewControllerViewIsHidden.assertDidNotEmitValue()

      self.scheduler.advance()

      self.rewardReceivedViewControllerViewIsHidden.assertValues([true])
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

    let mockService1 = MockService(
      fetchManagePledgeViewBackingResult: .success(initialBackingEnvelope),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService1) {
      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.configurePaymentMethodView.assertDidNotEmitValue()
      self.configurePledgeSummaryView.assertDidNotEmitValue()
      self.configureRewardSummaryViewProject.assertDidNotEmitValue()
      self.configureRewardSummaryViewReward.assertDidNotEmitValue()
      self.configureRewardReceivedWithProject.assertDidNotEmitValue()
      self.title.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.configurePaymentMethodView.assertValues([pledgePaymentMethodViewData])
      self.configurePledgeSummaryView.assertValues([initialPledgeViewSummaryData])

      self.configureRewardSummaryViewProject.assertValues([project])
      self.configureRewardSummaryViewReward.assertValues([.template])
      self.configureRewardReceivedWithProject.assertValues([project])
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

      self.configureRewardSummaryViewProject.assertValues([project, project])
      self.configureRewardSummaryViewReward.assertValues([.template, .template])
      self.configureRewardReceivedWithProject.assertValues([project])
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
      self.rootStackViewHidden.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1, "Refreshing ends after project fails")
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
      self.pullToRefreshStackViewHidden.assertValues([true, false])

      let successMockService = MockService(
        fetchManagePledgeViewBackingResult: .success(.template),
        fetchProjectResponse: .template
      )

      withEnvironment(apiService: successMockService) {
        // User pulls to refresh
        self.vm.inputs.beginRefresh()

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(1)
        self.rootStackViewHidden.assertValues([true])
        self.rightBarButtonItemHidden.assertValues([true])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.pullToRefreshStackViewHidden.assertValues([true, false])

        // Network request completes
        self.scheduler.advance()

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(1, "Does not end refreshing, fetching backing")
        self.rootStackViewHidden.assertValues([true, false])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.pullToRefreshStackViewHidden.assertValues([true, false, true])

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(3, "Ends refreshing for project and backing")
        self.rootStackViewHidden.assertValues([true, false])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.pullToRefreshStackViewHidden.assertValues([true, false, true])
      }
    }
  }

  func testRefreshing_BackingErrorThenSuccess() {
    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .failure(.invalidInput),
      fetchProjectResponse: .template
    )

    withEnvironment(apiService: mockService) {
      self.startRefreshing.assertDidNotEmitValue()
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
      self.pullToRefreshStackViewHidden.assertValues([true, false])

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1)
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
      self.pullToRefreshStackViewHidden.assertValues([true, false])

      let successMockService = MockService(
        fetchManagePledgeViewBackingResult: .success(.template),
        fetchProjectResponse: .template
      )

      withEnvironment(apiService: successMockService) {
        // User pulls to refresh
        self.vm.inputs.beginRefresh()

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(1)
        self.rootStackViewHidden.assertValues([true])
        self.rightBarButtonItemHidden.assertValues([true])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.pullToRefreshStackViewHidden.assertValues([true, false])

        // Network request completes
        self.scheduler.advance()

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(1)
        self.rootStackViewHidden.assertValues([true, false])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.pullToRefreshStackViewHidden.assertValues([true, false, true])

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        self.startRefreshing.assertValueCount(2)
        self.endRefreshing.assertValueCount(2)
        self.rootStackViewHidden.assertValues([true, false])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.pullToRefreshStackViewHidden.assertValues([true, false, true])
      }
    }
  }

  func testRefreshing_BackingSuccessThenError() {
    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: .template
    )

    withEnvironment(apiService: mockService) {
      self.startRefreshing.assertDidNotEmitValue()
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1)
      self.rootStackViewHidden.assertValues([true, false])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // Pledge view completed a change
      self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Updated")

      self.startRefreshing.assertValueCount(2)
      self.endRefreshing.assertValueCount(1)
      self.rootStackViewHidden.assertValues([true, false])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(2)
      self.endRefreshing.assertValueCount(1)
      self.rootStackViewHidden.assertValues([true, false])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(2)
      self.endRefreshing.assertValueCount(2)
      self.rootStackViewHidden.assertValues([true, false])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // User pulls to refresh
      self.vm.inputs.beginRefresh()

      // Network request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(3)
      self.endRefreshing.assertValueCount(2)
      self.rootStackViewHidden.assertValues([true, false])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(3)
      self.endRefreshing.assertValueCount(3)
      self.rootStackViewHidden.assertValues([true, false])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      let failureMockService = MockService(
        fetchManagePledgeViewBackingResult: .failure(.invalidInput),
        fetchProjectResponse: .template
      )

      withEnvironment(apiService: failureMockService) {
        // User pulls to refresh
        self.vm.inputs.beginRefresh()

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(3)
        self.rootStackViewHidden.assertValues([true, false])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertDidNotEmitValue()
        self.pullToRefreshStackViewHidden.assertValues([true])

        // Network request completes
        self.scheduler.advance()

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(3)
        self.rootStackViewHidden.assertValues([true, false])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.pullToRefreshStackViewHidden.assertValues([true])

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(4, "End refresh on errors")
        self.rootStackViewHidden.assertValues([true, false])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.pullToRefreshStackViewHidden.assertValues([true])
      }
    }
  }

  func testRefreshing_ProjectId_NilBackingId() {
    let project = Project.template
      |> Project.lens.personalization.backing .~ .template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResponse: project
    )

    withEnvironment(apiService: mockService) {
      self.startRefreshing.assertDidNotEmitValue()
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertDidNotEmitValue()
      self.rightBarButtonItemHidden.assertDidNotEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), nil))
      self.vm.inputs.viewDidLoad()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // Project request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // Backing request completes
      self.scheduler.advance()

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertDidNotEmitValue()
      self.rootStackViewHidden.assertValues([true])
      self.rightBarButtonItemHidden.assertValues([true])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(1)
      self.endRefreshing.assertValueCount(1)
      self.rootStackViewHidden.assertValues([true, false])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.pullToRefreshStackViewHidden.assertValues([true])
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
}
