import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public typealias ManagePledgeViewParamConfigData = (
  projectParam: Param,
  backingParam: Param?
)

public enum ManagePledgeAlertAction: CaseIterable {
  case editPledgeOverTimePledge
  case changePaymentMethod
  case chooseAnotherReward
  case contactCreator
  case cancelPledge
  case viewRewards
}

public protocol ManagePledgeViewModelInputs {
  func beginRefresh()
  func configureWith(_ params: ManagePledgeViewParamConfigData)
  func cancelPledgeDidFinish(with message: String)
  func fixButtonTapped()
  func menuButtonTapped()
  func menuOptionSelected(with action: ManagePledgeAlertAction)
  func pledgeViewControllerDidUpdatePledgeWithMessage(_ message: String)
  func viewDidLoad()
  func termsOfUseTapped(with helpType: HelpType)
}

public protocol ManagePledgeViewModelOutputs {
  var configurePaymentMethodView: Signal<ManagePledgePaymentMethodViewData, Never> { get }
  var configurePledgeSummaryView: Signal<ManagePledgeSummaryViewData, Never> { get }
  var endRefreshing: Signal<Void, Never> { get }
  var goToCancelPledge: Signal<CancelPledgeViewData, Never> { get }
  var goToChangePaymentMethod: Signal<PledgeViewData, Never> { get }
  var goToContactCreator: Signal<(MessageSubject, KSRAnalytics.MessageDialogContext), Never> { get }
  var goToFixPaymentMethod: Signal<PledgeViewData, Never> { get }
  var goToRewards: Signal<Project, Never> { get }
  var goToEditPledgeOverTime: Signal<Project, Never> { get }
  var loadProjectAndRewardsIntoDataSource: Signal<(Project, [Reward]), Never> { get }
  var loadPullToRefreshHeaderView: Signal<(), Never> { get }
  var notifyDelegateManagePledgeViewControllerFinishedWithMessage: Signal<String?, Never> { get }
  var paymentMethodViewHidden: Signal<Bool, Never> { get }
  var pledgeDetailsSectionLabelText: Signal<String, Never> { get }
  var rightBarButtonItemHidden: Signal<Bool, Never> { get }
  var showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never> { get }
  var showErrorBannerWithMessage: Signal<String, Never> { get }
  var showSuccessBannerWithMessage: Signal<String, Never> { get }
  var showWebHelp: Signal<HelpType, Never> { get }
  var startRefreshing: Signal<(), Never> { get }
  var title: Signal<String, Never> { get }
  var configurePlotPaymentScheduleView: Signal<[PledgePaymentIncrement], Never> { get }
  var plotPaymentScheduleViewHidden: Signal<Bool, Never> { get }
}

public protocol ManagePledgeViewModelType {
  var inputs: ManagePledgeViewModelInputs { get }
  var outputs: ManagePledgeViewModelOutputs { get }
}

