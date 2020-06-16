import KsApi
import Prelude
import ReactiveSwift

public typealias BackingData = (Project, User?)

public protocol ProjectPamphletViewModelInputs {
  /// Call with the project given to the view controller.
  func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call after the view loads and passes the initial TopConstraint constant.
  func initial(topConstraint: CGFloat)

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

  /// Call when the view will appear, and pass the animated parameter.
  func viewWillAppear(animated: Bool)

  /// Call when the view will transition to a new trait collection.
  func willTransition(toNewCollection collection: UITraitCollection)
}

public protocol ProjectPamphletViewModelOutputs {
  /// Emits a project that should be used to configure all children view controllers.
  var configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never> { get }

  /// Emits PledgeCTAContainerViewData to configure PledgeCTAContainerView
  var configurePledgeCTAView: Signal<PledgeCTAContainerViewData, Never> { get }

  var dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never> { get }

  var goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never> { get }

  /// Emits a project and refTag to be used to navigate to the reward selection screen.
  var goToRewards: Signal<(Project, RefTag?), Never> { get }

  /// Emits when the navigation stack should be popped to the root view controller.
  var popToRootViewController: Signal<(), Never> { get }

  /// Emits two booleans that determine if the navigation bar should be hidden, and if it should be animated.
  var setNavigationBarHiddenAnimated: Signal<(Bool, Bool), Never> { get }

  /// Emits when the `setNeedsStatusBarAppearanceUpdate` method should be called on the view.
  var setNeedsStatusBarAppearanceUpdate: Signal<(), Never> { get }

  /// Emits a float to update topLayoutConstraints constant.
  var topLayoutConstraintConstant: Signal<CGFloat, Never> { get }
}

public protocol ProjectPamphletViewModelType {
  var inputs: ProjectPamphletViewModelInputs { get }
  var outputs: ProjectPamphletViewModelOutputs { get }
}

public final class ProjectPamphletViewModel: ProjectPamphletViewModelType, ProjectPamphletViewModelInputs,
  ProjectPamphletViewModelOutputs {
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

    let freshProjectAndRefTag = freshProjectAndRefTagEvent.values()

    let project = freshProjectAndRefTag
      .map(first)
    let refTag = freshProjectAndRefTag
      .map(second)

    let projectAndBacking = project
      .filter { $0.personalization.isBacking ?? false }
      .filterMap { project -> (Project, Backing)? in
        guard let backing = project.personalization.backing else {
          return nil
        }

        return (project, backing)
      }

    let ctaButtonTappedWithType = self.pledgeCTAButtonTappedProperty.signal
      .skipNil()

    let shouldGoToRewards = ctaButtonTappedWithType
      .filter { [.pledge, .viewRewards, .viewYourRewards, .seeTheRewards, .viewTheRewards].contains($0) }
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

    self.setNeedsStatusBarAppearanceUpdate = Signal.merge(
      self.viewWillAppearAnimated.signal.ignoreValues(),
      self.willTransitionToCollectionProperty.signal.ignoreValues()
    )

    self.setNavigationBarHiddenAnimated = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((true, false)),
      self.viewWillAppearAnimated.signal.skip(first: 1).map { (true, $0) }
    )

    self.topLayoutConstraintConstant = self.initialTopConstraintProperty.signal.skipNil()
      .takePairWhen(self.willTransitionToCollectionProperty.signal.skipNil())
      .map(layoutConstraintConstant(initialTopConstraint:traitCollection:))

    self.dismissManagePledgeAndShowMessageBannerWithMessage
      = self.managePledgeViewControllerFinishedWithMessageProperty.signal
      .skipNil()

    let cookieRefTag = freshProjectAndRefTag
      .map { project, refTag in
        cookieRefTagFor(project: project) ?? refTag
      }
      .take(first: 1)

    let freshProjectRefTagAndCookieRefTag: Signal<(Project, RefTag?, RefTag?), Never> = Signal.zip(
      freshProjectAndRefTag.skip(first: 1),
      self.viewDidAppearAnimated.signal.ignoreValues()
    )
    .map(unpack)
    .map { project, refTag, _ in
      let cookieRefTag = cookieRefTagFor(project: project) ?? refTag

      return (project: project, refTag: refTag, cookieRefTag: cookieRefTag)
    }

    freshProjectRefTagAndCookieRefTag
      .observeValues { project, refTag, cookieRefTag in
        let optimizelyProps = optimizelyProperties() ?? [:]

        AppEnvironment.current.koala.trackProjectViewed(
          project,
          refTag: refTag,
          cookieRefTag: cookieRefTag,
          optimizelyProperties: optimizelyProps
        )
        AppEnvironment.current.optimizelyClient?.track(eventName: "Project Page Viewed")
      }

    Signal.combineLatest(cookieRefTag.skipNil(), freshProjectAndRefTag.map(first))
      .take(first: 1)
      .map(cookieFrom(refTag:project:))
      .skipNil()
      .observeValues { AppEnvironment.current.cookieStorage.setCookie($0) }

    let shouldTrackCTATappedEvent = ctaButtonTappedWithType
      .filter { [.pledge, .seeTheRewards, .viewTheRewards].contains($0) }

    Signal.combineLatest(project, refTag)
      .takeWhen(shouldTrackCTATappedEvent)
      .observeValues { _, _ in
        AppEnvironment.current.optimizelyClient?.track(eventName: "Project Page Pledge Button Clicked")
      }
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

  fileprivate let initialTopConstraintProperty = MutableProperty<CGFloat?>(nil)
  public func initial(topConstraint: CGFloat) {
    self.initialTopConstraintProperty.value = topConstraint
  }

  fileprivate let viewDidAppearAnimated = MutableProperty(false)
  public func viewDidAppear(animated: Bool) {
    self.viewDidAppearAnimated.value = animated
  }

  fileprivate let viewWillAppearAnimated = MutableProperty(false)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearAnimated.value = animated
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
  public let setNavigationBarHiddenAnimated: Signal<(Bool, Bool), Never>
  public let setNeedsStatusBarAppearanceUpdate: Signal<(), Never>
  public let topLayoutConstraintConstant: Signal<CGFloat, Never>

  public var inputs: ProjectPamphletViewModelInputs { return self }
  public var outputs: ProjectPamphletViewModelOutputs { return self }
}

private func layoutConstraintConstant(
  initialTopConstraint: CGFloat,
  traitCollection: UITraitCollection
) -> CGFloat {
  guard !traitCollection.isRegularRegular else {
    return 0.0
  }

  return traitCollection.isVerticallyCompact ? 0.0 : initialTopConstraint
}

private func fetchProject(projectOrParam: Either<Project, Param>, shouldPrefix: Bool)
  -> SignalProducer<Project, ErrorEnvelope> {
  let param = projectOrParam.ifLeft({ Param.id($0.id) }, ifRight: id)

  let projectProducer = AppEnvironment.current.apiService.fetchProject(param: param)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)

  if let project = projectOrParam.left, shouldPrefix {
    return projectProducer.prefix(value: project)
  }

  return projectProducer
}

private func shouldGoToManagePledge(with type: PledgeStateCTAType) -> Bool {
  return type.isAny(of: .viewBacking, .manage, .fix)
}
