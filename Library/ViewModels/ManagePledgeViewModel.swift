import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public typealias ManagePledgeViewParamConfigData = (
  projectParam: Param,
  backingParam: Param?
)

public enum ManagePledgeAlertAction: CaseIterable {
  case updatePledge
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
}

public protocol ManagePledgeViewModelOutputs {
  var configurePaymentMethodView: Signal<ManagePledgePaymentMethodViewData, Never> { get }
  var configurePledgeSummaryView: Signal<ManagePledgeSummaryViewData, Never> { get }
  var configureRewardReceivedWithData: Signal<ManageViewPledgeRewardReceivedViewData, Never> { get }
  var endRefreshing: Signal<Void, Never> { get }
  var goToCancelPledge: Signal<CancelPledgeViewData, Never> { get }
  var goToChangePaymentMethod: Signal<(Project, Reward), Never> { get }
  var goToContactCreator: Signal<(MessageSubject, Koala.MessageDialogContext), Never> { get }
  var goToFixPaymentMethod: Signal<(Project, Reward), Never> { get }
  var goToRewards: Signal<Project, Never> { get }
  var goToUpdatePledge: Signal<(Project, Reward), Never> { get }
  var loadProjectAndRewardsIntoDataSource: Signal<(Project, [Reward]), Never> { get }
  var loadPullToRefreshHeaderView: Signal<(), Never> { get }
  var notifyDelegateManagePledgeViewControllerFinishedWithMessage: Signal<String?, Never> { get }
  var paymentMethodViewHidden: Signal<Bool, Never> { get }
  var pledgeDetailsSectionLabelText: Signal<String, Never> { get }
  var pledgeDisclaimerViewHidden: Signal<Bool, Never> { get }
  var rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never> { get }
  var rightBarButtonItemHidden: Signal<Bool, Never> { get }
  var showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never> { get }
  var showErrorBannerWithMessage: Signal<String, Never> { get }
  var showSuccessBannerWithMessage: Signal<String, Never> { get }
  var startRefreshing: Signal<(), Never> { get }
  var title: Signal<String, Never> { get }
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
          .materialize()
      }

    let project = fetchProjectEvent.values()
      // Once we know we have a project value, keep track of that.
      .on(value: { [projectLoaded] _ in projectLoaded.value = true })

    let backingParamFromConfigData = params.map(second)
      .skipNil()
    let backingParamFromProject = project.map { $0.personalization.backing?.id }
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
      .map(String.init)
      .switchMap { backingId in
        AppEnvironment.current.apiService
          .fetchManagePledgeViewBacking(query: managePledgeViewProjectBackingQuery(withBackingId: backingId))
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

    let userIsCreatorOfProject = project.map { project in
      currentUserIsCreator(of: project)
    }

    let projectAndReward = Signal.combineLatest(project, backing)
      .filterMap { project, backing -> (Project, Int)? in
        guard
          let rewardRelayId = backing.reward?.id,
          let rewardId = decompose(id: rewardRelayId)
        else { return (project, Reward.noReward.id) }

        return (project, rewardId)
      }
      .map { project, rewardId in (project, reward(withId: rewardId, inProject: project)) }

    self.title = graphBackingProject.combineLatest(with: userIsCreatorOfProject)
      .map(navigationBarTitle(with:userIsCreatorOfProject:))

    self.configurePaymentMethodView = backing.map(managePledgePaymentMethodViewData)

    self.configurePledgeSummaryView = Signal.combineLatest(projectAndReward, graphBackingEnvelope)
      .map(unpack)
      .filterMap(managePledgeSummaryViewData)

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
      backing.map { backing in backing.creditCard }
    )
    .map { userIsCreatorOfProject, creditCard in userIsCreatorOfProject || creditCard == nil }
    .skipRepeats()

    self.loadProjectAndRewardsIntoDataSource = projectAndReward.combineLatest(with: backing)
      .map(unpack)
      .map { project, reward, backing in
        (project, [reward] + rewardsData(from: backing, with: project))
      }

    self.rightBarButtonItemHidden = Signal.merge(
      params.mapConst(true),
      self.loadPullToRefreshHeaderView.mapConst(true),
      self.loadProjectAndRewardsIntoDataSource.mapConst(false)
    )
    .skipRepeats()

    self.pledgeDisclaimerViewHidden = Signal.combineLatest(
      self.loadProjectAndRewardsIntoDataSource,
      userIsCreatorOfProject
    )
    .map(unpack)
    .map { _, rewards, userIsCreatorOfProject in
      rewards.map { $0.estimatedDeliveryOn }.allSatisfy(isNil) || userIsCreatorOfProject
    }

    self.pledgeDetailsSectionLabelText = userIsCreatorOfProject.map {
      $0
        ? localizedString(key: "Pledge_details", defaultValue: "Pledge details")
        : localizedString(key: "Your_pledge_details", defaultValue: "Your pledge details")
    }

    self.startRefreshing = Signal.merge(
      params.ignoreValues(),
      shouldBeginRefresh.ignoreValues()
    )

    let latestRewardDeliveryDate = self.loadProjectAndRewardsIntoDataSource.map { _, rewards in
      rewards
        .compactMap { $0.estimatedDeliveryOn }
        .reduce(0) { accum, value in max(accum, value) }
    }

    self.configureRewardReceivedWithData = Signal.combineLatest(project, backing, latestRewardDeliveryDate)
      .map { project, backing, latestRewardDeliveryDate in
        ManageViewPledgeRewardReceivedViewData(
          project: project,
          backerCompleted: backing.backerCompleted,
          estimatedDeliveryOn: latestRewardDeliveryDate,
          backingState: backing.status
        )
      }

    let menuOptions = Signal.combineLatest(project, backing, userIsCreatorOfProject)
      .map(actionSheetMenuOptionsFor(project:backing:userIsCreatorOfProject:))

    self.showActionSheetMenuWithOptions = menuOptions
      .takeWhen(self.menuButtonTappedSignal)

    self.goToUpdatePledge = projectAndReward
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .updatePledge })

    self.goToRewards = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .chooseAnotherReward || $0 == .viewRewards })

    let cancelPledgeSelected = self.menuOptionSelectedSignal
      .filter { $0 == .cancelPledge }
      .ignoreValues()

    self.goToCancelPledge = Signal.combineLatest(project, backing)
      .takeWhen(cancelPledgeSelected)
      .filter { _, backing in backing.cancelable }
      .map(cancelPledgeViewData(with:backing:))

    self.goToContactCreator = project
      .takeWhen(self.menuOptionSelectedSignal.filter { $0 == .contactCreator })
      .map { project in (MessageSubject.project(project), .backerModal) }

    let goToChangePaymentMethod = self.menuOptionSelectedSignal
      .filter { $0 == .changePaymentMethod }
      .ignoreValues()

    self.goToChangePaymentMethod = projectAndReward
      .takeWhen(goToChangePaymentMethod)

    self.goToFixPaymentMethod = projectAndReward
      .takeWhen(self.fixButtonTappedSignal)

    self.notifyDelegateManagePledgeViewControllerFinishedWithMessage = Signal.merge(
      self.cancelPledgeDidFinishWithMessageProperty.signal,
      backing.skip(first: 1).mapConst(nil)
    )

    self.rewardReceivedViewControllerViewIsHidden = latestRewardDeliveryDate.map { $0 == 0 }

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

    let managePledgeMenuType: Signal<Koala.ManagePledgeMenuCTAType, Never> = self.menuOptionSelectedSignal
      .map(managePledgeMenuCTAType(for:))

    // Tracking
    project
      .takePairWhen(managePledgeMenuType)
      .observeValues {
        AppEnvironment.current.koala.trackManagePledgeOptionClicked(project: $0, managePledgeMenuCTA: $1)
      }

    project
      .takePairWhen(self.fixButtonTappedSignal)
      .observeValues {
        AppEnvironment.current.koala.trackFixPledgeButtonClicked(project: $0.0)
      }
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
  public let configureRewardReceivedWithData: Signal<ManageViewPledgeRewardReceivedViewData, Never>
  public let endRefreshing: Signal<Void, Never>
  public let goToCancelPledge: Signal<CancelPledgeViewData, Never>
  public let goToChangePaymentMethod: Signal<(Project, Reward), Never>
  public let goToContactCreator: Signal<(MessageSubject, Koala.MessageDialogContext), Never>
  public let goToFixPaymentMethod: Signal<(Project, Reward), Never>
  public let goToRewards: Signal<Project, Never>
  public let goToUpdatePledge: Signal<(Project, Reward), Never>
  public let loadProjectAndRewardsIntoDataSource: Signal<(Project, [Reward]), Never>
  public let loadPullToRefreshHeaderView: Signal<(), Never>
  public let paymentMethodViewHidden: Signal<Bool, Never>
  public let pledgeDetailsSectionLabelText: Signal<String, Never>
  public let pledgeDisclaimerViewHidden: Signal<Bool, Never>
  public let notifyDelegateManagePledgeViewControllerFinishedWithMessage: Signal<String?, Never>
  public let rewardReceivedViewControllerViewIsHidden: Signal<Bool, Never>
  public let rightBarButtonItemHidden: Signal<Bool, Never>
  public let showActionSheetMenuWithOptions: Signal<[ManagePledgeAlertAction], Never>
  public let showSuccessBannerWithMessage: Signal<String, Never>
  public let showErrorBannerWithMessage: Signal<String, Never>
  public let startRefreshing: Signal<(), Never>
  public let title: Signal<String, Never>

  public var inputs: ManagePledgeViewModelInputs { return self }
  public var outputs: ManagePledgeViewModelOutputs { return self }
}

