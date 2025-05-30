import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectPageParam {
  var param: Param { get }
  var initialProject: (any ProjectPamphletMainCellConfiguration)? { get }
}

public struct ProjectPageParamBox: ProjectPageParam {
  public let param: Param
  public let initialProject: (any ProjectPamphletMainCellConfiguration)?

  public init(param: Param, initialProject: (any ProjectPamphletMainCellConfiguration)?) {
    self.param = param
    self.initialProject = initialProject
  }
}

extension Param: ProjectPageParam {
  public var param: Param { self }
  public var initialProject: (any ProjectPamphletMainCellConfiguration)? { nil }
}

public protocol ProjectPageViewModelInputs {
  /// Call when didSelectRowAt is called on a `ProjectFAQAskAQuestionCell`
  func askAQuestionCellTapped()

  /// Call when `AppDelegate`'s `applicationDidEnterBackground` is triggered.
  func applicationDidEnterBackground()

  /// Call when block user is tapped
  func blockUser(id: Int)

  /// Convenience overload for `configureWith` that defaults the `secretRewardToken` to `nil`.
  /// This version is primarily used in tests to avoid passing unnecessary parameters,
  /// which helps prevent widespread changes across all existing test cases in `ProjectPageViewModelTests`.
  /// Use this when the `secretRewardToken` context is not required.
  func configureWith(projectOrParam: Either<Project, any ProjectPageParam>, refInfo: RefInfo?)

  /// Call with the project given to the view controller, including an optional `secretRewardToken`.
  /// Use this when loading a project that include access to secret rewards for authenticated users.
  func configureWith(
    projectOrParam: Either<Project, any ProjectPageParam>,
    refInfo: RefInfo?,
    secretRewardToken: String?
  )

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

  /// Call when project notice details should be displayed.
  func projectNoticeDetailsRequested()

  /// Call when the delegate method for the `ProjectTabDisclaimerCellDelegate` is called.
  func projectTabDisclaimerCellDidTapURL(_ URL: URL)

  /// Call when the `ProjectNavigationSelectorViewDelegate` delegate method is called
  func projectNavigationSelectorViewDidSelect(index: Int)

  /// Call when the delegate method for the `ProjectRisksDisclaimerCellDelegate` is called.
  func projectRisksDisclaimerCellDidTapURL(_ url: URL)

  /// Call when didSelectRow is called on the comments cell.
  func tappedComments()

  /// Call when didSelectRow is called on the updates cell.
  func tappedUpdates()

  /// Call when didSelectRow is called on the report project cell.
  func tappedReportProject()

  /// Call when the user session starts and we want to reload the data source.
  func userSessionStarted()

  /// Call when the view did appear, and pass the animated parameter.
  func viewDidAppear(animated: Bool)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when right before orientation change on view
  func viewWillTransition()

  /// Call when a similar project is tapped.
  func similarProjectTapped(project: ProjectCardProperties)
}

public protocol ProjectPageViewModelOutputs {
  /// Emits a tuple of a `NavigationSection`, `Project` and `RefTag?` to configure the data source
  var configureDataSource: Signal<
    (NavigationSection, Either<Project, any ProjectPageParam>, RefTag?),
    Never
  > {
    get
  }

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

  /// Emits `LoginIntent` to take the user to the `LoginToutViewController`
  var goToLoginWithIntent: Signal<LoginIntent, Never> { get }

  /// Emits `ManagePledgeViewParamConfigData` to take the user to the `ManagePledgeViewController`
  var goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never> { get }

  /// Emits `URL` to take the user to the `PledgeManagementDetailsWebViewController`
  var goToPledgeManagementPledgeView: Signal<URL, Never> { get }

  /// Emits a `Project` when the updates are to be rendered.
  var goToUpdates: Signal<Project, Never> { get }

  /// Emits a `String` that explains why the creator is restricted.
  var goToRestrictedCreator: Signal<String, Never> { get }

  /// Emits a `Bool` to show if the project has been flagged, the projectID as a `String`, and  a  project URL `String` when the report project view is to be rendered.
  var goToReportProject: Signal<(Bool, String, String), Never> { get }

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

