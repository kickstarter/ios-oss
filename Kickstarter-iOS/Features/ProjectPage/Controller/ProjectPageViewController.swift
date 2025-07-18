import AVFoundation
import Combine
import KsApi
import Library
import Prelude
import SwiftUI
import UIKit

public enum ProjectPageViewControllerStyles {
  public enum Layout {
    public static let projectNavigationSelectorShadowViewHeight: CGFloat = 1
    public static let projectNavigationSelectorShadowOpacity: Float = 0.35
    public static let projectNavigationSelectorShadowVerticalOriginModifier: CGFloat = -1
    public static let projectNavigationSelectorHeightFormSheet: CGFloat = 60
    public static let projectNavigationSelectorHeightFullscreen: CGFloat = 70
    public static let tableFooterViewHeight: CGFloat = 1
  }
}

protocol ProjectPageViewControllerDelegate: AnyObject {
  func dismissPage(animated: Bool, completion: (() -> Void)?)
  func goToLogin()
  func displayProjectStarredPrompt()
  func showShareSheet(_ controller: UIActivityViewController, sourceView: UIView?)
}

protocol AudioVideoViewControllerPlaybackDelegate: AnyObject {
  func pauseAudioVideoPlayback()
}

public final class ProjectPageViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: Properties

  private let dataSource = ProjectPageViewControllerDataSource()
  private let viewModel: ProjectPageViewModelType = ProjectPageViewModel()

  private var navigationBarView: ProjectPageNavigationBarView = {
    ProjectPageNavigationBarView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let pledgeCTAContainerView: PledgeCTAContainerView = {
    PledgeCTAContainerView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let projectNavigationSelectorView: ProjectNavigationSelectorView = {
    ProjectNavigationSelectorView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let projectNavigationShadowView: UIView = {
    UIView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  weak var navigationDelegate: ProjectPageNavigationBarViewDelegate?
  weak var playbackDelegate: AudioVideoViewControllerPlaybackDelegate?
  public var messageBannerViewController: MessageBannerViewController?
  private var pinchToZoomData: PinchToZoomData?
  internal var overlayView: OverlayView? = OverlayView(frame: .zero)

  public static func configuredWith(
    projectOrParam: Either<Project, any ProjectPageParam>,
    refInfo: RefInfo?,
    secretRewardToken: String? = nil
  ) -> ProjectPageViewController {
    let vc = ProjectPageViewController.instantiate()

    vc.viewModel.inputs.configureWith(
      projectOrParam: projectOrParam,
      refInfo: refInfo,
      secretRewardToken: secretRewardToken
    )

    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configureNavigationView()
    self.configurePledgeCTAContainerView()
    self.configureTableView()
    self.configureNavigationShadowView()
    self.configureNavigationSelectorView()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)
    self.messageBannerViewController?.delegate = self
    self.tableView.registerCellClass(ProjectFAQsAskAQuestionCell.self)
    self.tableView.registerCellClass(ProjectFAQsCell.self)
    self.tableView.registerCellClass(ProjectFAQsEmptyStateCell.self)
    self.tableView.registerCellClass(ProjectTabAIGenerationCell.self)
    self.tableView.registerCellClass(ProjectTabCategoryDescriptionCell.self)
    self.tableView.registerCellClass(ProjectTabDisclaimerCell.self)
    self.tableView.registerCellClass(ProjectTabCheckmarkListCell.self)
    self.tableView.registerCellClass(ProjectHeaderCell.self)
    self.tableView.registerCellClass(ProjectPamphletCreatorHeaderCell.self)
    self.tableView.registerCellClass(TextViewElementCell.self)
    self.tableView.registerCellClass(ImageViewElementCell.self)
    self.tableView.registerCellClass(AudioVideoViewElementCell.self)
    self.tableView.registerCellClass(ExternalSourceViewElementCell.self)
    self.tableView.registerCellClass(ReportProjectCell.self)
    self.tableView.registerCellClass(SimilarProjectsTableViewCell.self)
    self.tableView.register(nib: .ProjectPamphletMainCell)
    self.tableView.register(nib: .ProjectPamphletSubpageCell)
    self.tableView.registerCellClass(ProjectRisksCell.self)
    self.tableView.registerCellClass(ProjectRisksDisclaimerCell.self)
    self.setupNotifications()
    self.viewModel.inputs.viewDidLoad()
    self.navigationDelegate?.viewDidLoad()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.showNavigationBar(true)
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    UIImageView.ksr_stopFetchingImages()
  }

  public override func updateViewConstraints() {
    super.updateViewConstraints()

    self.updatePledgeCTAConstraints()
    self.updateNavigationSelectorViewConstraints()
    self.updateNavigationShadowViewConstraints()
    self.updateTableViewConstraints()
  }

  public func configureNavigationView() {
    guard let defaultNavigationBarView = self.navigationController?.navigationBar else {
      return
    }

    _ = (self.navigationBarView, defaultNavigationBarView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.navigationBarView.delegate = self
    self.navigationDelegate = self.navigationBarView
  }

  private func configurePledgeCTAContainerView() {
    _ = (self.pledgeCTAContainerView, self.view)
      |> ksr_addSubviewToParent()

    self.pledgeCTAContainerView.retryButton.addTarget(
      self, action: #selector(ProjectPageViewController.pledgeRetryButtonTapped), for: .touchUpInside
    )

    self.pledgeCTAContainerView.delegate = self
  }

  private func configureTableView() {
    _ = self.tableView
      |> \.prefetchDataSource .~ self
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.tableFooterView .~
      UIView(frame: CGRect(
        x: 0,
        y: 0,
        width: 0,
        height: ProjectPageViewControllerStyles.Layout.tableFooterViewHeight
      ))

    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()
  }

  private func configureNavigationSelectorView() {
    _ = (self.projectNavigationSelectorView, self.view)
      |> ksr_addSubviewToParent()

    self.projectNavigationSelectorView.delegate = self
  }

  private func configureNavigationShadowView() {
    _ = (self.projectNavigationShadowView, self.view)
      |> ksr_addSubviewToParent()
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.view |>
      \.backgroundColor .~ LegacyColors.ksr_white.uiColor()

    _ = self.tableView |> tableViewStyle

    _ = self.projectNavigationShadowView
      |> \.backgroundColor .~ LegacyColors.ksr_white.uiColor()
      |> dropShadowStyle(
        offset: .init(width: 0, height: 0),
        shadowOpacity: ProjectPageViewControllerStyles.Layout
          .projectNavigationSelectorShadowOpacity
      )
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.bindProjectPageViewModel()
  }

  // MARK: - Private Helpers

  private func updateTableViewConstraints() {
    let tableViewBottomToPledgeCTA = self.tableView.bottomAnchor
      .constraint(equalTo: self.pledgeCTAContainerView.topAnchor, constant: -Styles.grid(1))

    let tableViewConstraints = [
      tableViewBottomToPledgeCTA,
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.projectNavigationSelectorView.bottomAnchor),
      self.tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
    ]

    NSLayoutConstraint.activate(tableViewConstraints)
  }

  private func updateNavigationSelectorViewConstraints() {
    let projectNavigationSelectorConstraints = [
      self.projectNavigationSelectorView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.projectNavigationSelectorView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.projectNavigationSelectorView.topAnchor
        .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
    ]

    NSLayoutConstraint.activate(projectNavigationSelectorConstraints)
  }

  private func updateNavigationShadowViewConstraints() {
    let projectNavigationShadowViewConstraints = [
      self.projectNavigationShadowView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.projectNavigationShadowView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.projectNavigationShadowView.topAnchor
        .constraint(
          equalTo: self.projectNavigationSelectorView.bottomAnchor,
          constant: ProjectPageViewControllerStyles.Layout
            .projectNavigationSelectorShadowVerticalOriginModifier
        ),
      self.projectNavigationShadowView.heightAnchor
        .constraint(
          equalToConstant: ProjectPageViewControllerStyles.Layout
            .projectNavigationSelectorShadowViewHeight
        )
    ]

    NSLayoutConstraint.activate(projectNavigationShadowViewConstraints)
  }

  private func updatePledgeCTAConstraints() {
    let pledgeCTAContainerViewConstraints = [
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ]

    NSLayoutConstraint.activate(pledgeCTAContainerViewConstraints)
  }

  private func setupNotifications() {
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageViewController.didBackProject),
        name: .ksr_projectBacked,
        object: nil
      )

    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageViewController.userSessionStarted),
        name: .ksr_sessionStarted,
        object: nil
      )

    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(self.appBackgrounded),
        name: .ksr_applicationDidEnterBackground,
        object: nil
      )
  }

  private func bindProjectPageViewModel() {
    self.navigationBarView.rac.hidden = self.viewModel.outputs.navigationBarIsHidden

    self.viewModel.outputs.navigationBarIsHidden
      .observeForUI()
      .observeValues { [weak self] _ in
        guard let defaultNavigationBarView = self?.navigationController?.navigationBar else {
          return
        }

        defaultNavigationBarView.standardAppearance.shadowColor = LegacyColors.ksr_white.uiColor()
        defaultNavigationBarView.scrollEdgeAppearance?.shadowColor = LegacyColors.ksr_white.uiColor()
      }

    self.viewModel.outputs.updateWatchProjectWithPrelaunchProjectState
      .observeForUI()
      .observeValues { [weak self] prelaunchState in
        self?.navigationDelegate?.configureSaveWatchPrelaunchProject(with: prelaunchState)
      }

    self.viewModel.outputs.goToRewards
      .observeForControllerAction()
      .observeValues { [weak self] params in
        let (project, refTag, secretRewardToken) = params

        self?.goToRewards(project: project, refTag: refTag, secretRewardToken: secretRewardToken)
      }

    self.viewModel.outputs.goToManagePledge
      .observeForControllerAction()
      .observeValues { [weak self] params in
        self?.goToManagePledge(params: params)
      }

    self.viewModel.outputs.goToPledgeManagementPledgeView
      .observeForControllerAction()
      .observeValues { [weak self] url in
        self?.goToPledgeManagementWebViewController(with: url)
      }

    self.viewModel.outputs.goToPledgeManager
      .observeForControllerAction()
      .observeValues { [weak self] url in
        self?.goToPledgeManagementWebViewController(with: url)
      }

    self.viewModel.outputs.configureChildViewControllersWithProject
      .observeForUI()
      .observeValues { [weak self] project, _ in
        self?.navigationDelegate?.configureSharing(with: .project(project))

        let watchProjectValue = WatchProjectValue(project, KSRAnalytics.PageContext.project, nil)

        self?.navigationDelegate?.configureWatchProject(with: watchProjectValue)
      }

    self.viewModel.outputs.configureDataSource
      .observeForUI()
      .observeValues { [weak self] navSection, project, refTag in
        self?.dataSource.load(
          navigationSection: navSection,
          project: project,
          refTag: refTag
        )

        self?.tableView.reloadData()
      }

    self.viewModel.outputs.configurePledgeCTAView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }

    self.viewModel.outputs.configureProjectNavigationSelectorView
      .observeForUI()
      .observeValues { [weak self] projectAndRefTag in
        self?.projectNavigationSelectorView.configure(with: projectAndRefTag)
      }

    self.viewModel.outputs.dismissManagePledgeAndShowMessageBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.dismiss(animated: true, completion: {
          self?.messageBannerViewController?.showBanner(with: .success, message: message)
        })
      }

    self.viewModel.outputs.goToComments
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToComments(project: $0)
      }

    self.viewModel.outputs.goToLoginWithIntent
      .observeForControllerAction()
      .observeValues { [weak self] intent in
        let loginTout = LoginToutViewController.configuredWith(loginIntent: intent)

        let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad
        let nav = UINavigationController(rootViewController: loginTout)
          |> \.modalPresentationStyle .~ (isIpad ? .formSheet : .fullScreen)

        self?.present(nav, animated: true, completion: nil)
      }

    self.viewModel.outputs.goToReportProject
      .observeForControllerAction()
      .observeValues { [weak self] flagged, projectID, projectUrl in
        guard !flagged else { return }
        self?.goToReportProject(projectID: projectID, projectUrl: projectUrl)
      }

    self.viewModel.outputs.goToRestrictedCreator
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToRestrictedCreator(message: $0)
      }

    self.viewModel.outputs.goToUpdates
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToUpdates(project: $0)
      }

    self.viewModel.outputs.goToURL
      .observeForControllerAction()
      .observeValues { url in
        UIApplication.shared.open(url)
      }

    self.viewModel.outputs.prefetchImageURLs
      .observeValues { [weak self] urls, indexPath in
        self?.prefetchImageDataAndUpdateWith(indexPath, imageUrls: urls)
      }

    self.viewModel.outputs.prefetchImageURLsOnFirstLoad
      .observeValues { [weak self] imageViewElements in
        imageViewElements.forEach { element in
          guard let url = URL(string: element.src) else { return }

          UIImageView.ksr_cacheImageWith(url) { [weak self] image in
            guard let dataSource = self?.dataSource,
                  let crossPlatformImage = image else { return }

            dataSource.preloadCampaignImageViewElement(element, image: crossPlatformImage)
          }
        }
      }

    self.viewModel.outputs.precreateAudioVideoURLsOnFirstLoad
      .observeValues { [weak self] elements in
        elements.forEach { element in
          guard let url = URL(string: element.sourceURLString) else { return }

          var audioVideoThumbnailURL: URL?

          if let audioVideoThumbnailURLString = element.thumbnailURLString {
            audioVideoThumbnailURL = URL(string: audioVideoThumbnailURLString)
          }

          self?.prepareToPlayAudioVideoURL(
            audioVideoURL: url,
            thumbnailURL: audioVideoThumbnailURL
          ) { availablePlayer, image in
            guard let usablePlayer = availablePlayer else { return }

            self?.dataSource.preloadCampaignAudioVideoViewElement(element, player: usablePlayer, image: image)
          }
        }
      }

    self.viewModel.outputs.precreateAudioVideoURLs
      .observeValues { [weak self] element, indexPath in
        guard let url = URL(string: element.sourceURLString) else { return }

        var audioVideoThumbnailURL: URL?

        if let audioVideoThumbnailURLString = element.thumbnailURLString {
          audioVideoThumbnailURL = URL(string: audioVideoThumbnailURLString)
        }

        self?.prepareToPlayAudioVideoURL(
          audioVideoURL: url,
          thumbnailURL: audioVideoThumbnailURL
        ) { availablePlayer, image in
          guard let usablePlayer = availablePlayer else { return }

          self?.dataSource.updateAudioVideoViewElementWith(
            element,
            player: usablePlayer,
            thumbnailImage: image,
            indexPath: indexPath
          )
        }
      }

    self.viewModel.outputs.presentMessageDialog
      .observeForUI()
      .observeValues { [weak self] project in
        self?.presentMessageDialog(project: project)
      }

    self.viewModel.outputs.showHelpWebViewController
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.presentHelpWebViewController(with: helpType, presentationStyle: .formSheet)
      }

    self.viewModel.outputs.updateDataSource
      .observeForUI()
      .observeValues { [weak self] data in
        let (navSection, project, refTag, initialIsExpandedArray, _, similarProjectsState) = data

        self?.pausePlayingMainCellVideo(navSection: navSection)

        let initialDatasourceLoad = {
          self?.dataSource.load(
            navigationSection: navSection,
            project: .left(project),
            refTag: refTag,
            isExpandedStates: initialIsExpandedArray,
            similarProjectsState: similarProjectsState
          )

          self?.tableView.reloadData()
        }

        initialDatasourceLoad()
      }

    self.viewModel.outputs.updateFAQsInDataSource
      .observeForUI()
      .observeValues { [weak self] project, refTag, isExpandedValues in
        self?.dataSource.load(
          navigationSection: .faq,
          project: .left(project),
          refTag: refTag,
          isExpandedStates: isExpandedValues
        )
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.popToRootViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.navigationController?.popToRootViewController(animated: false)
      }

    self.viewModel.outputs.pauseMedia
      .observeForUI()
      .observeValues { [weak self] in
        guard let tableView = self?.tableView else { return }

        tableView.indexPathsForVisibleRows?.forEach { indexPath in
          if let cell = tableView.cellForRow(at: indexPath) as? AudioVideoViewElementCell,
             let isPlaying = cell.delegate?.isPlaying(),
             isPlaying,
             let seekTime = cell.delegate?.pausePlayback() {
            self?.dataSource.updateAudioVideoViewElementSeektime(
              with: seekTime,
              tableView: tableView,
              indexPath: indexPath
            )
          }
        }
      }

    self.viewModel.outputs.reloadCampaignData
      .observeForUI()
      .observeValues { [weak self] in
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.projectFlagged
      .observeForUI()
      .observeValues { _ in
        // TODO: Use this flag to hide or show the Report this project label [MBL-983](https://kickstarter.atlassian.net/browse/MBL-983)
      }

    self.viewModel.outputs.didBlockUser
      .observeForUI()
      .observeValues { [weak self] _ in
        guard let self, let messageBanner = self.messageBannerViewController else { return }

        messageBanner.showBanner(with: .success, message: Strings.Block_user_success())
      }

    self.viewModel.outputs.didBlockUserError
      .observeForUI()
      .observeValues { [weak self] _ in
        guard let self, let messageBanner = self.messageBannerViewController else { return }

        messageBanner.showBanner(with: .error, message: Strings.Block_user_fail())
      }

    self.viewModel.outputs.navigateToSimilarProject
      .observeForUI()
      .observeValues { [weak self] project in
        guard let self else { return }
        let vc = ProjectPageViewController.configuredWith(
          projectOrParam: Either<Project, any ProjectPageParam>.right(project.projectPageParam),
          refInfo: RefInfo(.similarProjects)
        )
        if let nav = self.navigationController {
          nav.pushViewController(vc, animated: true)
        } else {
          assertionFailure("We expect a navigation controller to be here")
          let nav = UINavigationController(rootViewController: vc)
          self.present(nav, animated: true)
        }
      }
  }

  private func prepareToPlayAudioVideoURL(
    audioVideoURL: URL,
    thumbnailURL: URL?,
    completionHandler: @escaping (AVPlayer?, UIImage?) -> Void
  ) {
    // Fetch the thumbnail
    var cachedImage: UIImage?

    if let audioVideoThumbnailURL = thumbnailURL {
      UIImageView.ksr_cacheImageWith(audioVideoThumbnailURL) { image in
        cachedImage = image
      }
    }

    // Create asset to be played
    let asset = AVAsset(url: audioVideoURL)

    asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
      var durationError: NSError?
      var tracksError: NSError?

      if asset.statusOfValue(forKey: "duration", error: &durationError) == .loaded,
         asset.statusOfValue(forKey: "tracks", error: &tracksError) == .loaded {
        let playerItem = AVPlayerItem(
          asset: asset,
          automaticallyLoadedAssetKeys: ["duration", "tracks"]
        )

        var player: AVPlayer?
        var cancellable: AnyCancellable?

        cancellable = playerItem.publisher(for: \.status)
          .subscribe(on: DispatchQueue.global(qos: .background))
          .sink { status in
            switch status {
            case .readyToPlay:
              guard let availablePlayer = player else {
                completionHandler(nil, nil)

                return
              }

              completionHandler(availablePlayer, cachedImage)

              cancellable = nil
            default:
              return
            }
          }

        player = AVPlayer(playerItem: playerItem)
      }
    }
  }

  private func showProjectStarredPrompt() {
    let alert = UIAlertController(
      title: Strings.Project_saved(),
      message: Strings.Well_remind_you_forty_eight_hours_before_this_project_ends(),
      preferredStyle: .alert
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.Got_it(),
        style: .cancel,
        handler: nil
      )
    )

    self.present(alert, animated: true, completion: nil)
  }

  private func goToLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .starProject)
    let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad
    let nav = UINavigationController(rootViewController: vc)
      |> \.modalPresentationStyle .~ (isIpad ? .formSheet : .fullScreen)

    self.present(nav, animated: true, completion: nil)
  }

  private func goToRewards(project: Project, refTag: RefTag?, secretRewardToken: String?) {
    let vc = RewardsCollectionViewController.controller(
      with: project,
      refTag: refTag,
      secretRewardToken: secretRewardToken
    )
    self.present(vc, animated: true)
  }

  private func goToManagePledge(params: ManagePledgeViewParamConfigData) {
    let vc = ManagePledgeViewController.instantiate()
      |> \.delegate .~ self
    vc.configureWith(params: params)

    let nc = RewardPledgeNavigationController(rootViewController: vc)

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = nc
        |> \.modalPresentationStyle .~ .pageSheet
    }

    self.present(nc, animated: true)
  }

  private func goToPledgeManagementWebViewController(with backingDetailsURL: String) {
    let vc = SurveyResponseViewController.configuredWith(surveyUrl: backingDetailsURL)

    let nc = RewardPledgeNavigationController(rootViewController: vc)

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      nc.modalPresentationStyle = .pageSheet
    }

    self.present(nc, animated: true)
  }

  private func goToComments(project: Project) {
    let vc = commentsViewController(for: project)
    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.viewModel.inputs.showNavigationBar(false)
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func goToReportProject(projectID: String, projectUrl: String) {
    let reportProjectInfoView = ReportProjectInfoView(
      projectID: projectID,
      projectUrl: projectUrl,
      onSuccessfulSubmit: { [weak self] in
        self?.viewModel.inputs.viewDidLoad()
      }
    )
    self.viewModel.inputs.showNavigationBar(false)
    self.navigationController?
      .pushViewController(UIHostingController(rootView: reportProjectInfoView), animated: true)
  }

  private func goToRestrictedCreator(message: String) {
    let restrictedCreatorVC = RestrictedCreatorViewController.configuredWith(message: message)
    let navigationVC = UINavigationController(rootViewController: restrictedCreatorVC)
    navigationVC.modalPresentationStyle = .formSheet
    navigationVC.setNavigationBarHidden(true, animated: false)
    if let sheetController = navigationVC.sheetPresentationController {
      // If large text is on, allow view to scroll to fill entire screen.
      // This will not update dynamically if the content size category changes while the view is
      // open, but that's okay for this view.
      if self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
        sheetController.detents = [.medium(), .large()]
      } else {
        sheetController.detents = [.medium()]
      }
      sheetController.prefersGrabberVisible = true
    }
    present(navigationVC, animated: true)
  }

  private func goToUpdates(project: Project) {
    let vc = ProjectUpdatesViewController.configuredWith(project: project)
    self.viewModel.inputs.showNavigationBar(false)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func presentMessageDialog(project: Project) {
    let dialog = MessageDialogViewController
      .configuredWith(messageSubject: .project(id: project.id, name: project.name), context: .projectPage)
    dialog.modalPresentationStyle = .formSheet
    dialog.delegate = self
    self.present(
      UINavigationController(rootViewController: dialog),
      animated: true,
      completion: nil
    )
  }

  fileprivate func prefetchImageDataAndUpdateWith(
    _ indexPath: IndexPath,
    imageUrls: [URL]
  ) {
    guard let preexistingImageData = self.dataSource.imageViewElementWith(
      urls: imageUrls,
      indexPath: indexPath
    ) else {
      return
    }

    guard preexistingImageData.image == nil else { return }

    UIImageView.ksr_cacheImageWith(preexistingImageData.url) { [weak self] image in
      guard let imageData = image,
            let tableView = self?.tableView,
            let dataSource = self?.dataSource,
            dataSource.isIndexPathAnImageViewElement(
              tableView: tableView,
              indexPath: indexPath,
              section: .campaign
            ) else { return }

      dataSource
        .updateImageViewElementWith(
          preexistingImageData.element,
          image: imageData,
          indexPath: preexistingImageData.indexPath
        )
    }
  }

  private func pausePlayingMainCellVideo(navSection: NavigationSection) {
    let mainCellIndexPath = IndexPath(
      row: .zero,
      section: ProjectPageViewControllerDataSource.Section.overview.rawValue
    )

    if let _ = tableView.cellForRow(at: mainCellIndexPath) as? ProjectPamphletMainCell,
       navSection != .overview {
      self.playbackDelegate?.pauseAudioVideoPlayback()
    }
  }

  private func presentBlockUserAlert(username: String, userId: Int) {
    let alert = UIAlertController
      .blockUserAlert(username: username, blockUserHandler: { _ in
        self.viewModel.inputs.blockUser(id: userId)
      })

    self.present(alert, animated: true)
  }

  private func goToCreatorProfile(forProject project: any ProjectCreatorConfiguration) {
    let vc = ProjectCreatorViewController.configuredWith(project: project)

    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.viewModel.inputs.showNavigationBar(false)
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  // MARK: - Selectors

  @objc private func didBackProject() {
    self.viewModel.inputs.didBackProject()
  }

  @objc private func pledgeRetryButtonTapped() {
    self.viewModel.inputs.pledgeRetryButtonTapped()
  }

  @objc private func userSessionStarted() {
    self.viewModel.inputs.userSessionStarted()
  }

  @objc private func appBackgrounded() {
    self.viewModel.inputs.applicationDidEnterBackground()
  }
}

// MARK: - PledgeCTAContainerViewDelegate

extension ProjectPageViewController: PledgeCTAContainerViewDelegate {
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType) {
    self.viewModel.inputs.pledgeCTAButtonTapped(with: state)
  }
}

