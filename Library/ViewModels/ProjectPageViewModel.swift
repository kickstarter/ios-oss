import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectPageViewModelInputs {
  /// Call when didSelectRowAt is called on a `ProjectFAQAskAQuestionCell`
  func askAQuestionCellTapped()

  /// Call when `AppDelegate`'s `applicationDidEnterBackground` is triggered.
  func applicationDidEnterBackground()

  /// Call with the project given to the view controller.
  func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the Thank you page is dismissed after finishing backing the project
  func didBackProject()

  /// Call with the `Int` (index) of the cell selected and the existing values (`[Bool]`) in the data source
  func didSelectFAQsRowAt(row: Int, values: [Bool])

  /// Call with the `URL` of the `ImageViewElement` cell selected in the Campaign section of the data source.
  func didSelectCampaignImageLink(url: URL)

  /// Call when the navigation bar should be hidden/shown.
  func showNavigationBar(_ flag: Bool)

  /// Call when the ManagePledgeViewController finished updating/cancelling a pledge with an optional message
  func managePledgeViewControllerFinished(with message: String?)

  /// Call when the pledge CTA button is tapped
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType)

  /// Call when pledgeRetryButton is tapped.
  func pledgeRetryButtonTapped()

  /// Call for image view elements that are missing inside `prefetchRowsAt` delegate in `ProjectPageViewController`
  func prepareImageAt(_ indexPath: IndexPath)

  /// Call for audio/video view elements that are missing a player inside `prefetchRowsAt` delegate in `ProjectPageViewController`
  func prepareAudioVideoAt(_ indexPath: IndexPath, with audioVideoViewElement: AudioVideoViewElement)

  /// Call when the delegate method for the `ProjectEnvironmentalCommitmentFooterCellDelegate` is called.
  func projectEnvironmentalCommitmentDisclaimerCellDidTapURL(_ URL: URL)

  /// Call when the `ProjectNavigationSelectorViewDelegate` delegate method is called
  func projectNavigationSelectorViewDidSelect(index: Int)

  /// Call when the delegate method for the `ProjectRisksDisclaimerCellDelegate` is called.
  func projectRisksDisclaimerCellDidTapURL(_ url: URL)

  /// Call when didSelectRow is called on the comments cell.
  func tappedComments()

  /// Call when didSelectRow is called on the updates cell.
  func tappedUpdates()

  /// Call when the creator header cell progress view is tapped.
  func tappedViewProgress(of project: Project)

  /// Call when the user session starts and we want to reload the data source.
  func userSessionStarted()

  /// Call when the view did appear, and pass the animated parameter.
  func viewDidAppear(animated: Bool)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when right before orientation change on view
  func viewWillTransition()
}

public protocol ProjectPageViewModelOutputs {
  /// Emits a tuple of a `NavigationSection`, `Project` and `RefTag?` to configure the data source
  var configureDataSource: Signal<(NavigationSection, Project, RefTag?), Never> { get }

  /// Emits a project that should be used to configure all children view controllers.
  var configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never> { get }

  /// Emits PledgeCTAContainerViewData to configure PledgeCTAContainerView
  var configurePledgeCTAView: Signal<PledgeCTAContainerViewData, Never> { get }

  /// Emits `(Project, RefTag?)` to configure `ProjectNavigationSelectorView`
  var configureProjectNavigationSelectorView: Signal<(Project, RefTag?), Never> { get }

  /// Emits a message to show on `MessageBannerViewController`
  var dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never> { get }

  /// Emits a `Project` when the comments are to be rendered.
  var goToComments: Signal<Project, Never> { get }

  /// Emits a `Param` when the creator header cell progress view is tapped.
  var goToDashboard: Signal<Param, Never> { get }

  /// Emits `ManagePledgeViewParamConfigData` to take the user to the `ManagePledgeViewController`
  var goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never> { get }

  /// Emits a `Project` when the updates are to be rendered.
  var goToUpdates: Signal<Project, Never> { get }

  /// Emits a project and refTag to be used to navigate to the reward selection screen.
  var goToRewards: Signal<(Project, RefTag?), Never> { get }

  /// Emits a URL that will be opened by an external Safari browser.
  var goToURL: Signal<URL, Never> { get }

  /// Emits a `Bool` to hide the navigation bar.
  var navigationBarIsHidden: Signal<Bool, Never> { get }

  /// Emits a signal when the app is no longer being actively used to pause any playing media.
  var pauseMedia: Signal<Void, Never> { get }