  /// Emits a `Bool` when a project is flagged.
  var projectFlagged: Signal<Bool, Never> { get }

  /// Emits a signal when an orientation change happens if the currently selected tab is campaign.
  var reloadCampaignData: Signal<Void, Never> { get }

  /// Emits a `HelpType` to use when presenting a HelpWebViewController.
  var showHelpWebViewController: Signal<HelpType, Never> { get }

  /// Emits a tuple of a `NavigationSection`, `Project`, `RefTag?`, `[Bool]` (isExpanded values) and `[URL]` for campaign data to instruct the data source which section it is loading. Also a
  /// `SimilarProjectsState` for loading the Similar Projects Carousel.
  var updateDataSource: Signal<
    (NavigationSection, Project, RefTag?, [Bool], [URL], SimilarProjectsState),
    Never
  > { get }

  /// Emits a tuple of `Project`, `RefTag?` and `[Bool]` (isExpanded values) for the FAQs.
  var updateFAQsInDataSource: Signal<(Project, RefTag?, [Bool]), Never> { get }

  /// Emits a prelaunch save state that updates the navigation bar's watch project state.
  var updateWatchProjectWithPrelaunchProjectState: Signal<PledgeCTAPrelaunchState, Never> { get }

  /// Emits when a block user request is successful.
  var didBlockUser: Signal<(), Never> { get }

  /// Emits when a block user request fails.
  var didBlockUserError: Signal<(), Never> { get }

  /// The current state of similar projects.
  var similarProjects: Property<SimilarProjectsState> { get }

  /// Signal that emits when a user taps on a similar project.
  var navigateToSimilarProject: Signal<ProjectCardProperties, Never> { get }
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

    let freshProjectAndRefTagEvent = self.configDataProperty.signal
      .skipNil()
      .takePairWhen(Signal.merge(
        self.viewDidLoadProperty.signal.mapConst(true),
        self.userSessionStartedProperty.signal.mapConst(true),
        self.didBackProjectProperty.signal.ignoreValues().mapConst(false),
        self.managePledgeViewControllerFinishedWithMessageProperty.signal.ignoreValues().mapConst(false),
        self.pledgeRetryButtonTappedProperty.signal.mapConst(false)
      ))
      .map { data, shouldPrefix -> (Either<Project, any ProjectPageParam>, RefInfo?, String?, Bool) in
        let (projectOrParam, refInfo, secretRewardToken) = data

        return (projectOrParam, refInfo, secretRewardToken, shouldPrefix)
      }
      .switchMap { projectOrParam, refInfo, secretRewardToken, shouldPrefix in
        fetchProject(
          projectOrParam: projectOrParam,
          secretRewardToken: secretRewardToken,
          shouldPrefix: shouldPrefix
        )
        .on(
          starting: { isLoading.value = true },
          terminated: { isLoading.value = false }
        )
        .map { project in
          (project, refInfo?.refTag.map(cleanUp(refTag:)))
        }
        .materialize()
      }

    let projectFriends = MutableProperty([User]())

    projectFriends <~ self.configDataProperty.signal.skipNil()
      .switchMap { projectParamAndRefTag -> SignalProducer<[User], Never> in
        let (projectOrParam, _, _) = projectParamAndRefTag
        return fetchProjectFriends(projectOrParam: projectOrParam).demoteErrors()
      }

    let freshProjectAndRefTag: Signal<(Project, RefTag?), Never> = freshProjectAndRefTagEvent.values()
      .map { project, refTag -> (Project, RefTag?) in
        let updatedProjectWithFriends = project
          |> Project.lens.personalization.friends .~ projectFriends.value
          |> Project.lens.extendedProjectProperties .~ project.extendedProjectProperties

        return (updatedProjectWithFriends, refTag)
      }

    let project = freshProjectAndRefTag
      .map(first)

    self.projectFlagged = project.signal
      .map { $0.flagging ?? false }