// MARK: - VideoViewControllerDelegate

extension ProjectPageViewController: VideoViewControllerDelegate {
  public func videoViewControllerDidFinish(_: VideoViewController) {}
  public func videoViewControllerDidStart(_: VideoViewController) {}
}

// MARK: - ManagePledgeViewControllerDelegate

extension ProjectPageViewController: ManagePledgeViewControllerDelegate {
  func managePledgeViewController(
    _: ManagePledgeViewController,
    managePledgeViewControllerFinishedWithMessage message: String?
  ) {
    self.viewModel.inputs.managePledgeViewControllerFinished(with: message)
  }

  func managePledgeViewControllerDidDismiss(_: ManagePledgeViewController) {}
}

// MARK: - ProjectPageViewControllerDelegate

extension ProjectPageViewController: ProjectPageViewControllerDelegate {
  func goToLogin() {
    self.goToLoginTout()
  }

  func displayProjectStarredPrompt() {
    self.showProjectStarredPrompt()
  }

  func dismissPage(animated flag: Bool, completion: (() -> Void)?) {
    self.dismiss(animated: flag, completion: completion)
  }

  func showShareSheet(_ controller: UIActivityViewController, sourceView: UIView?) {
    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = sourceView
    }

    self.present(controller, animated: true, completion: nil)
  }
}