  /// Emits when the navigation stack should be popped to the root view controller.
  var popToRootViewController: Signal<(), Never> { get }

  /// Emits `Project` when the MessageDialogViewController should be presented
  var presentMessageDialog: Signal<Project, Never> { get }

  /// Emits `AudioVideoViewElement` and `IndexPath` when the project has campaign data to download for a row
  var precreateAudioVideoURLs: Signal<(AudioVideoViewElement, IndexPath), Never> { get }

  /// Emits `[AudioVideoViewElement]` to preload the data source with `AVPlayer` objects for video player cells.
  var precreateAudioVideoURLsOnFirstLoad: Signal<[AudioVideoViewElement], Never> { get }

  /// Emits `[URL]` and `IndexPath` when the project has campaign data to download for a row
  var prefetchImageURLs: Signal<([URL], IndexPath), Never> { get }

  /// Emits `[ImageViewElement]` when the project has campaign data to download for an image row as soon as the urls are available.
  var prefetchImageURLsOnFirstLoad: Signal<[ImageViewElement], Never> { get }

  /// Emits a signal when an orientation change happens if the currently selected tab is campaign.
  var reloadCampaignData: Signal<Void, Never> { get }

  /// Emits a `HelpType` to use when presenting a HelpWebViewController.
  var showHelpWebViewController: Signal<HelpType, Never> { get }

  /// Emits a tuple of a `NavigationSection`, `Project`, `RefTag?`, `[Bool]` (isExpanded values) and `[URL]` for campaign data to instruct the data source which section it is loading.
  var updateDataSource: Signal<(NavigationSection, Project, RefTag?, [Bool], [URL]), Never> { get }

  /// Emits a tuple of `Project`, `RefTag?` and `[Bool]` (isExpanded values) for the FAQs.
  var updateFAQsInDataSource: Signal<(Project, RefTag?, [Bool]), Never> { get }
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
        self.userSessionStartedProperty.signal.mapConst(true),
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

    self.prefetchImageURLs = project.signal
      .skip(first: 1)
      .combineLatest(with: self.prepareImageAtProperty.signal.skipNil())
      .filterWhenLatestFrom(
        self.projectNavigationSelectorViewDidSelectProperty.signal.skipNil(),
        satisfies: { NavigationSection(rawValue: $0) == .campaign }
      )
      .switchMap { project, indexPath -> SignalProducer<([URL], IndexPath)?, Never> in
        let imageViewElements = project.extendedProjectProperties?.story.htmlViewElements
          .compactMap { $0 as? ImageViewElement } ?? []

        if imageViewElements.count > 0 {
          let urlStrings = imageViewElements.map { $0.src }
          let urls = urlStrings.compactMap { URL(string: $0) }

          return SignalProducer(value: (urls, indexPath))
        }

        return SignalProducer(value: nil)
      }
      .skipNil()

    self.prefetchImageURLsOnFirstLoad = project.signal
      .skip(first: 1)
      .switchMap { project -> SignalProducer<[ImageViewElement], Never> in
        let imageViewElements = project.extendedProjectProperties?.story.htmlViewElements
          .compactMap { $0 as? ImageViewElement } ?? []

        return SignalProducer(value: imageViewElements)
      }

    self.precreateAudioVideoURLsOnFirstLoad = project.signal
      .skip(first: 1)
      .switchMap { project -> SignalProducer<[AudioVideoViewElement], Never> in
        let audioVideoViewElements = project.extendedProjectProperties?.story.htmlViewElements
          .compactMap { $0 as? AudioVideoViewElement } ?? []

        return SignalProducer(value: audioVideoViewElements)
      }

    self.precreateAudioVideoURLs = self.prepareAudioVideoAtProperty.signal.skipNil()

    // The first tab we render by default is overview
    self.configureDataSource = freshProjectAndRefTag
      .combineLatest(with: self.viewDidLoadProperty.signal)
      .map { projectAndRefTag, _ in
        let (project, refTag) = projectAndRefTag
        return (.overview, project, refTag)
      }

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

    self.goToComments = project
      .takeWhen(self.tappedCommentsProperty.signal)

    self.goToDashboard = self.tappedViewProgressProperty.signal
      .skipNil()
      .map { .id($0.id) }

    self.goToUpdates = project
      .takeWhen(self.tappedUpdatesProperty.signal)

    // Hide the custom navigation bar when pushing a new view controller
    // Unhide the custom navigation bar when viewWillAppear is called
    self.navigationBarIsHidden = self.showNavigationBarProperty.signal.negate()