    self.prefetchImageURLs = project.signal
      .compactMap { $0.extendedProjectProperties }
      .combineLatest(with: self.prepareImageAtProperty.signal.skipNil())
      .filterWhenLatestFrom(
        self.projectNavigationSelectorViewDidSelectProperty.signal.skipNil(),
        satisfies: { NavigationSection(rawValue: $0) == .campaign }
      )
      .switchMap { properties, indexPath -> SignalProducer<([URL], IndexPath)?, Never> in
        let imageViewElements = properties.story.htmlViewElements
          .compactMap { $0 as? ImageViewElement }

        if imageViewElements.count > 0 {
          let urlStrings = imageViewElements.map { $0.src }
          let urls = urlStrings.compactMap { URL(string: $0) }

          return SignalProducer(value: (urls, indexPath))
        }

        return SignalProducer(value: nil)
      }
      .skipNil()

    self.prefetchImageURLsOnFirstLoad = project.signal
      .compactMap { $0.extendedProjectProperties }
      .switchMap { properties -> SignalProducer<[ImageViewElement], Never> in
        let imageViewElements = properties.story.htmlViewElements
          .compactMap { $0 as? ImageViewElement }

        return SignalProducer(value: imageViewElements)
      }

    self.precreateAudioVideoURLsOnFirstLoad = project.signal
      .compactMap { $0.extendedProjectProperties }
      .switchMap { properties -> SignalProducer<[AudioVideoViewElement], Never> in
        let audioVideoViewElements = properties.story.htmlViewElements
          .compactMap { $0 as? AudioVideoViewElement }

        return SignalProducer(value: audioVideoViewElements)
      }

    self.precreateAudioVideoURLs = self.prepareAudioVideoAtProperty.signal.skipNil()

    let initialProjectData = self.configDataProperty.signal
      .takeWhen(self.viewDidLoadProperty.signal)
      .compactMap { data -> (Either<Project, any ProjectPageParam>, RefTag?)? in
        guard
          let (either, refInfo, _) = data,
          let right = either.right,
          let project = right.initialProject
        else { return nil }

        return (either, refInfo?.refTag)
      }

    let initialProjectDataSource = initialProjectData
      .map { config, refInfo in
        (NavigationSection.overview, config, refInfo)
      }

    // The first tab we render by default is overview
    self.configureDataSource = freshProjectAndRefTag
      .combineLatest(with: self.viewDidLoadProperty.signal)
      .map { projectAndRefTag, _ in
        let (project, refTag) = projectAndRefTag
        return (.overview, .left(project), refTag)
      }
      .merge(with: initialProjectDataSource)

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

    let shouldUpdateWatchProjectOnPrelaunch = ctaButtonTappedWithType
      .filter { state in
        switch state {
        case .prelaunch:
          return true
        default:
          return false
        }
      }

    self.updateWatchProjectWithPrelaunchProjectState = shouldUpdateWatchProjectOnPrelaunch
      .map { pledgeCTAType -> PledgeCTAPrelaunchState? in
        switch pledgeCTAType {
        case let .prelaunch(saved, watchesCount):
          return PledgeCTAPrelaunchState(prelaunch: true, saved: saved, watchesCount: watchesCount)
        default:
          return nil
        }
      }
      .skipNil()

    let projectError: Signal<ErrorEnvelope, Never> = freshProjectAndRefTagEvent.errors()

    self.configurePledgeCTAView = Signal.combineLatest(
      Signal.merge(freshProjectAndRefTag.map(Either.left), projectError.map(Either.right)),
      isLoading.signal
    )
    .map { ($0, $1) }

    self.configureChildViewControllersWithProject = freshProjectAndRefTag
      .map { project, refTag in (project, refTag) }

    self.dismissManagePledgeAndShowMessageBannerWithMessage
      = self.managePledgeViewControllerFinishedWithMessageProperty.signal
      .skipNil()

    let cookieRefTag: Signal<RefTag?, Never> = freshProjectAndRefTag
      .map { project, refTag -> RefTag? in
        let r = cookieRefTagFor(project: project) ?? refTag
        return r
      }
      .take(first: 1)