// MARK: - Functions

private func actionSheetMenuOptionsFor(
  project: Project,
  backing: ManagePledgeViewBackingEnvelope.Backing,
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

  return ManagePledgeAlertAction.allCases.filter { $0 != .viewRewards }
}

private func navigationBarTitle(
  with project: ManagePledgeViewBackingEnvelope.Project,
  userIsCreatorOfProject: Bool
) -> String {
  if userIsCreatorOfProject {
    return localizedString(
      key: "Pledge_details",
      defaultValue: "Pledge details"
    )
  }

  return project.state == .live ? Strings.Manage_your_pledge() : Strings.Your_pledge()
}

private func managePledgeMenuCTAType(for managePledgeAlertAction: ManagePledgeAlertAction)
  -> Koala.ManagePledgeMenuCTAType {
  switch managePledgeAlertAction {
  case .cancelPledge: return .cancelPledge
  case .changePaymentMethod: return .changePaymentMethod
  case .chooseAnotherReward: return .chooseAnotherReward
  case .contactCreator: return .contactCreator
  case .updatePledge: return .updatePledge
  case .viewRewards: return .viewRewards
  }
}

private func cancelPledgeViewData(
  with project: Project,
  backing: ManagePledgeViewBackingEnvelope.Backing
) -> CancelPledgeViewData {
  return .init(
    project: project,
    projectCountry: project.country,
    projectName: project.name,
    omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
    backingId: backing.id,
    pledgeAmount: backing.amount.amount
  )
}