// MARK: - ProjectNavigationSelectorViewDelegate

extension ProjectPageViewController: ProjectNavigationSelectorViewDelegate {
  func projectNavigationSelectorViewDidSelect(_: ProjectNavigationSelectorView, index: Int) {
    self.viewModel.inputs.projectNavigationSelectorViewDidSelect(index: index)
  }
}

// MARK: - UITableViewDelegate

extension ProjectPageViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case ProjectPageViewControllerDataSource.Section.overviewSubpages.rawValue:
      if self.dataSource.indexPathIsCommentsSubpage(indexPath) {
        self.viewModel.inputs.tappedComments()
      } else if self.dataSource.indexPathIsUpdatesSubpage(indexPath) {
        self.viewModel.inputs.tappedUpdates()
      }
    case ProjectPageViewControllerDataSource.Section.overviewReportProject.rawValue:
      self.viewModel.inputs.tappedReportProject()
    case ProjectPageViewControllerDataSource.Section.faqsAskAQuestion.rawValue:
      self.viewModel.inputs.askAQuestionCellTapped()
    case ProjectPageViewControllerDataSource.Section.faqs.rawValue:
      let values = self.dataSource.isExpandedValuesForFAQsSection() ?? []
      self.viewModel.inputs.didSelectFAQsRowAt(row: indexPath.row, values: values)
    case ProjectPageViewControllerDataSource.Section.campaign.rawValue:
      if let url = self.dataSource.imageViewElementURL(tableView: tableView, indexPath: indexPath) {
        self.viewModel.inputs.didSelectCampaignImageLink(url: url)
      }
    default:
      return
    }
  }

  public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? ProjectTabDisclaimerCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ProjectRisksDisclaimerCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ProjectPamphletMainCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ProjectPamphletMainCell, playbackDelegate == nil {
      self.playbackDelegate = cell
    } else if let cell = cell as? ImageViewElementCell {
      cell.pinchToZoomDelegate = self
    } else if let cell = cell as? SimilarProjectsTableViewCell {
      cell.delegate = self
    }

    /// If we are displaying the `ProjectPamphletSubpageCell` we do not want to show the cells separator.
    self.tableView.separatorStyle = indexPath.section == ProjectPageViewControllerDataSource.Section
      .overviewReportProject.rawValue ? .none : .singleLine

    self.tableView.layoutIfNeeded()
  }

  public func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cell = self.dataSource.items(in: indexPath.section)[indexPath.row]

    if cell.reusableId == SimilarProjectsTableViewCell.defaultReusableId {
      return SimilarProjectsCellConstants.collectionViewHeight
    }

    return UITableView.automaticDimension
  }

  public func tableView(
    _: UITableView,
    didEndDisplaying cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    if let cell = cell as? AudioVideoViewElementCell,
       let seekTime = cell.delegate?.pausePlayback() {
      self.dataSource
        .updateAudioVideoViewElementSeektime(with: seekTime, tableView: self.tableView, indexPath: indexPath)
    }
  }

  public override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)

    self.viewModel.inputs.viewWillTransition()
  }
}

