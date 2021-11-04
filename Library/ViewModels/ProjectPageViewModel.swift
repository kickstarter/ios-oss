import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectPageViewModelInputs {
  /// Call when didSelectRowAt is called on a `ProjectFAQAskAQuestionCell`
  func askAQuestionCellTapped()

  /// Call with the project given to the view controller.
  func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the Thank you page is dismissed after finishing backing the project
  func didBackProject()

  /// Call with the `Int` (index) of the cell selected and the existing values (`[Bool]`) in the data source
  func didSelectRowAt(row: Int, values: [Bool])

  /// Call when the ManagePledgeViewController finished updating/cancelling a pledge with an optional message
  func managePledgeViewControllerFinished(with message: String?)

  /// Call when the pledge CTA button is tapped
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType)

  /// Call when pledgeRetryButton is tapped.
  func pledgeRetryButtonTapped()

  /// Call when the delegate method for the ProjectEnvironmentalCommitmentFooterCellDelegate is called.
  func projectEnvironmentalCommitmentDisclaimerCellDidTapURL(_ URL: URL)

  /// Call when the `ProjectNavigationSelectorViewDelegate` delegate method is called
  func projectNavigationSelectorViewDidSelect(index: Int)

  /// Call when the view did appear, and pass the animated parameter.
  func viewDidAppear(animated: Bool)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectPageViewModelOutputs {
  /// Emits a tuple of a `NavigationSection` and `ExtendedProjectProperties` to configure the data source
  var configureDataSource: Signal<(NavigationSection, ExtendedProjectProperties), Never> { get }

  /// Emits a project that should be used to configure all children view controllers.
  var configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never> { get }

  /// Emits PledgeCTAContainerViewData to configure PledgeCTAContainerView
  var configurePledgeCTAView: Signal<PledgeCTAContainerViewData, Never> { get }

  /// Emits Void to configure ProjectNavigationSelectorView
  var configureProjectNavigationSelectorView: Signal<Void, Never> { get }

  /// Emits a message to show on `MessageBannerViewController`
  var dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never> { get }

  /// Emits `ManagePledgeViewParamConfigData` to take the user to the `ManagePledgeViewController`
  var goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never> { get }

  /// Emits a project and refTag to be used to navigate to the reward selection screen.
  var goToRewards: Signal<(Project, RefTag?), Never> { get }

  /// Emits when the navigation stack should be popped to the root view controller.
  var popToRootViewController: Signal<(), Never> { get }

  /// Emits `Project` when the MessageDialogViewController should be presented
  var presentMessageDialog: Signal<Project, Never> { get }

  /// Emits a `HelpType` to use when presenting a HelpWebViewController.
  var showHelpWebViewController: Signal<HelpType, Never> { get }

  /// Emits a tuple of a `NavigationSection`, `ExtendedProjectProperties` and `[Bool]` (isExpanded values) to instruct the data source which section it is loading.
  var updateDataSource: Signal<(NavigationSection, ExtendedProjectProperties, [Bool]), Never> { get }

  /// Emits a tuple of `ExtendedProjectProperties` and `[Bool]` (isExpanded values) for the FAQs.
  var updateFAQsInDataSource: Signal<(ExtendedProjectProperties, [Bool]), Never> { get }
}

public protocol ProjectPageViewModelType {
  var inputs: ProjectPageViewModelInputs { get }
  var outputs: ProjectPageViewModelOutputs { get }
}

