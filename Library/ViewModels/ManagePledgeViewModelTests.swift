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
  private let configurePlotPaymentScheduleView = TestObserver<[PledgePaymentIncrement], Never>()
  private let endRefreshing = TestObserver<Void, Never>()
  private let goToCancelPledge = TestObserver<CancelPledgeViewData, Never>()
  private let goToChangePaymentMethod = TestObserver<PledgeViewData, Never>()
  private let goToContactCreatorSubject = TestObserver<MessageSubject, Never>()
  private let goToContactCreatorContext = TestObserver<KSRAnalytics.MessageDialogContext, Never>()
  private let goToFixPaymentMethod = TestObserver<PledgeViewData, Never>()
  private let goToRewards = TestObserver<Project, Never>()
  private let loadProjectAndRewardsIntoDataSourceProject = TestObserver<Project, Never>()
  private let loadProjectAndRewardsIntoDataSourceReward = TestObserver<[Reward], Never>()
  private let loadPullToRefreshHeaderView = TestObserver<(), Never>()
  private let notifyDelegateManagePledgeViewControllerFinishedWithMessage
    = TestObserver<String?, Never>()
  private let paymentMethodViewHidden = TestObserver<Bool, Never>()
  private let pledgeDetailsSectionLabelText = TestObserver<String, Never>()
  private let plotPaymentScheduleViewHidden = TestObserver<Bool, Never>()
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
    self.vm.outputs.loadProjectAndRewardsIntoDataSource.map(first)
      .observe(self.loadProjectAndRewardsIntoDataSourceProject.observer)
    self.vm.outputs.loadProjectAndRewardsIntoDataSource.map(second)
      .observe(self.loadProjectAndRewardsIntoDataSourceReward.observer)
    self.vm.outputs.loadPullToRefreshHeaderView.observe(self.loadPullToRefreshHeaderView.observer)
    self.vm.outputs.endRefreshing.observe(self.endRefreshing.observer)
    self.vm.outputs.goToCancelPledge.observe(self.goToCancelPledge.observer)
    self.vm.outputs.goToChangePaymentMethod.observe(self.goToChangePaymentMethod.observer)
    self.vm.outputs.goToContactCreator.map(first).observe(self.goToContactCreatorSubject.observer)
    self.vm.outputs.goToContactCreator.map(second).observe(self.goToContactCreatorContext.observer)
    self.vm.outputs.goToFixPaymentMethod.observe(self.goToFixPaymentMethod.observer)
    self.vm.outputs.goToRewards.observe(self.goToRewards.observer)
    self.vm.outputs.notifyDelegateManagePledgeViewControllerFinishedWithMessage
      .observe(self.notifyDelegateManagePledgeViewControllerFinishedWithMessage.observer)
    self.vm.outputs.paymentMethodViewHidden.observe(self.paymentMethodViewHidden.observer)
    self.vm.outputs.pledgeDetailsSectionLabelText.observe(self.pledgeDetailsSectionLabelText.observer)
    self.vm.outputs.rightBarButtonItemHidden.observe(self.rightBarButtonItemHidden.observer)
    self.vm.outputs.showActionSheetMenuWithOptions.observe(self.showActionSheetMenuWithOptions.observer)
    self.vm.outputs.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)
    self.vm.outputs.showSuccessBannerWithMessage.observe(self.showSuccessBannerWithMessage.observer)
    self.vm.outputs.startRefreshing.observe(self.startRefreshing.observer)

    self.vm.outputs.configurePlotPaymentScheduleView.observe(self.configurePlotPaymentScheduleView.observer)
    self.vm.outputs.plotPaymentScheduleViewHidden.observe(self.plotPaymentScheduleViewHidden.observer)
  }

  func testNavigationBarTitle_LiveProject() {
    self.title.assertDidNotEmitValue()

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(.template),
      fetchProjectRewardsResult: .success([.template])
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

    let envelope = ProjectAndBackingEnvelope.template
      |> \.project.state .~ .successful

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResult: .success(finishedProject),
      fetchProjectRewardsResult: .success([.template])
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

    let envelope = ProjectAndBackingEnvelope.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    let pledgePaymentMethodViewData = ManagePledgePaymentMethodViewData(
      backingState: .pledged,
      expirationDate: "2019-09-30",
      lastFour: "1111",
      creditCardType: .visa,
      paymentType: .creditCard,
      isPledgeOverTime: false
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
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us

    let envelope = ProjectAndBackingEnvelope.template
      |> \.project .~ Project.template
      |> \.backing .~ (Backing.template |> Backing.lens.addOns .~ nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    let pledgeViewSummaryData = ManagePledgeSummaryViewData(
      backerId: envelope.backing.backer?.id ?? 0,
      backerName: envelope.backing.backer?.name ?? "",
      backerSequence: envelope.backing.sequence,
      backingState: Backing.Status.pledged,
      bonusAmount: 0.0,
      currentUserIsCreatorOfProject: false,
      isNoReward: false,
      locationName: "United States",
      needsConversion: true,
      omitUSCurrencyCode: true,
      pledgeAmount: envelope.backing.amount,
      pledgedOn: envelope.backing.pledgedAt,
      currencyCode: Project.Country.mx.currencyCode,
      projectDeadline: 1_476_657_315.0,
      projectState: Project.State.live,
      rewardMinimum: 10.0,
      rewardReceivedViewControllerViewIsHidden: false,
      rewardReceivedWithData: .init(
        project: .template,
        backerCompleted: true,
        estimatedDeliveryOn: 1_506_897_315.0,
        backingState: .pledged,
        estimatedShipping: nil,
        pledgeDisclaimerViewHidden: false
      ),
      shippingAmount: envelope.backing.shippingAmount.flatMap(Double.init),
      shippingAmountHidden: true,
      rewardIsLocalPickup: false,
      paymentIncrements: [],
      project: project
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

    let env = ProjectAndBackingEnvelope.template
      |> \.backing .~ (.template |> Backing.lens.addOns .~ nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadProjectAndRewardsIntoDataSourceProject.assertValue(project)
      self.loadProjectAndRewardsIntoDataSourceReward.assertValue([Reward.template])
    }
  }

  func testMenuButtonTapped_WhenProject_IsLive() {
    let project = Project.template
      |> Project.lens.state .~ .live

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([
        [
          ManagePledgeAlertAction.changePaymentMethod,
          ManagePledgeAlertAction.chooseAnotherReward,
          ManagePledgeAlertAction.contactCreator,
          ManagePledgeAlertAction.cancelPledge
        ]
      ])
    }
  }

  func testMenuButtonTapped_WhenProject_IsLive_doesNotInclude_updatePledge() {
    let project = Project.template
      |> Project.lens.state .~ .live

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([
        [
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
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
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
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
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

    let env = ProjectAndBackingEnvelope.template
      |> \.backing .~ (Backing.template |> Backing.lens.status .~ .preauth)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
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

    let env = ProjectAndBackingEnvelope.template
      |> \.backing .~ (Backing.template |> Backing.lens.status .~ .preauth)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
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

  func testMenuButtonTapped_WhenProject_IsEditPledgeOverTime_doesNotInclude_chooseAnotherReward_includes_EditPledge(
  ) {
    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.isPledgeOverTimeAllowed .~ true

    let backing = Backing.templatePlot

    let projectAndBacking = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndBacking),
      fetchProjectResult: .success(project),
      fetchProjectRewardsAndPledgeOverTimeDataResult: .success(
        RewardsAndPledgeOverTimeEnvelope.template
      )
    )

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true,
      RemoteConfigFeature.editPledgeOverTimeEnabled.rawValue: true
    ]

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([
        [
          ManagePledgeAlertAction.changePaymentMethod,
          ManagePledgeAlertAction.editPledgeOverTimePledge,
          ManagePledgeAlertAction.contactCreator,
          ManagePledgeAlertAction.cancelPledge
        ]
      ])
    }
  }

  func testMenuButtonTapped_WhenProject_IsPledgeOverTime_doesNotInclude_chooseAnotherReward_Or_editPledge_WhenEditPledgeOverTimeFeatureFlag_isFalse(
  ) {
    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.isPledgeOverTimeAllowed .~ true

    let backing = Backing.templatePlot

    let projectAndBacking = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndBacking),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true,
      RemoteConfigFeature.editPledgeOverTimeEnabled.rawValue: false
    ]

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([
        [
          ManagePledgeAlertAction.changePaymentMethod,
          ManagePledgeAlertAction.contactCreator,
          ManagePledgeAlertAction.cancelPledge
        ]
      ])
    }
  }

  func testMenuButtonTapped_WhenProject_IsPledgeOverTime_Includes_editPledge_WhenProjectIsPLOTAllowed_IsTrue(
  ) {
    let project = Project.template
      |> Project.lens.state .~ .live
      |> Project.lens.isPledgeOverTimeAllowed .~ true

    let backing = Backing.templatePlot

    let projectAndBacking = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndBacking),
      fetchProjectResult: .success(project),
      fetchProjectRewardsAndPledgeOverTimeDataResult: .success(
        RewardsAndPledgeOverTimeEnvelope.template
      )
    )

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true,
      RemoteConfigFeature.editPledgeOverTimeEnabled.rawValue: true
    ]

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showActionSheetMenuWithOptions.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()

      self.showActionSheetMenuWithOptions.assertValues([
        [
          ManagePledgeAlertAction.changePaymentMethod,
          ManagePledgeAlertAction.editPledgeOverTimePledge,
          ManagePledgeAlertAction.contactCreator,
          ManagePledgeAlertAction.cancelPledge
        ]
      ])
    }
  }

  func testGoToCancelPledge() {
    let project = Project.template

    let envelope = ProjectAndBackingEnvelope.template

    let expectedId = envelope.backing.graphID
    let expectedAmount = envelope.backing.amount

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
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
    let envelope = ProjectAndBackingEnvelope.template
      |> \.backing .~ (Backing.template |> Backing.lens.cancelable .~ false)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(envelope),
      fetchProjectResult: .success(.template),
      fetchProjectRewardsResult: .success([.template])
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
    let reward = Reward.template

    let project = Project.template

    let env = ProjectAndBackingEnvelope.template
      |> \.backing .~ (
        Backing.template
          |> Backing.lens.locationId .~ nil
          |> Backing.lens.addOns .~ nil
      )

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToChangePaymentMethod.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .changePaymentMethod)

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: nil,
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .changePaymentMethod
      )

      self.goToChangePaymentMethod.assertValues([data])
    }
  }

  func testGoToContactCreator() {
    let project = Project.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToContactCreatorSubject.assertDidNotEmitValue()
      self.goToContactCreatorContext.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .contactCreator)

      self.goToContactCreatorSubject.assertValues([.project(id: project.id, name: project.name)])
      self.goToContactCreatorContext.assertValues([.backerModal])
    }
  }

  func testGoToRewards() {
    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(.template),
      fetchProjectRewardsResult: .success([.template])
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

  func testGoToRewards_WithRewardDataIncludingLocalPickup_Success() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.localPickup .~ .canada
      |> Reward.lens.shipping.preference .~ .local

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.goToRewards.assertDidNotEmitValue()

      self.vm.inputs.menuButtonTapped()
      self.vm.inputs.menuOptionSelected(with: .chooseAnotherReward)

      self.goToRewards.assertValues([Project.template])
      XCTAssertNotNil(self.goToRewards.lastValue?.rewards.first?.localPickup)
      XCTAssertEqual(
        self.goToRewards.lastValue?.rewards.first?.localPickup,
        .canada
      )
    }
  }

  func testNotifyDelegateManagePledgeViewControllerFinishedWithMessage_CancellingPledge() {
    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(.template),
      fetchProjectRewardsResult: .success([.template])
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
      fetchProjectResult: .success(.template),
      fetchProjectRewardsResult: .success([.template])
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
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us

    let backing = Backing.template
      |> Backing.lens.locationId .~ nil
      |> Backing.lens.addOns .~ nil
      |> Backing.lens.reward .~ .noReward

    let envelope = ProjectAndBackingEnvelope.template
      |> \.backing .~ backing

    // Pledge amount 25
    let initialPledgeViewSummaryData = ManagePledgeSummaryViewData(
      backerId: envelope.backing.backer?.id ?? 0,
      backerName: envelope.backing.backer?.name ?? "",
      backerSequence: envelope.backing.sequence,
      backingState: Backing.Status.pledged,
      bonusAmount: 0.0,
      currentUserIsCreatorOfProject: false,
      isNoReward: true,
      locationName: "United States",
      needsConversion: true,
      omitUSCurrencyCode: true,
      pledgeAmount: 25,
      pledgedOn: envelope.backing.pledgedAt,
      currencyCode: Project.Country.mx.currencyCode,
      projectDeadline: 1_476_657_315.0,
      projectState: Project.State.live,
      rewardMinimum: 0,
      rewardReceivedViewControllerViewIsHidden: true,
      rewardReceivedWithData: .init(
        project: project,
        backerCompleted: true,
        estimatedDeliveryOn: 0.0,
        backingState: .pledged,
        estimatedShipping: nil,
        pledgeDisclaimerViewHidden: true
      ),
      shippingAmount: envelope.backing.shippingAmount.flatMap(Double.init),
      shippingAmountHidden: true,
      rewardIsLocalPickup: false,
      paymentIncrements: [],
      project: project
    )

    // Pledge amount 50
    let updatedPledgeViewSummaryData = ManagePledgeSummaryViewData(
      backerId: envelope.backing.backer?.id ?? 0,
      backerName: envelope.backing.backer?.name ?? "",
      backerSequence: envelope.backing.sequence,
      backingState: Backing.Status.pledged,
      bonusAmount: 0.0,
      currentUserIsCreatorOfProject: false,
      isNoReward: true,
      locationName: "United States",
      needsConversion: true,
      omitUSCurrencyCode: true,
      pledgeAmount: 50,
      pledgedOn: envelope.backing.pledgedAt,
      currencyCode: Project.Country.mx.currencyCode,
      projectDeadline: 1_476_657_315.0,
      projectState: Project.State.live,
      rewardMinimum: 0,
      rewardReceivedViewControllerViewIsHidden: false,
      rewardReceivedWithData: .init(
        project: project,
        backerCompleted: true,
        estimatedDeliveryOn: 1_506_897_315.0,
        backingState: .pledged,
        estimatedShipping: nil,
        pledgeDisclaimerViewHidden: true
      ),
      shippingAmount: envelope.backing.shippingAmount.flatMap(Double.init),
      shippingAmountHidden: true,
      rewardIsLocalPickup: false,
      paymentIncrements: [],
      project: project
    )

    let pledgePaymentMethodViewData = ManagePledgePaymentMethodViewData(
      backingState: .pledged,
      expirationDate: "2019-09-30",
      lastFour: "1111",
      creditCardType: .visa,
      paymentType: .creditCard,
      isPledgeOverTime: false
    )

    let initialBackingEnvelope = envelope
      |> \.backing .~ (backing |> Backing.lens.amount .~ 25)
    let updatedBackingEnvelope = initialBackingEnvelope
      |> \.backing .~ (backing |> Backing.lens.amount .~ 50)

    let mockService1 = MockService(
      fetchManagePledgeViewBackingResult: .success(initialBackingEnvelope),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    let expectedRewardReceivedData = ManageViewPledgeRewardReceivedViewData(
      project: project,
      backerCompleted: true,
      estimatedDeliveryOn: 0,
      backingState: .pledged,
      estimatedShipping: nil,
      pledgeDisclaimerViewHidden: true
    )

    withEnvironment(apiService: mockService1) {
      self.showSuccessBannerWithMessage.assertDidNotEmitValue()
      self.configurePaymentMethodView.assertDidNotEmitValue()
      self.configurePledgeSummaryView.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceProject.assertDidNotEmitValue()
      self.loadProjectAndRewardsIntoDataSourceReward.assertDidNotEmitValue()
      self.title.assertDidNotEmitValue()

      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.configurePaymentMethodView.assertValues([pledgePaymentMethodViewData])
      self.configurePledgeSummaryView.assertValues([initialPledgeViewSummaryData])

      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[.noReward]])
      self.title.assertValues(["Manage your pledge"])
    }

    let mockService2 = MockService(
      fetchManagePledgeViewBackingResult: .success(updatedBackingEnvelope),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService2) {
      self.vm.inputs.pledgeViewControllerDidUpdatePledgeWithMessage("Got it! Your changes have been saved.")

      self.scheduler.run()

      self.showSuccessBannerWithMessage.assertValues(["Got it! Your changes have been saved."])

      self.configurePaymentMethodView.assertValues([
        pledgePaymentMethodViewData,
        pledgePaymentMethodViewData
      ])

      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project, project, project, project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
        [.noReward], [.noReward], [.noReward], [.noReward]
      ])

      let rewardReceivedWithData = self.configurePledgeSummaryView.values.map { $0.rewardReceivedWithData }

      XCTAssertEqual([rewardReceivedWithData.last], [expectedRewardReceivedData])

      self.title.assertValues(["Manage your pledge", "Manage your pledge", "Manage your pledge"])
    }
  }

  func testFixPaymentTrackingEvents() {
    let project = Project.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

      self.vm.inputs.fixButtonTapped()

      XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)
    }
  }

  func testRefreshing_ProjectErrorThenSuccess() {
    let mockService = MockService(
      fetchProjectResult: .failure(.couldNotParseJSON),
      fetchProjectRewardsResult: .success([.template])
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
        |> \.rewardData.rewards .~ [reward]

      let env = ProjectAndBackingEnvelope.template
        |> \.backing .~ (.template |> Backing.lens.addOns .~ nil)

      let successMockService = MockService(
        fetchManagePledgeViewBackingResult: .success(env),
        fetchProjectResult: .success(project),
        fetchProjectRewardsResult: .success([reward])
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

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .failure(.couldNotParseJSON),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
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

      let env = ProjectAndBackingEnvelope.template
        |> \.backing .~ (.template |> Backing.lens.addOns .~ nil)

      let successMockService = MockService(
        fetchManagePledgeViewBackingResult: .success(env),
        fetchProjectResult: .success(project),
        fetchProjectRewardsResult: .success([reward])
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

    let env = ProjectAndBackingEnvelope.template
      |> \.backing .~ (.template |> Backing.lens.addOns .~ nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
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
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project, project, project, project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward], [reward], [reward], [reward]])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(2)
      self.endRefreshing.assertValueCount(2)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues([project, project, project, project])
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([[reward], [reward], [reward], [reward]])
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
        [project, project, project, project, project, project, project]
      )
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
        [reward], [reward], [reward], [reward], [reward], [reward], [reward]
      ])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      // endRefreshing is delayed by 300ms for animation duration
      self.scheduler.advance(by: .milliseconds(300))

      self.startRefreshing.assertValueCount(3)
      self.endRefreshing.assertValueCount(3)
      self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
        [project, project, project, project, project, project, project]
      )
      self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
        [reward], [reward], [reward], [reward], [reward], [reward], [reward]
      ])
      self.rightBarButtonItemHidden.assertValues([true, false])
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
      self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

      let failureMockService = MockService(
        fetchManagePledgeViewBackingResult: .failure(.couldNotParseJSON),
        fetchProjectResult: .success(project),
        fetchProjectRewardsResult: .success([reward])
      )

      withEnvironment(apiService: failureMockService) {
        // User pulls to refresh
        self.vm.inputs.beginRefresh()

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(3)
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
          [project, project, project, project, project, project, project]
        )
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
          [reward], [reward], [reward], [reward], [reward], [reward], [reward]
        ])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertDidNotEmitValue()
        self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

        // Network request completes
        self.scheduler.advance()

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(3)
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
          [project, project, project, project, project, project, project]
        )
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
          [reward], [reward], [reward], [reward], [reward], [reward], [reward]
        ])
        self.rightBarButtonItemHidden.assertValues([true, false])
        self.showErrorBannerWithMessage.assertValues(["Something went wrong, please try again."])
        self.loadPullToRefreshHeaderView.assertDidNotEmitValue()

        // endRefreshing is delayed by 300ms for animation duration
        self.scheduler.advance(by: .milliseconds(300))

        self.startRefreshing.assertValueCount(4)
        self.endRefreshing.assertValueCount(4, "End refresh on errors")
        self.loadProjectAndRewardsIntoDataSourceProject.assertValues(
          [project, project, project, project, project, project, project]
        )
        self.loadProjectAndRewardsIntoDataSourceReward.assertValues([
          [reward], [reward], [reward], [reward], [reward], [reward], [reward]
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

    let env = ProjectAndBackingEnvelope.template
      |> \.backing .~ (.template |> Backing.lens.addOns .~ nil)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
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
    self.goToFixPaymentMethod.assertDidNotEmitValue()

    let reward = Project.cosmicSurgery.rewards.filter { $0.id == Backing.template.rewardId }.first!

    let project = Project.cosmicSurgery

    let env = ProjectAndBackingEnvelope.template
      |> \.backing .~ (
        Backing.template
          |> Backing.lens.locationId .~ nil
          |> Backing.lens.addOns .~ nil
      )

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([reward])
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.fixButtonTapped()

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: nil,
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .fixPaymentMethod
      )

      self.goToFixPaymentMethod.assertValues([data])
    }
  }

  func testPaymentMethodViewHidden_UserIsCreatorOfProject() {
    self.paymentMethodViewHidden.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
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
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.paymentMethodViewHidden.assertDidNotEmitValue()

      self.scheduler.advance()

      self.paymentMethodViewHidden.assertValues([false])
    }
  }

  func testPledgeDetailsSectionLabelText_UserIsNotCreatorOfProject() {
    self.pledgeDetailsSectionLabelText.assertDidNotEmitValue()

    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (user |> User.lens.id .~ 999)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
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
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.pledgeDetailsSectionLabelText.assertDidNotEmitValue()

      self.scheduler.advance()

      self.pledgeDetailsSectionLabelText.assertValues(["Pledge details"])
    }
  }

  func testPlotPaymentScheduleView_IsHiddenWhenThereIsNoPaymentIncrements() {
    self.pledgeDetailsSectionLabelText.assertDidNotEmitValue()

    let project = Project.template
      |> Project.lens.state .~ .live

    let backing = Backing.template

    let projectAndBacking = ProjectAndBackingEnvelope(project: project, backing: backing)

    let user = User.template

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndBacking),
      fetchProjectResult: .success(project)
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.plotPaymentScheduleViewHidden.assertValue(true)
      self.configurePlotPaymentScheduleView.assertDidNotEmitValue()
    }
  }

  func testPledgeDisclaimerViewHidden_Shipping_UserIsCreatorOfProject() {
    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      guard let pledgeDisclaimerViewHidden = self.configurePledgeSummaryView.lastValue?.rewardReceivedWithData
        .pledgeDisclaimerViewHidden else {
        XCTAssertNil("configurePledgeSummaryView should not be nil.")
        return
      }

      XCTAssertTrue(pledgeDisclaimerViewHidden)
    }
  }

  func testPledgeDisclaimerViewHidden_NoShipping_UserIsNotCreatorOfProject() {
    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (user |> User.lens.id .~ 999)
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.noReward
          |> Backing.lens.rewardId .~ Reward.noReward.id
      )
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us

    let addOn = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ nil

    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ nil

    let backing = Backing.template
      |> Backing.lens.reward .~ reward
      |> Backing.lens.addOns .~ [addOn]

    let env = ProjectAndBackingEnvelope.template
      |> \.backing .~ backing

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(env),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template |> Reward.lens.estimatedDeliveryOn .~ nil])
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()
      self.scheduler.advance(by: .milliseconds(300))

      guard let pledgeDisclaimerViewHidden = self.configurePledgeSummaryView.lastValue?.rewardReceivedWithData
        .pledgeDisclaimerViewHidden else {
        XCTAssertNil("configurePledgeSummaryView should not be nil.")
        return
      }

      XCTAssertTrue(pledgeDisclaimerViewHidden)
    }
  }

  func testPledgeDisclaimerViewHidden_Shipping_UserIsNotCreatorOfProject() {
    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ (user |> User.lens.id .~ 999)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(.template),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      guard let pledgeDisclaimerViewHidden = self.configurePledgeSummaryView.lastValue?.rewardReceivedWithData
        .pledgeDisclaimerViewHidden else {
        XCTAssertNil("configurePledgeSummaryView should not be nil.")
        return
      }

      XCTAssertFalse(pledgeDisclaimerViewHidden)
    }
  }

  func testPlotPaymentScheduleView_IsVisibleWhenFeatureFlagIsEnabled() {
    let user = User.template

    let project = Project.cosmicSurgery
      |> Project.lens.creator .~ user

    let backing = Backing.templatePlot

    let projectAndBacking = ProjectAndBackingEnvelope(project: project, backing: backing)

    let mockService = MockService(
      fetchManagePledgeViewBackingResult: .success(projectAndBacking),
      fetchProjectResult: .success(project),
      fetchProjectRewardsResult: .success([.template])
    )

    withEnvironment(apiService: mockService, currentUser: user) {
      self.vm.inputs.configureWith((Param.slug("project-slug"), Param.id(1)))
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.plotPaymentScheduleViewHidden.assertValue(false)
      self.configurePlotPaymentScheduleView.assertDidEmitValue()
    }
  }
}