// MARK: - ProjectPageViewControllerDataSourcePrefetching

extension ProjectPageViewController: UITableViewDataSourcePrefetching {
  public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    let campaignSectionImageIndexPaths = indexPaths.filter { indexPath in
      self.dataSource.isIndexPathAnImageViewElement(
        tableView: self.tableView,
        indexPath: indexPath,
        section: .campaign
      )
    }

    campaignSectionImageIndexPaths.forEach { indexPath in
      self.viewModel.inputs.prepareImageAt(indexPath)
    }

    let campaignSectionAudioVideoIndexPaths = indexPaths.compactMap { indexPath in
      self.dataSource.audioVideoViewElementWithNoPlayer(
        tableView: self.tableView,
        indexPath: indexPath,
        section: .campaign
      )
    }

    campaignSectionAudioVideoIndexPaths.forEach { element, indexPath in
      self.viewModel.inputs.prepareAudioVideoAt(indexPath, with: element)
    }
  }
}

// MARK: - MessageDialogViewControllerDelegate

extension ProjectPageViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage _: Message) {}
}

// MARK: - ProjectTabDisclaimerCellDelegate

extension ProjectPageViewController: ProjectTabDisclaimerCellDelegate {
  func projectTabDisclaimerCell(
    _: ProjectTabDisclaimerCell,
    didTapURL: URL
  ) {
    self.viewModel.inputs.projectTabDisclaimerCellDidTapURL(didTapURL)
  }
}