public final class ProjectPageViewModel: ProjectPageViewModelType, ProjectPageViewModelInputs,
  ProjectPageViewModelOutputs {
  public init() {
    let isLoading = MutableProperty(false)

    self.popToRootViewController = self.didBackProjectProperty.signal.ignoreValues()

    let freshProjectAndRefTagEvent = self.configDataProperty.signal.skipNil()
      .takePairWhen(Signal.merge(
        self.viewDidLoadProperty.signal.mapConst(true),
        self.didBackProjectProperty.signal.ignoreValues().mapConst(false),
        self.managePledgeViewControllerFinishedWithMessageProperty.signal.ignoreValues().mapConst(false),
        self.pledgeRetryButtonTappedProperty.signal.mapConst(false)
      ))
      .map(unpack)
      .switchMap { projectOrParam, refTag, shouldPrefix in
        fetchProject(projectOrParam: projectOrParam, shouldPrefix: shouldPrefix)
          .on(
            starting: { isLoading.value = true },
            terminated: { isLoading.value = false }
          )
          .map { project in
            (project, refTag.map(cleanUp(refTag:)))
          }
          .materialize()
      }

    let projectFriends = MutableProperty([User]())

    projectFriends <~ self.configDataProperty.signal.skipNil()
      .switchMap { projectParamAndRefTag -> SignalProducer<[User], Never> in
        let (projectOrParam, _) = projectParamAndRefTag
        return fetchProjectFriends(projectOrParam: projectOrParam).demoteErrors()
      }

    let freshProjectAndRefTag = freshProjectAndRefTagEvent.values()
      .map { project, refTag -> (Project, RefTag?) in
        let updatedProjectWithFriends = project
          |> Project.lens.personalization.friends .~ projectFriends.value
          |> Project.lens.extendedProjectProperties .~ project.extendedProjectProperties

        return (updatedProjectWithFriends, refTag)
      }

    let project = freshProjectAndRefTag
      .map(first)

    // The first tab we render by default is overview
    self.configureDataSource = project.map(\.extendedProjectProperties)
      .skipNil()
      .combineLatest(with: self.viewDidLoadProperty.signal)
      .map { projectProperties, _ in (.overview, projectProperties) }

    let projectAndBacking = project
      .filter { $0.personalization.isBacking ?? false }
      .compactMap { project -> (Project, Backing)? in
        guard let backing = project.personalization.backing else {
          return nil
        }

        return (project, backing)
      }

    let ctaButtonTappedWithType = self.pledgeCTAButtonTappedProperty.signal
      .skipNil()

    let shouldGoToRewards = ctaButtonTappedWithType
      .filter { $0.isAny(of: .pledge, .viewRewards, .viewYourRewards) }
      .ignoreValues()

    let shouldGoToManagePledge = ctaButtonTappedWithType
      .filter(shouldGoToManagePledge(with:))
      .ignoreValues()

    self.goToRewards = freshProjectAndRefTag
      .takeWhen(shouldGoToRewards)

    self.goToManagePledge = projectAndBacking
      .takeWhen(shouldGoToManagePledge)
      .map(first)
      .map { project -> ManagePledgeViewParamConfigData? in
        guard let backing = project.personalization.backing else {
          return nil
        }

        return (projectParam: Param.slug(project.slug), backingParam: Param.id(backing.id))
      }
      .skipNil()

    let projectError: Signal<ErrorEnvelope, Never> = freshProjectAndRefTagEvent.errors()

    self.configurePledgeCTAView = Signal.combineLatest(
      Signal.merge(freshProjectAndRefTag.map(Either.left), projectError.map(Either.right)),
      isLoading.signal
    )
    .map { ($0, $1, PledgeCTAContainerViewContext.projectPamphlet) }

    self.configureProjectNavigationSelectorView = self.viewDidLoadProperty.signal

    self.configureChildViewControllersWithProject = freshProjectAndRefTag
      .map { project, refTag in (project, refTag) }

    self.dismissManagePledgeAndShowMessageBannerWithMessage
      = self.managePledgeViewControllerFinishedWithMessageProperty.signal
      .skipNil()

    let cookieRefTag = freshProjectAndRefTag
      .map { project, refTag -> RefTag? in
        let r = cookieRefTagFor(project: project) ?? refTag
        return r
      }
      .take(first: 1)

    let freshProjectRefTag: Signal<(Project, RefTag?), Never> = Signal.zip(
      freshProjectAndRefTag.skip(first: 1),
      self.viewDidAppearAnimated.signal.ignoreValues()
    )
    .map(unpack)
    .map { project, refTag, _ in
      (project: project, refTag: refTag)
    }

    freshProjectRefTag
      .observeValues { project, refTag in
        AppEnvironment.current.ksrAnalytics.trackProjectViewed(
          project,
          refTag: refTag,
          sectionContext: .overview
        )
      }

    Signal.combineLatest(cookieRefTag.skipNil(), freshProjectAndRefTag.map(first))
      .take(first: 1)
      .map(cookieFrom(refTag:project:))
      .skipNil()
      .observeValues { AppEnvironment.current.cookieStorage.setCookie($0) }

    self.presentMessageDialog = project
      .takeWhen(self.askAQuestionCellTappedProperty.signal)

    self.showHelpWebViewController = self.projectEnvironmentalCommitmentDisclaimerCellDidTapURLProperty.signal
      .skipNil()
      .map(HelpType.helpType)
      .skipNil()

    // We skip the first one here because on `viewDidLoad` we are setting .overview so we don't need a useless emission here
    self.updateDataSource = self.projectNavigationSelectorViewDidSelectProperty.signal
      .skipNil()
      .map { index in NavigationSection(rawValue: index) }
      .skipNil()
      .combineLatest(with: project.map(\.extendedProjectProperties).skipNil())
      .map { navSection, projectProperties in
        let initialIsExpandedArray = Array(repeating: false, count: projectProperties.faqs.count)
        return (navSection, projectProperties, initialIsExpandedArray)
      }
      .skip(first: 1)

    self.updateFAQsInDataSource = project
      .map(\.extendedProjectProperties)
      .skipNil()
      .combineLatest(with: self.didSelectRowAtProperty.signal.skipNil())
      .map { projectProperties, indexAndDataSourceValues in
        let (index, isExpandedValues) = indexAndDataSourceValues
        var updatedValues = isExpandedValues
        updatedValues[index] = !updatedValues[index]

        return (projectProperties, updatedValues)
      }
  }

  fileprivate let askAQuestionCellTappedProperty = MutableProperty(())
  public func askAQuestionCellTapped() {
    self.askAQuestionCellTappedProperty.value = ()
  }

  private let configDataProperty = MutableProperty<(Either<Project, Param>, RefTag?)?>(nil)
  public func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?) {
    self.configDataProperty.value = (projectOrParam, refTag)
  }

  private let didBackProjectProperty = MutableProperty<Void>(())
  public func didBackProject() {
    self.didBackProjectProperty.value = ()
  }

  fileprivate let didSelectRowAtProperty = MutableProperty<(Int, [Bool])?>(nil)
  public func didSelectRowAt(row: Int, values: [Bool]) {
    self.didSelectRowAtProperty.value = (row, values)
  }

  private let managePledgeViewControllerFinishedWithMessageProperty = MutableProperty<String?>(nil)
  public func managePledgeViewControllerFinished(with message: String?) {
    self.managePledgeViewControllerFinishedWithMessageProperty.value = message
  }

  private let pledgeCTAButtonTappedProperty = MutableProperty<PledgeStateCTAType?>(nil)
  public func pledgeCTAButtonTapped(with state: PledgeStateCTAType) {
    self.pledgeCTAButtonTappedProperty.value = state
  }

  private let pledgeRetryButtonTappedProperty = MutableProperty(())
  public func pledgeRetryButtonTapped() {
    self.pledgeRetryButtonTappedProperty.value = ()
  }

  fileprivate let projectEnvironmentalCommitmentDisclaimerCellDidTapURLProperty = MutableProperty<URL?>(nil)
  public func projectEnvironmentalCommitmentDisclaimerCellDidTapURL(_ url: URL) {
    self.projectEnvironmentalCommitmentDisclaimerCellDidTapURLProperty.value = url
  }

  private let projectNavigationSelectorViewDidSelectProperty = MutableProperty<Int?>(nil)
  public func projectNavigationSelectorViewDidSelect(index: Int) {
    self.projectNavigationSelectorViewDidSelectProperty.value = index
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewDidAppearAnimated = MutableProperty(false)
  public func viewDidAppear(animated: Bool) {
    self.viewDidAppearAnimated.value = animated
  }

  public let configureDataSource: Signal<(NavigationSection, ExtendedProjectProperties), Never>
  public let configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never>
  public let configurePledgeCTAView: Signal<PledgeCTAContainerViewData, Never>
  public let configureProjectNavigationSelectorView: Signal<Void, Never>
  public let dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never>
  public let goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never>
  public let goToRewards: Signal<(Project, RefTag?), Never>
  public let popToRootViewController: Signal<(), Never>
  public let presentMessageDialog: Signal<Project, Never>
  public let showHelpWebViewController: Signal<HelpType, Never>
  public let updateDataSource: Signal<(NavigationSection, ExtendedProjectProperties, [Bool]), Never>
  public let updateFAQsInDataSource: Signal<(ExtendedProjectProperties, [Bool]), Never>

  public var inputs: ProjectPageViewModelInputs { return self }
  public var outputs: ProjectPageViewModelOutputs { return self }
}