private func managePledgePaymentMethodViewData(
  with backing: ManagePledgeViewBackingEnvelope.Backing
) -> ManagePledgePaymentMethodViewData {
  ManagePledgePaymentMethodViewData(
    backingState: backing.status,
    expirationDate: backing.creditCard?.expirationDate,
    lastFour: backing.creditCard?.lastFour,
    creditCardType: backing.creditCard?.type,
    paymentType: backing.creditCard?.paymentType
  )
}

private func managePledgeSummaryViewData(
  with project: Project,
  backedReward: Reward,
  envelope: ManagePledgeViewBackingEnvelope
) -> ManagePledgeSummaryViewData? {
  return .init(
    backerId: envelope.backing.backer.uid,
    backerName: envelope.backing.backer.name,
    backerSequence: envelope.backing.sequence,
    backingState: envelope.backing.status,
    bonusAmount: envelope.backing.bonusAmount?.amount,
    currentUserIsCreatorOfProject: currentUserIsCreator(of: project),
    isNoReward: backedReward.id == Reward.noReward.id,
    locationName: envelope.backing.location?.name,
    needsConversion: project.stats.needsConversion,
    omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
    pledgeAmount: envelope.backing.amount.amount,
    pledgedOn: envelope.backing.pledgedOn,
    projectCountry: project.country,
    projectDeadline: project.dates.deadline,
    projectState: envelope.project.state,
    rewardMinimum: envelope.backing.reward?.amount.amount ?? 0,
    shippingAmount: envelope.backing.shippingAmount?.amount
  )
}

private func rewardsData(
  from backing: ManagePledgeViewBackingEnvelope.Backing,
  with project: Project
) -> [Reward] {
  guard let addOns = backing.addOns?.nodes else { return [] }

  var selectedAddOnQuantities: [String: Int] = [:]

  addOns.forEach { addOn in
    let quantity = (selectedAddOnQuantities[addOn.id] ?? 0) + 1
    selectedAddOnQuantities[addOn.id] = quantity
  }

  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-DD"

  var existingAddOnIds = Set<String>()

  return addOns.compactMap { addOn in
    guard existingAddOnIds.contains(addOn.id) == false else { return nil }
    existingAddOnIds.insert(addOn.id)

    return Reward.addOnReward(
      from: addOn,
      project: project,
      selectedAddOnQuantities: selectedAddOnQuantities,
      dateFormatter: dateFormatter
    )
  }
}
