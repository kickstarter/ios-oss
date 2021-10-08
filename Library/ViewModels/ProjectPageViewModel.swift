import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectPageViewModelInputs {
  /// Call with the project given to the view controller.
  func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the Thank you page is dismissed after finishing backing the project
  func didBackProject()

  /// Call when the ManagePledgeViewController finished updating/cancelling a pledge with an optional message
  func managePledgeViewControllerFinished(with message: String?)

  /// Call when the pledge CTA button is tapped
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType)

  /// Call when pledgeRetryButton is tapped.
  func pledgeRetryButtonTapped()

  /// Call when the view did appear, and pass the animated parameter.
  func viewDidAppear(animated: Bool)

  /// Call when the view will transition to a new trait collection.
  func willTransition(toNewCollection collection: UITraitCollection)
}

public protocol ProjectPageViewModelOutputs {
  /// Emits a project that should be used to configure all children view controllers.
  var configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never> { get }

  /// Emits PledgeCTAContainerViewData to configure PledgeCTAContainerView
  var configurePledgeCTAView: Signal<PledgeCTAContainerViewData, Never> { get }

  /// Emits a message to show on `MessageBannerViewController`
  var dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never> { get }

  /// Emits `ManagePledgeViewParamConfigData` to take the user to the `ManagePledgeViewController`
  var goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never> { get }

  /// Emits a project and refTag to be used to navigate to the reward selection screen.
  var goToRewards: Signal<(Project, RefTag?), Never> { get }

  /// Emits when the navigation stack should be popped to the root view controller.
  var popToRootViewController: Signal<(), Never> { get }
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
        let updatedProjectWithFriends = project |> Project.lens.personalization.friends .~ projectFriends
          .value

        return (updatedProjectWithFriends, refTag)
      }

    let project = freshProjectAndRefTag
      .map(first)

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
  }

  private let configDataProperty = MutableProperty<(Either<Project, Param>, RefTag?)?>(nil)
  public func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?) {
    self.configDataProperty.value = (projectOrParam, refTag)
  }

  private let didBackProjectProperty = MutableProperty<Void>(())
  public func didBackProject() {
    self.didBackProjectProperty.value = ()
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

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewDidAppearAnimated = MutableProperty(false)
  public func viewDidAppear(animated: Bool) {
    self.viewDidAppearAnimated.value = animated
  }

  fileprivate let willTransitionToCollectionProperty =
    MutableProperty<UITraitCollection?>(nil)
  public func willTransition(toNewCollection collection: UITraitCollection) {
    self.willTransitionToCollectionProperty.value = collection
  }

  public let configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never>
  public let configurePledgeCTAView: Signal<PledgeCTAContainerViewData, Never>
  public let dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never>
  public let goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never>
  public let goToRewards: Signal<(Project, RefTag?), Never>
  public let popToRootViewController: Signal<(), Never>

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

      return SignalProducer(value: projectWithBackingAndRewards)
    }
}

private func shouldGoToManagePledge(with type: PledgeStateCTAType) -> Bool {
  return type.isAny(of: .viewBacking, .manage, .fix)
}