private func fetchProjectFriends(projectOrParam: Either<Project, Param>)
  -> SignalProducer<[User], ErrorEnvelope> {
  let param = projectOrParam.ifLeft({ Param.id($0.id) }, ifRight: id)

  let projectFriendsProducer = AppEnvironment.current.apiService.fetchProjectFriends(param: param)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)

  return projectFriendsProducer
}

private func fetchProject(projectOrParam: Either<Project, Param>, shouldPrefix: Bool)
  -> SignalProducer<Project, ErrorEnvelope> {
  let param = projectOrParam.ifLeft({ Param.id($0.id) }, ifRight: id)

  let projectAndBackingIdProducer = AppEnvironment.current.apiService.fetchProject(projectParam: param)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)

  let projectAndBackingProducer = projectAndBackingIdProducer
    .switchMap { projectPamphletData -> SignalProducer<Project, ErrorEnvelope> in
      guard let backingId = projectPamphletData.backingId else {
        return fetchProjectRewards(project: projectPamphletData.project)
      }

      let projectWithBackingAndRewards = AppEnvironment.current.apiService
        .fetchBacking(id: backingId, withStoredCards: false)
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .switchMap { projectWithBacking -> SignalProducer<Project, ErrorEnvelope> in
          let updatedProjectWithBacking = projectWithBacking.project
            |> Project.lens.personalization.backing .~ projectWithBacking.backing
            |> Project.lens.personalization.isBacking .~ true
            |> Project.lens.extendedProjectProperties .~ projectWithBacking.project.extendedProjectProperties

          return fetchProjectRewards(project: updatedProjectWithBacking)
        }

      return projectWithBackingAndRewards
    }

  if let project = projectOrParam.left, shouldPrefix {
    return projectAndBackingProducer.prefix(value: project)
  }

  return projectAndBackingProducer
}

private func fetchProjectRewards(project: Project) -> SignalProducer<Project, ErrorEnvelope> {
  return AppEnvironment.current.apiService
    .fetchProjectRewards(projectId: project.id)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .switchMap { projectRewards -> SignalProducer<Project, ErrorEnvelope> in

      var allRewards = projectRewards

      if let noRewardReward = project.rewardData.rewards.first {
        allRewards.insert(noRewardReward, at: 0)
      }

      let projectWithBackingAndRewards = project
        |> Project.lens.rewardData.rewards .~ allRewards
        |> Project.lens.extendedProjectProperties .~ project.extendedProjectProperties

      return SignalProducer(value: projectWithBackingAndRewards)
    }
}

private func shouldGoToManagePledge(with type: PledgeStateCTAType) -> Bool {
  return type.isAny(of: .viewBacking, .manage, .fix)
}