    self.configureProjectNavigationSelectorView = freshProjectAndRefTag
      .map { projectAndRefTag in
        let (project, refTag) = projectAndRefTag
        return (project: project, refTag: refTag)
      }

    let trackFreshProjectAndRefTagViewed: Signal<(Project, RefTag?), Never> = Signal.zip(
      freshProjectAndRefTag.skip(first: 1),
      self.viewDidAppearAnimatedProperty.signal.ignoreValues()
    )
    .map(unpack)
    .map { project, refTag, _ in
      (project: project, refTag: refTag)
    }

    trackFreshProjectAndRefTagViewed
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

    let tappableCellURLs = Signal.merge(
      self.projectEnvironmentalCommitmentDisclaimerCellDidTapURLProperty.signal,
      self.projectRisksDisclaimerCellDidTapURLProperty.signal
    )
    .skipNil()

    self.showHelpWebViewController =
      tappableCellURLs
        .map(HelpType.helpType)
        .skipNil()

    // We skip the first one here because on `viewDidLoad` we are setting .overview so we don't need a useless emission here
    self.updateDataSource = self.projectNavigationSelectorViewDidSelectProperty.signal
      .skipNil()
      .skipRepeats()
      .map { index in NavigationSection(rawValue: index) }
      .skipNil()
      .combineLatest(with: freshProjectAndRefTag)
      .map { navSection, projectAndRefTag in
        let (project, refTag) = projectAndRefTag
        let initialIsExpandedArray = Array(
          repeating: false,
          count: project.extendedProjectProperties?.faqs.count ?? 0
        )

        var dataSourceUpdate = (navSection, project, refTag, initialIsExpandedArray, [URL]())

        switch navSection {
        case .campaign:
          let imageViewElements = project.extendedProjectProperties?.story.htmlViewElements
            .compactMap { $0 as? ImageViewElement } ?? []

          if imageViewElements.count > 0 {
            let urlStrings = imageViewElements.map { $0.src }
            let urls = urlStrings.compactMap { URL(string: $0) }

            dataSourceUpdate = (navSection, project, refTag, initialIsExpandedArray, urls)
          }
        default:
          break
        }

        return dataSourceUpdate
      }
      .skip(first: 1)

    self.updateFAQsInDataSource = freshProjectAndRefTag
      .combineLatest(with: self.didSelectFAQsRowAtProperty.signal.skipNil())
      .map { projectAndRefTag, indexAndDataSourceValues in
        let (project, refTag) = projectAndRefTag
        let (index, isExpandedValues) = indexAndDataSourceValues
        var updatedValues = isExpandedValues
        updatedValues[index] = !updatedValues[index]

        return (project, refTag, updatedValues)
      }

    self.pauseMedia = self.applicationDidEnterBackgroundProperty.signal
    self.reloadCampaignData = self.projectNavigationSelectorViewDidSelectProperty.signal.skipNil()
      .takeWhen(self.viewWillTransitionProperty.signal)
      .filter { NavigationSection(rawValue: $0) == .campaign }
      .ignoreValues()