    self.goToComments = project
      .takeWhen(self.tappedCommentsProperty.signal)

    self.goToUpdates = project
      .takeWhen(self.tappedUpdatesProperty.signal)

    self.goToReportProject = project.signal
      .map { ($0.flagging ?? false, "\($0.graphID)", $0.urls.web.project) }
      .takeWhen(self.tappedReportProjectProperty.signal)

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

    // Facebook CAPI + Google Analytics
    trackFreshProjectAndRefTagViewed
      .observeValues { projectAndRefTag in
        let (project, _) = projectAndRefTag

        AppEnvironment.current.appTrackingTransparency.updateAdvertisingIdentifier()

        guard let externalId = AppEnvironment.current.appTrackingTransparency.advertisingIdentifier
        else { return }

        var userId = ""

        if let userValue = AppEnvironment.current.currentUser {
          userId = "\(userValue.id)"
        }

        let projectId = "\(project.id)"

        var extInfo = Array(repeating: "", count: 16)
        extInfo[0] = "i2"
        extInfo[4] = AppEnvironment.current.mainBundle.platformVersion

        _ = AppEnvironment
          .current
          .apiService
          .triggerThirdPartyEventInput(
            input: .init(
              deviceId: externalId,
              eventName: ThirdPartyEventInputName.ProjectPageViewed.rawValue,
              projectId: projectId,
              pledgeAmount: nil,
              shipping: nil,
              transactionId: nil,
              userId: userId,
              appData: .init(
                advertiserTrackingEnabled: true,
                applicationTrackingEnabled: true,
                extinfo: extInfo
              ),
              clientMutationId: ""
            )
          )
      }