// MARK: ProjectRisksDisclaimerCellDelegate

extension ProjectPageViewController: ProjectRisksDisclaimerCellDelegate {
  func projectRisksDisclaimerCell(_: ProjectRisksDisclaimerCell, didTapURL: URL) {
    self.viewModel.inputs.projectRisksDisclaimerCellDidTapURL(didTapURL)
  }
}

// MARK: ProjectPamphletMainCellDelegate

extension ProjectPageViewController: ProjectPamphletMainCellDelegate {
  func projectPamphletMainCellGoToProjectNotice(_: ProjectPamphletMainCell) {
    self.viewModel.inputs.projectNoticeDetailsRequested()
  }

  internal func projectPamphletMainCell(
    _: ProjectPamphletMainCell,
    addChildController child: UIViewController
  ) {
    self.addChild(child)
    child.beginAppearanceTransition(true, animated: false)
    child.didMove(toParent: self)
    child.endAppearanceTransition()
  }

  internal func projectPamphletMainCell(
    _ cell: ProjectPamphletMainCell,
    goToCreatorForProject project: any ProjectPamphletMainCellConfiguration
  ) {
    guard
      let currentUser = AppEnvironment.current.currentUser,
      currentUser.id != project.projectPamphletMainCellProperties.creatorId,
      !project.projectPamphletMainCellProperties.isCreatorBlocked
    else {
      self.goToCreatorProfile(forProject: project)
      return
    }

    let actionSheet = UIAlertController
      .blockUserActionSheet(
        blockUserHandler: { _ in
          self.presentBlockUserAlert(
            username: project.projectPamphletMainCellProperties.creatorName,
            userId: project.projectPamphletMainCellProperties.creatorId
          )
        },
        viewProfileHandler: { _ in self.goToCreatorProfile(forProject: project) },
        sourceView: cell.creatorButton,
        isIPad: self.traitCollection.userInterfaceIdiom == .pad
      )

    self.present(actionSheet, animated: true)
  }
}