public final class ManagePledgeViewModel:
  ManagePledgeViewModelType, ManagePledgeViewModelInputs, ManagePledgeViewModelOutputs {
  public init() {
    let params = Signal.combineLatest(
      self.configureWithProjectOrParamSignal,
      self.viewDidLoadSignal
    )
    .map(first)

    let projectParam = params.map(first)

    let shouldBeginRefresh = Signal.merge(
      self.pledgeViewControllerDidUpdatePledgeWithMessageSignal.ignoreValues(),
      self.beginRefreshSignal
    )

    // Keep track of whether the project has successfully loaded at least once.
    let projectLoaded = MutableProperty<Bool>(false)

    let shouldFetchProjectWithParam = Signal.merge(
      projectParam,
      projectParam.takeWhen(shouldBeginRefresh)
    )

    let fetchProjectEvent = shouldFetchProjectWithParam
      // Only fetch the project if it hasn't yet succeeded, to avoid this call occurring with each refresh.
      .filter { [projectLoaded] _ in projectLoaded.value == false }
      .switchMap { param in
        AppEnvironment.current.apiService.fetchProject(param: param)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .switchMap { project in
            // Only fetch pledge over time data if the feature flag is enabled
            if featureEditPledgeOverTimeEnabled() {
              return fetchProjectRewardsAndPledgeOverTimeData(project: project)
            }

            return fetchProjectRewards(project: project)
          }
          .materialize()
      }

    let initialProject = fetchProjectEvent.values()
      // Once we know we have a project value, keep track of that.
      .on(value: { [projectLoaded] _ in projectLoaded.value = true })

    let backingParamFromConfigData = params.map(second)
      .skipNil()
    let backingParamFromProject = initialProject.map { $0.personalization.backing?.id }
      .skipNil()
      .map(Param.id)

    let backingParam = Signal.merge(
      backingParamFromConfigData,
      backingParamFromProject
        .take(until: backingParamFromConfigData.ignoreValues())
    )

    let shouldFetchGraphBackingWithParam = Signal.merge(
      backingParam,
      backingParam.takeWhen(shouldBeginRefresh)
    )

    let graphBackingEvent = shouldFetchGraphBackingWithParam
      .map { param in param.id }
      .skipNil()
      .switchMap { backingId in
        AppEnvironment.current.apiService
          .fetchBacking(id: backingId, withStoredCards: false)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let graphBackingProject = graphBackingEvent.values()
      .map { $0.project }

    let graphBackingEnvelope = graphBackingEvent.values()

    let backing = graphBackingEnvelope
      .map { $0.backing }

    let endRefreshingWhenProjectFailed = fetchProjectEvent.errors()
      .ignoreValues()

    let endRefreshingWhenBackingCompleted = graphBackingEvent
      .filter { $0.isTerminating }
      .ksr_delay(.milliseconds(300), on: AppEnvironment.current.scheduler)
      .ignoreValues()

    self.endRefreshing = Signal.merge(
      endRefreshingWhenProjectFailed,
      endRefreshingWhenBackingCompleted
    )
    .ignoreValues()

    let project: Signal<Project, Never> = initialProject.combineLatest(with: backing)
      .map { project, backing -> Project in
        /**
         Here we are updating the `Project`'s `Backing` with an updated one from GraphQL.
         This is because, at the time of writing, v1 does not return add-ons or bonus amount but GraphQL does.
         */
        let p = (project |> Project.lens.personalization.backing .~ backing)
        return p
      }

    let userIsCreatorOfProject = project.map { project in
      currentUserIsCreator(of: project)
    }

    let projectAndReward = Signal.combineLatest(project, backing)
      .compactMap { project, backing -> (Project, Reward)? in
        guard let reward = backing.reward else { return (project, .noReward) }

        return (project, reward)
      }

    self.title = graphBackingProject.combineLatest(with: userIsCreatorOfProject)
      .map(navigationBarTitle(with:userIsCreatorOfProject:))

    self.configurePaymentMethodView = backing.map(managePledgePaymentMethodViewData)

    let projectOrBackingFailedToLoad = Signal.merge(
      fetchProjectEvent.map { $0.error as Error? },
      graphBackingEvent.map { $0.error as Error? }
    )
    .filter(isNotNil)

    self.loadPullToRefreshHeaderView = projectOrBackingFailedToLoad
      .take(until: backing.ignoreValues())
      .ignoreValues()

    self.paymentMethodViewHidden = Signal.combineLatest(
      userIsCreatorOfProject,
      backing.map { backing in backing.paymentSource }
    )
    .map { userIsCreatorOfProject, creditCard in userIsCreatorOfProject || creditCard == nil }
    .skipRepeats()

    self.loadProjectAndRewardsIntoDataSource = projectAndReward.combineLatest(with: backing)
      .map(unpack)
      .map { project, reward, backing -> (Project, [Reward]) in
        (project, distinctRewards([reward] + (backing.addOns ?? [])))
      }

    self.rightBarButtonItemHidden = Signal.merge(
      params.mapConst(true),
      self.loadPullToRefreshHeaderView.mapConst(true),
      self.loadProjectAndRewardsIntoDataSource.mapConst(false)
    )
    .skipRepeats()

    let pledgeDisclaimerViewHidden = Signal.combineLatest(
      self.loadProjectAndRewardsIntoDataSource,
      userIsCreatorOfProject
    )
    .map(unpack)
    .map { _, rewards, userIsCreatorOfProject in
      rewards.map { $0.estimatedDeliveryOn }.allSatisfy(isNil) || userIsCreatorOfProject
    }

    self.pledgeDetailsSectionLabelText = userIsCreatorOfProject.map {
      $0 ? Strings.Pledge_details() : Strings.Your_pledge_details()
    }

    self.startRefreshing = Signal.merge(
      params.ignoreValues(),
      shouldBeginRefresh.ignoreValues()
    )

    // MARK: - ManageViewPledgeRewardReceivedViewData

    let latestRewardDeliveryDate = self.loadProjectAndRewardsIntoDataSource.map { _, rewards in
      rewards
        .compactMap { $0.estimatedDeliveryOn }
        .reduce(0) { accum, value in max(accum, value) }
    }

    let estimatedShipping = Signal.combineLatest(
      backing,
      self.loadProjectAndRewardsIntoDataSource
    )
    .map(unpack)
    .map { backing, project, rewards -> String? in
      guard let locationId = backing.locationId,
            let range = estimatedShippingText(
              for: rewards,
              project: project,
              locationId: locationId,
              selectedQuantities: selectedRewardQuantities(in: backing)
            )
      else { return nil }

      return Strings.About_reward_amount(reward_amount: range)
    }

    let rewardReceivedWithData = Signal.combineLatest(
      project,
      backing,
      latestRewardDeliveryDate,
      estimatedShipping,
      pledgeDisclaimerViewHidden
    )
    .map { project, backing, latestRewardDeliveryDate, estimatedShipping, pledgeDisclaimerViewHidden in
      ManageViewPledgeRewardReceivedViewData(
        project: project,
        backerCompleted: backing.backerCompleted ?? false,
        estimatedDeliveryOn: latestRewardDeliveryDate,
        backingState: backing.status,
        estimatedShipping: estimatedShipping,
        pledgeDisclaimerViewHidden: pledgeDisclaimerViewHidden
      )
    }

    // MARK: - Menu options

    let menuOptions = Signal.combineLatest(project, backing, userIsCreatorOfProject)
      .map(actionSheetMenuOptionsFor(project:backing:userIsCreatorOfProject:))

    self.showActionSheetMenuWithOptions = menuOptions
      .takeWhen(self.menuButtonTappedSignal)

    let backedRewards = self.loadProjectAndRewardsIntoDataSource.map(second)

    self.goToRewards = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .chooseAnotherReward || $0 == .viewRewards })

    self.goToEditPledgeOverTime = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .editPledgeOverTimePledge })

    let cancelPledgeSelected = self.menuOptionSelectedSignal
      .filter { $0 == .cancelPledge }
      .ignoreValues()

    self.goToCancelPledge = Signal.combineLatest(project, backing)
      .takeWhen(cancelPledgeSelected)
      .filter { _, backing in backing.cancelable }
      .map(cancelPledgeViewData(with:backing:))

    self.goToContactCreator = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .contactCreator })
      .map { project in (MessageSubject.project(id: project.id, name: project.name), .backerModal) }

    self.goToChangePaymentMethod = Signal.combineLatest(project, backing, backedRewards)
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .changePaymentMethod })
      .map { project, backing, rewards in
        (project, backing, rewards, .changePaymentMethod)
      }
      .map(pledgeViewData)

    self.goToFixPaymentMethod = Signal.combineLatest(project, backing, backedRewards)
      .takeWhen(self.fixButtonTappedSignal)
      .map { project, backing, rewards in
        (project, backing, rewards, .fixPaymentMethod)
      }
      .map(pledgeViewData)

    self.notifyDelegateManagePledgeViewControllerFinishedWithMessage = Signal.merge(
      self.cancelPledgeDidFinishWithMessageProperty.signal,
      backing.skip(first: 1).mapConst(nil)
    )

    let rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never> = latestRewardDeliveryDate
      .map { $0 == 0 }

    self.configurePledgeSummaryView = Signal.combineLatest(
      projectAndReward,
      backing,
      rewardReceivedWithData,
      rewardReceivedViewControllerViewIsHidden
    )
    .compactMap(managePledgeSummaryViewData)

    self.showSuccessBannerWithMessage = self.pledgeViewControllerDidUpdatePledgeWithMessageSignal

    let cancelBackingDisallowed = backing
      .map { $0.cancelable }
      .filter(isFalse)

    let attemptedDisallowedCancelBackingMessage = cancelBackingDisallowed
      .takeWhen(cancelPledgeSelected)
      .map { _ in
        // swiftformat:disable wrap
        Strings.We_dont_allow_cancelations_that_will_cause_a_project_to_fall_short_of_its_goal_within_the_last_24_hours()
        // swiftformat:enable wrap
      }

    let networkErrorMessage = Signal.merge(
      fetchProjectEvent.errors().ignoreValues(),
      graphBackingEvent.errors().ignoreValues()
    )
    .map { _ in Strings.Something_went_wrong_please_try_again() }

    self.showErrorBannerWithMessage = Signal.merge(
      attemptedDisallowedCancelBackingMessage,
      networkErrorMessage
    )

    // Tracking

    Signal.zip(self.loadProjectAndRewardsIntoDataSource, backing)
      .map(unpack)
      .observeValues { project, rewards, backing in
        guard let reward = backing.reward else { return }

        let checkoutData = checkoutProperties(
          from: project,
          baseReward: reward,
          addOnRewards: rewards,
          selectedQuantities: selectedRewardQuantities(in: backing),
          additionalPledgeAmount: backing.bonusAmount,
          pledgeTotal: backing.amount,
          shippingTotal: Double(backing.shippingAmount ?? 0),
          isApplePay: backing.paymentSource?.paymentType == .applePay
        )

        AppEnvironment.current.ksrAnalytics.trackManagePledgePageViewed(
          project: project,
          reward: reward,
          checkoutData: checkoutData
        )
      }

    // Pledge Over Time

    let pledgeOverTimeEnabled = backing.map {
      isPledgeOverTime(with: $0)
    }

    self.plotPaymentScheduleViewHidden = pledgeOverTimeEnabled.negate()

    self.configurePlotPaymentScheduleView = backing
      .filterWhenLatestFrom(pledgeOverTimeEnabled, satisfies: { $0 })
      .map { $0.paymentIncrements }

    self.showWebHelp = self.termsOfUseTappedSignal
  }

  private let (beginRefreshSignal, beginRefreshObserver) = Signal<Void, Never>.pipe()
  public func beginRefresh() {
    self.beginRefreshObserver.send(value: ())
  }

  private let (configureWithProjectOrParamSignal, configureWithProjectOrParamObserver)
    = Signal<ManagePledgeViewParamConfigData, Never>.pipe()
  public func configureWith(_ params: ManagePledgeViewParamConfigData) {
    self.configureWithProjectOrParamObserver.send(value: params)
  }

  private let cancelPledgeDidFinishWithMessageProperty = MutableProperty<String?>(nil)
  public func cancelPledgeDidFinish(with message: String) {
    self.cancelPledgeDidFinishWithMessageProperty.value = message
  }

  private let (fixButtonTappedSignal, fixButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func fixButtonTapped() {
    self.fixButtonTappedObserver.send(value: ())
  }

  private let (menuButtonTappedSignal, menuButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func menuButtonTapped() {
    self.menuButtonTappedObserver.send(value: ())
  }

  private let (menuOptionSelectedSignal, menuOptionSelectedObserver) = Signal<ManagePledgeAlertAction, Never>
    .pipe()
  public func menuOptionSelected(with action: ManagePledgeAlertAction) {
    self.menuOptionSelectedObserver.send(value: action)
  }

  private let (termsOfUseTappedSignal, termsOfUseTappedObserver) = Signal<HelpType, Never>.pipe()
  public func termsOfUseTapped(with helpType: HelpType) {
    self.termsOfUseTappedObserver.send(value: helpType)
  }

  private let (
    pledgeViewControllerDidUpdatePledgeWithMessageSignal,
    pledgeViewControllerDidUpdatePledgeWithMessageObserver
  ) = Signal<String, Never>.pipe()
  public func pledgeViewControllerDidUpdatePledgeWithMessage(_ message: String) {
    self.pledgeViewControllerDidUpdatePledgeWithMessageObserver.send(value: message)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let configurePaymentMethodView: Signal<ManagePledgePaymentMethodViewData, Never>
  public let configurePledgeSummaryView: Signal<ManagePledgeSummaryViewData, Never>
  public let configurePlotPaymentScheduleView: Signal<[PledgePaymentIncrement], Never>
  public let endRefreshing: Signal<Void, Never>
  public let goToCancelPledge: Signal<CancelPledgeViewData, Never>
  public let goToChangePaymentMethod: Signal<PledgeViewData, Never>
  public let goToContactCreator: Signal<(MessageSubject, KSRAnalytics.MessageDialogContext), Never>
  public let goToFixPaymentMethod: Signal<PledgeViewData, Never>
  public let goToRewards: Signal<Project, Never>
  public let goToEditPledgeOverTime: Signal<Project, Never>
  public let loadProjectAndRewardsIntoDataSource: Signal<(Project, [Reward]), Never>
  public let loadPullToRefreshHeaderView: Signal<(), Never>
  public let paymentMethodViewHidden: Signal<Bool, Never>
  public let pledgeDetailsSectionLabelText: Signal<String, Never>
  public let plotPaymentScheduleViewHidden: Signal<Bool, Never>
  public let notifyDelegateManagePledgeViewControllerFinishedWithMessage: Signal<String?, Never>
  public let rightBarButtonItemHidden: Signal<Bool, Never>
  public let showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never>
  public let showSuccessBannerWithMessage: Signal<String, Never>
  public let showErrorBannerWithMessage: Signal<String, Never>
  public let showWebHelp: Signal<HelpType, Never>
  public let startRefreshing: Signal<(), Never>
  public let title: Signal<String, Never>

  public var inputs: ManagePledgeViewModelInputs { return self }
  public var outputs: ManagePledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func fetchProjectRewards(project: Project) -> SignalProducer<Project, ErrorEnvelope> {
  return AppEnvironment.current.apiService
    .fetchProjectRewards(projectId: project.id)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .switchMap { projectRewards -> SignalProducer<Project, ErrorEnvelope> in

      let projectUpdated = projectWithUpdatedRewards(project, rewards: projectRewards)

      return SignalProducer(value: projectUpdated)
    }
}

private func fetchProjectRewardsAndPledgeOverTimeData(project: Project)
  -> SignalProducer<Project, ErrorEnvelope> {
  return AppEnvironment.current.apiService
    .fetchProjectRewardsAndPledgeOverTimeData(projectId: project.id)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .switchMap { envelope -> SignalProducer<Project, ErrorEnvelope> in

      var projectUpdated = projectWithUpdatedRewards(project, rewards: envelope.rewards)

      projectUpdated = projectUpdated
        |> Project.lens.isPledgeOverTimeAllowed .~ envelope.isPledgeOverTimeAllowed
        |> Project.lens
        .pledgeOverTimeCollectionPlanChargeExplanation .~ envelope
        .pledgeOverTimeCollectionPlanChargeExplanation
        |> Project.lens
        .pledgeOverTimeCollectionPlanChargedAsNPayments .~ envelope
        .pledgeOverTimeCollectionPlanChargedAsNPayments
        |> Project.lens
        .pledgeOverTimeCollectionPlanShortPitch .~ envelope.pledgeOverTimeCollectionPlanShortPitch
        |> Project.lens.pledgeOverTimeMinimumExplanation .~ envelope.pledgeOverTimeMinimumExplanation

      return SignalProducer(value: projectUpdated)
    }
}

private func projectWithUpdatedRewards(_ project: Project, rewards: [Reward]) -> Project {
  let rewardsIncludingNoReward: [Reward]

  if let noReward = project.rewardData.rewards.first {
    rewardsIncludingNoReward = [noReward] + rewards
  } else {
    rewardsIncludingNoReward = rewards
  }

  return project
    |> Project.lens.rewardData.rewards .~ rewardsIncludingNoReward
}

private func pledgeViewData(
  project: Project,
  backing: Backing,
  rewards: [Reward],
  context: PledgeViewContext
) -> PledgeViewData {
  return PledgeViewData(
    project: project,
    rewards: rewards,
    bonusSupport: nil,
    selectedShippingRule: nil,
    selectedQuantities: selectedRewardQuantities(in: backing),
    selectedLocationId: backing.locationId,
    refTag: nil,
    context: context
  )
}

private func actionSheetMenuOptionsFor(
  project: Project,
  backing: Backing,
  userIsCreatorOfProject: Bool
) -> [ManagePledgeAlertAction] {
  if userIsCreatorOfProject {
    return [.viewRewards]
  }

  guard project.state == .live else {
    return [.viewRewards, .contactCreator]
  }

  if backing.status == .preauth {
    return [.contactCreator]
  }

  var actions = ManagePledgeAlertAction.allCases
    .filter { $0 != .viewRewards && $0 != .editPledgeOverTimePledge }

  /// Enable the 'Edit pledge' option for all PLOT-enabled projects.
  if isPledgeOverTime(with: backing) || project.isPledgeOverTimeAllowed == true {
    actions = actions.filter { $0 != .chooseAnotherReward }

    /// If the Edit Pledge Over Time feature flag is `true`, replace 'Edit reward" with 'Edit pledge'.
    if featureEditPledgeOverTimeEnabled() == true {
      actions.insert(.editPledgeOverTimePledge, at: 1)
    }
  }

  return actions
}

private func navigationBarTitle(
  with project: Project,
  userIsCreatorOfProject: Bool
) -> String {
  if userIsCreatorOfProject {
    return Strings.Pledge_details()
  }

  return project.state == .live ? Strings.Manage_your_pledge() : Strings.Your_pledge()
}

private func managePledgeMenuCTAType(for managePledgeAlertAction: ManagePledgeAlertAction)
  -> KSRAnalytics.ManagePledgeMenuCTAType {
  switch managePledgeAlertAction {
  case .editPledgeOverTimePledge: return .editPledgeOverTimePledge
  case .cancelPledge: return .cancelPledge
  case .changePaymentMethod: return .changePaymentMethod
  case .chooseAnotherReward: return .chooseAnotherReward
  case .contactCreator: return .contactCreator
  case .viewRewards: return .viewRewards
  }
}

private func cancelPledgeViewData(
  with project: Project,
  backing: Backing
) -> CancelPledgeViewData {
  return .init(
    project: project,
    projectName: project.name,
    omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
    backingId: backing.graphID,
    pledgeAmount: backing.amount
  )
}

private func managePledgePaymentMethodViewData(
  with backing: Backing
) -> ManagePledgePaymentMethodViewData {
  ManagePledgePaymentMethodViewData(
    backingState: backing.status,
    expirationDate: backing.paymentSource?.expirationDate,
    lastFour: backing.paymentSource?.lastFour,
    creditCardType: backing.paymentSource?.type,
    paymentType: backing.paymentSource?.paymentType,
    isPledgeOverTime: !backing.paymentIncrements.isEmpty
  )
}

private func isPledgeOverTime(with backing: Backing) -> Bool {
  return !backing.paymentIncrements.isEmpty
}

private func managePledgeSummaryViewData(
  with projectAndReward: (Project, Reward),
  backing: Backing,
  rewardReceivedWithData: ManageViewPledgeRewardReceivedViewData,
  rewardReceivedViewControllerViewIsHidden: Bool
) -> ManagePledgeSummaryViewData? {
  let (project, backedReward) = projectAndReward

  guard let backer = backing.backer,
        let deadline = project.dates.deadline else { return nil }

  let isRewardLocalPickup = isRewardLocalPickup(backing.reward)

  return ManagePledgeSummaryViewData(
    backerId: backer.id,
    backerName: backer.name,
    backerSequence: backing.sequence,
    backingState: backing.status,
    bonusAmount: backing.bonusAmount,
    currentUserIsCreatorOfProject: currentUserIsCreator(of: project),
    isNoReward: backedReward.id == Reward.noReward.id,
    locationName: backing.locationName,
    needsConversion: project.stats.needsConversion,
    omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
    pledgeAmount: backing.amount,
    pledgedOn: backing.pledgedAt,
    currencyCode: project.statsCurrency,
    projectDeadline: deadline,
    projectState: project.state,
    rewardMinimum: backing.rewardsAmount ?? allRewardsTotal(for: backing),
    rewardReceivedViewControllerViewIsHidden: rewardReceivedViewControllerViewIsHidden,
    rewardReceivedWithData: rewardReceivedWithData,
    shippingAmount: backing.shippingAmount.flatMap(Double.init),
    shippingAmountHidden: backing.reward?.shipping.enabled == false || backing.shippingAmount == 0,
    rewardIsLocalPickup: isRewardLocalPickup,
    paymentIncrements: backing.paymentIncrements,
    project: project
  )
}

private func allRewardsTotal(for backing: Backing) -> Double {
  let baseRewardAmount = backing.reward?.minimum ?? 0

  guard let addOns = backing.addOns else { return baseRewardAmount }

  return baseRewardAmount + addOns.reduce(0.0) { total, addOn in total.addingCurrency(addOn.minimum) }
}

private func distinctRewards(_ rewards: [Reward]) -> [Reward] {
  var rewardIds: Set<Int> = []
  return rewards.filter { reward in
    defer { rewardIds.insert(reward.id) }
    return !rewardIds.contains(reward.id)
  }
}