    // Event attribution tracking
    self.configDataProperty.signal
      .skipNil()
      .combineLatest(with: freshProjectAndRefTag)
      .map { projectAndRefInfo, freshProjectAndRefTag in
        let (_, refInfo, _) = projectAndRefInfo
        let (project, _) = freshProjectAndRefTag
        return (project.graphID, refInfo)
      }
      .take(first: 1)
      .flatMap { graphId, refInfo in
        let eventName = AttributionTracking.AttributionEvent.projectPageViewed.rawValue
        let propsString = AttributionTracking.eventParametersString(refInfo: refInfo)
        let input = GraphAPI.CreateAttributionEventInput(
          eventName: eventName,
          eventProperties: propsString,
          projectId: graphId
        )
        return AppEnvironment.current.apiService.createAttributionEvent(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }
      .observeCompleted {
        // GraphQL mutation only runs if it is observed.
      }

    Signal.combineLatest(cookieRefTag.skipNil(), freshProjectAndRefTag.map(first))
      .take(first: 1)
      .map(cookieFrom(refTag:project:))
      .skipNil()
      .observeValues { AppEnvironment.current.cookieStorage.setCookie($0) }

    self.presentMessageDialog = project
      .takeWhen(self.askAQuestionCellTappedProperty.signal)

    let tappableCellURLs = Signal.merge(
      self.projectTabDisclaimerCellDidTapURLProperty.signal,
      self.projectRisksDisclaimerCellDidTapURLProperty.signal
    )
    .skipNil()

    self.showHelpWebViewController =
      tappableCellURLs
        .map(HelpType.helpType)
        .skipNil()

    let dataSourceUpdate = self.projectNavigationSelectorViewDidSelectProperty.signal
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

    let similarProjectsState = self.similarProjectsUseCase.similarProjects.signal
      .merge(
        with: self.similarProjectsUseCase.similarProjects.producer
          .takeWhen(self.viewDidLoadProperty.signal)
      )

    self.updateDataSource = Signal.combineLatest(
      dataSourceUpdate,
      similarProjectsState
    )
    .map { dataSource, similarProjects in
      let (navSection, project, refTag, initialIsExpandedArray, urls) = dataSource
      return (navSection, project, refTag, initialIsExpandedArray, urls, similarProjects)
    }

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

    // MARK: Project notice

    self.goToRestrictedCreator = project.takeWhen(self.projectNoticeDetailsRequestedProperty.signal)
      .map(\.extendedProjectProperties?.projectNotice)
      .skipNil()

    // MARK: User blocking

    let blockUserEvent = self.blockUserProperty.signal
      .map { BlockUserInput.init(blockUserId: "\($0)") }
      .switchMap { input in
        AppEnvironment.current.apiService
          .blockUser(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.didBlockUser = blockUserEvent.values().ignoreValues()
      .map { _ in NotificationCenter.default.post(.init(name: .ksr_blockedUser)) }

    // TODO: Display proper error messaging from the backend
    self.didBlockUserError = blockUserEvent.errors().ignoreValues()

    // MARK: User Blocking Analytics

    _ = self.blockUserProperty.signal
      .combineLatest(with: project)
      .observeValues { blockedUserId, project in
        AppEnvironment.current.ksrAnalytics
          .trackBlockedUser(
            project,
            page: .project,
            sectionContext: .overview,
            locationContext: .creatorDetailsMenu,
            typeContext: .initiate,
            targetUserId: "\(blockedUserId)"
          )
      }

    _ = self.blockUserProperty.signal
      .combineLatest(with: project)
      .takeWhen(blockUserEvent.values().ignoreValues())
      .observeValues { blockedUserId, project in
        AppEnvironment.current.ksrAnalytics
          .trackBlockedUser(
            project,
            page: .project,
            sectionContext: .overview,
            locationContext: .creatorDetailsMenu,
            typeContext: .confirm,
            targetUserId: "\(blockedUserId)"
          )
      }

    // MARK: Rewards

    let secretRewardToken = self.configDataProperty.signal
      .skipNil()
      .map { _, _, secretRewardToken -> String? in
        secretRewardToken
      }

    self.rewardsUseCase = RewardsUseCase(
      secretRewardToken: secretRewardToken,
      userSessionStarted: self.userSessionStartedProperty.signal
    )

    self.goToRewards = freshProjectAndRefTag
      .takeWhen(
        self.rewardsUseCase.goToRewards
      )

    // MARK: - Pledge View

    self.viewPledgeUseCase = .init(with: projectAndBacking)

    ctaButtonTappedWithType
      .filter(shouldGoToManagePledge(with:))
      .observeValues { _ in self.viewPledgeUseCase.goToPledgeViewTapped() }

    // MARK: Similar Projects

    freshProjectAndRefTag
      .map { project, _ in "\(project.id)" }
      .skipRepeats()
      .observeForControllerAction()
      .observeValues { [weak self] projectID in
        self?.similarProjectsUseCase.inputs.projectIDLoaded(projectID: projectID)
      }

    // MARK: Rewards Setup (pre-initialization)

    let shouldGoToRewards = ctaButtonTappedWithType
      .filter { state in
        switch state {
        case .pledge, .viewRewards, .viewYourRewards:
          return true
        default:
          return false
        }
      }
      .ignoreValues()

    shouldGoToRewards
      .observeValues { _ in self.rewardsUseCase.goToRewardsTapped() }
  }

  fileprivate let askAQuestionCellTappedProperty = MutableProperty(())
  public func askAQuestionCellTapped() {
    self.askAQuestionCellTappedProperty.value = ()
  }

  fileprivate let applicationDidEnterBackgroundProperty = MutableProperty(())
  public func applicationDidEnterBackground() {
    self.applicationDidEnterBackgroundProperty.value = ()
  }

  fileprivate let blockUserProperty = MutableProperty<Int>(0)
  public func blockUser(id: Int) {
    self.blockUserProperty.value = id
  }

  private let configDataProperty = MutableProperty<(
    Either<Project, any ProjectPageParam>,
    RefInfo?,
    String?
  )?>(nil)
  public func configureWith(
    projectOrParam: Either<Project, any ProjectPageParam>,
    refInfo: RefInfo?,
    secretRewardToken: String?
  ) {
    self.configDataProperty.value = (projectOrParam, refInfo, secretRewardToken)
  }

  /// Convenience overload for `configureWith` that defaults the `secretRewardToken` to `nil`.
  /// This version is primarily used in tests to avoid passing unnecessary parameters,
  /// which helps prevent widespread changes across all existing test cases in `ProjectPageViewModelTests`.
  /// Use this when the `secretRewardToken` context is not required.
  public func configureWith(projectOrParam: Either<Project, any ProjectPageParam>, refInfo: RefInfo?) {
    self.configureWith(projectOrParam: projectOrParam, refInfo: refInfo, secretRewardToken: nil)
  }

  private let didBackProjectProperty = MutableProperty<Void>(())
  public func didBackProject() {
    self.didBackProjectProperty.value = ()
  }

  fileprivate let didSelectFAQsRowAtProperty = MutableProperty<(Int, [Bool])?>(nil)
  public func didSelectFAQsRowAt(row: Int, values: [Bool]) {
    self.didSelectFAQsRowAtProperty.value = (row, values)
  }

  fileprivate let didSelectCampaignImageLinkProperty = MutableProperty<URL?>(nil)
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

  fileprivate let projectNoticeDetailsRequestedProperty = MutableProperty(())
  public func projectNoticeDetailsRequested() {
    self.projectNoticeDetailsRequestedProperty.value = ()
  }

  fileprivate let projectTabDisclaimerCellDidTapURLProperty = MutableProperty<URL?>(nil)
  public func projectTabDisclaimerCellDidTapURL(_ url: URL) {
    self.projectTabDisclaimerCellDidTapURLProperty.value = url
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

  fileprivate let tappedReportProjectProperty = MutableProperty(())
  public func tappedReportProject() {
    self.tappedReportProjectProperty.value = ()
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

  private let viewPledgeUseCase: ViewPledgeUseCase

  public let configureDataSource: Signal<
    (NavigationSection, Either<Project, any ProjectPageParam>, RefTag?),
    Never
  >
  public let configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never>
  public let configurePledgeCTAView: Signal<PledgeCTAContainerViewData, Never>
  public let configureProjectNavigationSelectorView: Signal<(Project, RefTag?), Never>
  public let dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never>
  public let goToComments: Signal<Project, Never>

  public var goToLoginWithIntent: Signal<LoginIntent, Never> {
    self.rewardsUseCase.goToLoginWithIntent
  }

  public var goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never> {
    self.viewPledgeUseCase.goToNativePledgeView
  }

  public var goToPledgeManagementPledgeView: Signal<URL, Never> {
    self.viewPledgeUseCase.goToPledgeManagementPledgeView
  }

  public let goToRestrictedCreator: Signal<String, Never>
  public let goToRewards: Signal<(Project, RefTag?), Never>
  public let goToUpdates: Signal<Project, Never>
  public let goToReportProject: Signal<(Bool, String, String), Never>
  public let goToURL: Signal<URL, Never>
  public let navigationBarIsHidden: Signal<Bool, Never>
  public let pauseMedia: Signal<Void, Never>
  public let popToRootViewController: Signal<(), Never>
  public let presentMessageDialog: Signal<Project, Never>
  public let precreateAudioVideoURLs: Signal<(AudioVideoViewElement, IndexPath), Never>
  public let precreateAudioVideoURLsOnFirstLoad: Signal<[AudioVideoViewElement], Never>
  public let prefetchImageURLs: Signal<([URL], IndexPath), Never>
  public let prefetchImageURLsOnFirstLoad: Signal<[ImageViewElement], Never>
  public let projectFlagged: Signal<Bool, Never>
  public let reloadCampaignData: Signal<Void, Never>
  public let showHelpWebViewController: Signal<HelpType, Never>
  public let updateDataSource: Signal<
    (NavigationSection, Project, RefTag?, [Bool], [URL], SimilarProjectsState),
    Never
  >
  public let updateFAQsInDataSource: Signal<(Project, RefTag?, [Bool]), Never>
  public let updateWatchProjectWithPrelaunchProjectState: Signal<PledgeCTAPrelaunchState, Never>
  public let didBlockUser: Signal<(), Never>
  public let didBlockUserError: Signal<(), Never>

  public var inputs: ProjectPageViewModelInputs { return self }
  public var outputs: ProjectPageViewModelOutputs { return self }

  // MARK: - Similar Projects

  private let similarProjectsUseCase = SimilarProjectsUseCase()

  public func similarProjectTapped(project: ProjectCardProperties) {
    self.similarProjectsUseCase.projectTapped(project: project)
  }

  public var similarProjects: Property<SimilarProjectsState> {
    self.similarProjectsUseCase.similarProjects
  }

  public var navigateToSimilarProject: Signal<ProjectCardProperties, Never> {
    self.similarProjectsUseCase.navigateToProject
  }

  // MARK: - RewardsUseCase

  private let rewardsUseCase: RewardsUseCase
}

private func fetchProjectFriends(projectOrParam: Either<Project, any ProjectPageParam>)
  -> SignalProducer<[User], ErrorEnvelope> {
  let param = projectOrParam.ifLeft({ Param.id($0.id) }, ifRight: id)

  let projectFriendsProducer = AppEnvironment.current.apiService.fetchProjectFriends(param: param.param)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)

  return projectFriendsProducer
}

private func fetchProject(
  projectOrParam: Either<Project, any ProjectPageParam>,
  secretRewardToken secretRewardToken: String?,
  shouldPrefix: Bool
)
  -> SignalProducer<Project, ErrorEnvelope> {
  let param = projectOrParam.ifLeft({ Param.id($0.id) }, ifRight: id)
  let configCurrency = AppEnvironment.current.launchedCountries.countries
    .first(where: { $0.countryCode == AppEnvironment.current.countryCode })?.currencyCode

  let projectAndBackingIdProducer = AppEnvironment.current.apiService
    .fetchProject(projectParam: param.param, configCurrency: configCurrency)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)

  let projectAndBackingProducer = projectAndBackingIdProducer
    .switchMap { projectPamphletData -> SignalProducer<Project, ErrorEnvelope> in
      guard let backingId = projectPamphletData.backingId else {
        return addUserToSecretRewardGroupIfNeeded(
          project: projectPamphletData.project,
          secretRewardToken: secretRewardToken
        )
        .then(fetchProjectRewards(project: projectPamphletData.project))
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
            |> Project.lens.stats.userCurrency .~ projectPamphletData.project.stats.userCurrency

          return addUserToSecretRewardGroupIfNeeded(
            project: updatedProjectWithBacking,
            secretRewardToken: secretRewardToken
          )
          .then(fetchProjectRewards(project: updatedProjectWithBacking))
        }

      return projectWithBackingAndRewards
    }

  if let project = projectOrParam.left, shouldPrefix {
    return projectAndBackingProducer.prefix(value: project)
  }

  return projectAndBackingProducer
}

// TODO: Consider relocating this logic to `RewardsUseCase` to consolidate secret reward handling.
// Ticket: [MBL-2478](https://kickstarter.atlassian.net/browse/MBL-2478)
private func addUserToSecretRewardGroupIfNeeded(
  project: Project,
  secretRewardToken: String?
) -> SignalProducer<Void, ErrorEnvelope> {
  let isUserLoggedIn = AppEnvironment.current.currentUser != nil

  guard isUserLoggedIn, let secretRewardToken = secretRewardToken, !secretRewardToken.isEmpty else {
    return SignalProducer(value: ())
  }

  let input = AddUserToSecretRewardGroupInput(
    projectId: project.graphID,
    secretRewardToken: secretRewardToken
  )
  return AppEnvironment.current.apiService
    .addUserToSecretRewardGroup(input: input)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .switchMap { _ -> SignalProducer<Void, ErrorEnvelope> in
      SignalProducer(value: ())
    }
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

private func shouldGoToManagePledge(with ctaType: PledgeStateCTAType) -> Bool {
  switch ctaType {
  case .fix, .viewBacking, .manage:
    return true
  default:
    return false
  }
}