extension ProjectPageViewController: SimilarProjectsTableViewCellDelegate {
  func didSelectProject(_ project: ProjectCardProperties) {
    self.viewModel.inputs.similarProjectTapped(project: project)
  }
}

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
}

extension ProjectPageViewController: PinchToZoomDelegate, OverlayViewPresenting {
  public func pinchZoomDidBegin(
    _ gestureRecognizer: UIPinchGestureRecognizer,
    frame: CGRect,
    image: UIImage
  ) {
    if gestureRecognizer.scale > 1 {
      let imageView = UIImageView(image: image)
        |> \.contentMode .~ .scaleAspectFit
        |> \.clipsToBounds .~ true
        |> \.frame .~ frame

      showOverlayView(with: imageView)

      let gestureCenterInContainer = locationInView(gestureRecognizer)

      self.pinchToZoomData = PinchToZoomData(
        referenceFrame: frame,
        referenceCenter: gestureCenterInContainer,
        imageView: imageView
      )
    }
  }

  func pinchZoomDidChange(
    _ gestureRecognizer: UIPinchGestureRecognizer,
    completionHandler: () -> Void
  ) {
    guard let data = self.pinchToZoomData,
          let windowTransform = windowTransform else {
      hideOverlayView()

      return
    }

    let currentScale = data.imageView.frame.width / data.referenceFrame.size.width
    let newZoomScale = currentScale * gestureRecognizer.scale

    if newZoomScale > 1 {
      completionHandler()
    }

    let currentAlpha = OverlayViewLayout.Alpha.min + (newZoomScale - 1)
    let newAlpha = currentAlpha < OverlayViewLayout.Alpha.max ? currentAlpha : OverlayViewLayout.Alpha.max

    updateOverlayView(with: newAlpha)

    let centerXDiff = data.referenceCenter.x - locationInView(gestureRecognizer).x
    let centerYDiff = data.referenceCenter.y - locationInView(gestureRecognizer).y

    let zoomScale = (newZoomScale * data.imageView.frame.width >= data.referenceFrame.width) ? newZoomScale :
      currentScale

    let transform = windowTransform
      .scaledBy(x: zoomScale, y: zoomScale)
      .translatedBy(x: -centerXDiff, y: -centerYDiff)

    data.imageView.transform = transform
    transformSubviews(with: transform)

    self.pinchToZoomData = data

    gestureRecognizer.scale = 1
  }

  func pinchZoomDidEnd(
    _: UIPinchGestureRecognizer,
    completionHandler: @escaping () -> Void
  ) {
    UIView.animate(withDuration: 0.3, animations: {
      self.pinchToZoomData = nil

      self.transformSubviews(with: .identity)
    }, completion: { [weak self] _ in

      self?.hideOverlayView()
      completionHandler()
    })
  }
}

extension ProjectPageViewController: MessageBannerViewControllerDelegate {
  public func messageBannerViewDidHide(type: MessageBannerType) {
    if type == .success {
      self.dismiss(animated: true)
    }
  }
}