    self.goToURL = self.didSelectCampaignImageLinkProperty.signal.skipNil()
  }

  fileprivate let askAQuestionCellTappedProperty = MutableProperty(())
  public func askAQuestionCellTapped() {
    self.askAQuestionCellTappedProperty.value = ()
  }

  fileprivate let applicationDidEnterBackgroundProperty = MutableProperty(())
  public func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }

  private let configDataProperty = MutableProperty<(Either<Project, Param>, RefTag?)?>(nil)
  public func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?) {
    self.configDataProperty.value = (projectOrParam, refTag)
  }

  private let didBackProjectProperty = MutableProperty<Void>(())
  public func didBackProject() {
    self.didBackProjectProperty.value = ()
  }

  fileprivate let didSelectFAQsRowAtProperty = MutableProperty<(Int, [Bool])?>(nil)
  public func didSelectFAQsRowAt(row: Int, values: [Bool]) {
    self.didSelectFAQsRowAtProperty.value = (row, values)
  }

  fileprivate let didSelectCampaignImageLinkProperty = MutableProperty<(URL)?>(nil)
  public func didSelectCampaignImageLink(url: URL) {
    self.didSelectCampaignImageLinkProperty.value = url
  }

  fileprivate let showNavigationBarProperty = MutableProperty<Bool>(false)
  public func showNavigationBar(_ flag: Bool) {
    self.showNavigationBarProperty.value = flag
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

  private let prepareImageAtProperty = MutableProperty<IndexPath?>(nil)
  public func prepareImageAt(_ indexPath: IndexPath) {
    self.prepareImageAtProperty.value = indexPath
  }

  private let prepareAudioVideoAtProperty = MutableProperty<(AudioVideoViewElement, IndexPath)?>(nil)
  public func prepareAudioVideoAt(_ indexPath: IndexPath, with audioVideoViewElement: AudioVideoViewElement) {
    self.prepareAudioVideoAtProperty.value = (audioVideoViewElement, indexPath)
  }

  fileprivate let projectEnvironmentalCommitmentDisclaimerCellDidTapURLProperty = MutableProperty<URL?>(nil)
  public func projectEnvironmentalCommitmentDisclaimerCellDidTapURL(_ url: URL) {
    self.projectEnvironmentalCommitmentDisclaimerCellDidTapURLProperty.value = url
  }

  private let projectNavigationSelectorViewDidSelectProperty = MutableProperty<Int?>(nil)
  public func projectNavigationSelectorViewDidSelect(index: Int) {
    self.projectNavigationSelectorViewDidSelectProperty.value = index
  }

  fileprivate let projectRisksDisclaimerCellDidTapURLProperty = MutableProperty<URL?>(nil)
  public func projectRisksDisclaimerCellDidTapURL(_ url: URL) {
    self.projectRisksDisclaimerCellDidTapURLProperty.value = url
  }

  fileprivate let tappedCommentsProperty = MutableProperty(())
  public func tappedComments() {
    self.tappedCommentsProperty.value = ()
  }

  fileprivate let tappedUpdatesProperty = MutableProperty(())
  public func tappedUpdates() {
    self.tappedUpdatesProperty.value = ()
  }

  fileprivate let tappedViewProgressProperty = MutableProperty<Project?>(nil)
  public func tappedViewProgress(of project: Project) {
    self.tappedViewProgressProperty.value = project
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewDidAppearAnimatedProperty = MutableProperty(false)
  public func viewDidAppear(animated: Bool) {
    self.viewDidAppearAnimatedProperty.value = animated
  }

  fileprivate let viewWillTransitionProperty = MutableProperty(())
  public func viewWillTransition() {
    self.viewWillTransitionProperty.value = ()
  }

  public let configureDataSource: Signal<(NavigationSection, Project, RefTag?), Never>
  public let configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never>
  public let configurePledgeCTAView: Signal<PledgeCTAContainerViewData, Never>
  public let configureProjectNavigationSelectorView: Signal<(Project, RefTag?), Never>
  public let dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never>
  public let goToComments: Signal<Project, Never>
  public let goToDashboard: Signal<Param, Never>
  public let goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never>
  public let goToRewards: Signal<(Project, RefTag?), Never>
  public let goToUpdates: Signal<Project, Never>
  public let goToURL: Signal<URL, Never>
  public let navigationBarIsHidden: Signal<Bool, Never>
  public let pauseMedia: Signal<Void, Never>
  public let popToRootViewController: Signal<(), Never>
  public let presentMessageDialog: Signal<Project, Never>
  public let precreateAudioVideoURLs: Signal<(AudioVideoViewElement, IndexPath), Never>
  public let precreateAudioVideoURLsOnFirstLoad: Signal<[AudioVideoViewElement], Never>
  public let prefetchImageURLs: Signal<([URL], IndexPath), Never>
  public let prefetchImageURLsOnFirstLoad: Signal<[ImageViewElement], Never>
  public let reloadCampaignData: Signal<Void, Never>
  public let showHelpWebViewController: Signal<HelpType, Never>
  public let updateDataSource: Signal<(NavigationSection, Project, RefTag?, [Bool], [URL]), Never>
  public let updateFAQsInDataSource: Signal<(Project, RefTag?, [Bool]), Never>

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
  let configCurrency = AppEnvironment.current.launchedCountries.countries
    .first(where: { $0.countryCode == AppEnvironment.current.countryCode })?.currencyCode

  let projectAndBackingIdProducer = AppEnvironment.current.apiService
    .fetchProject(projectParam: param, configCurrency: configCurrency)
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
            // INFO: Seems like in the `fetchBacking` call we nil out the chosen currency set by `fetchProject` b/c the query for backing doesn't have `me { chosenCurrency }`, so its' being included here.
            |> Project.lens.stats.currentCurrency .~ projectPamphletData.project.stats.currentCurrency

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
