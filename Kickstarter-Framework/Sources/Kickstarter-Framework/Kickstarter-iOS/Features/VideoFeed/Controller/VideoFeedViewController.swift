import AVFoundation
import FirebaseCrashlytics
import KDS
import Kingfisher
import KsApi
import Library
import SwiftUI
import UIKit

/// Full-screen swipeable video feed.
///   - Full-screen paging
///   - Plain data source driven by `VideoFeedViewModel`
///   - Cells buffer video on `willDisplay` and reset on `didEndDisplaying`
///   - Playback only starts once a cell is fully settled (scroll has ended)
///   - Current cell audio plays until the next cell takes over
///   - Pauses video on background, resumes on foreground
final class VideoFeedViewController: UIViewController {
  private enum Constants {
    static let backgroundColor = KDS.Colors.Icon.dark.uiColor()
  }

  private let viewModel = VideoFeedViewModel()
  private let dataSource = VideoFeedDataSource()

  private var lifecycleObservers: [any NSObjectProtocol] = []
  private var previewImagePrefetcher: ImagePrefetcher?
  private var isScrolling = false

  /// Called once the first batch of items has loaded and the feed is ready to present.
  var onReadyToPresent: (() -> Void)?

  /// Called if the initial fetch fails.
  var onFetchFailed: (() -> Void)?

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 0
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = Constants.backgroundColor

    self.configureAudioSession()
    self.observeAppLifecycle()

    self.setupCollectionView()
    self.bindViewModel()
  }

  func startFetch() {
    self.viewModel.viewDidLoad()
    self.bindViewModel()
  }

  deinit {
    self.lifecycleObservers.forEach(NotificationCenter.default.removeObserver)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    /// Presenting a fullscreen modal nudges the contentOffset.
    /// This is a side effect of UIKit re-measuring UIHostingConfiguration cells when presenting views.
    /// This method snaps the collection view cell back into place once the layout has settled.
    self.snapToCurrentPage()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.setNavigationBarHidden(true, animated: animated)
    self.viewModel.viewWillAppear()

    /// Dispatching so item state updates on the project page (to handle project saves for example) before we reconfigure the cell.
    DispatchQueue.main.async { [weak self] in
      self?.reconfigureVisibleCell()
      self?.activateCurrentPageCell()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.navigationController?.setNavigationBarHidden(false, animated: animated)
    self.pauseVisibleCell()
  }

  // MARK: - CollectionView

  private func setupCollectionView() {
    self.collectionView.dataSource = self.dataSource
    self.collectionView.delegate = self
    self.collectionView.translatesAutoresizingMaskIntoConstraints = false
    self.collectionView.backgroundColor = Constants.backgroundColor
    self.collectionView.isPagingEnabled = true
    self.collectionView.showsVerticalScrollIndicator = false
    self.collectionView.contentInsetAdjustmentBehavior = .never

    self.collectionView.register(
      VideoFeedCell.self,
      forCellWithReuseIdentifier: VideoFeedCell.reuseIdentifier
    )

    self.view.addSubview(self.collectionView)

    NSLayoutConstraint.activate([
      self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  // MARK: - Binding

  public override func bindViewModel() {
    withObservationTracking {
      _ = self.viewModel.fetchedItems
    } onChange: { [weak self] in
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }

        self.updateFeedWithFetchedItems(self.viewModel.items)

        /// isInitialLoadComplete is set before fetchedItems in the VM, so it's
        /// guaranteed to be true here on the first successful fetch.
        if self.viewModel.isInitialLoadComplete {
          self.onReadyToPresent?()
        }

        self.bindViewModel()
      }
    }

    withObservationTracking {
      _ = self.viewModel.errorMessage
    } onChange: { [weak self] in
      DispatchQueue.main.async { [weak self] in
        guard let self, self.viewModel.errorMessage != nil else { return }

        self.onFetchFailed?()
        self.bindViewModel()
      }
    }

    withObservationTracking {
      _ = self.viewModel.loginIntent
    } onChange: { [weak self] in
      DispatchQueue.main.async { [weak self] in
        guard let self, let intent = self.viewModel.loginIntent else { return }

        self.goToLoginTout(intent: intent)
        self.viewModel.clearLoginIntent()
        self.bindViewModel()
      }
    }

    withObservationTracking {
      _ = self.viewModel.saveFailedItemId
    } onChange: { [weak self] in
      DispatchQueue.main.async { [weak self] in
        guard let self, let failedId = self.viewModel.saveFailedItemId else { return }

        self.collectionView.visibleCells
          .compactMap { $0 as? VideoFeedCell }
          .first { $0.currentItemId == failedId }?
          .showSaveErrorToast()

        self.viewModel.clearSaveFailedItemId()
        self.bindViewModel()
      }
    }

    /// Reconfigures the visible cell whenever items mutate (e.g. save state changes made on the project page).
    withObservationTracking {
      _ = self.viewModel.items
    } onChange: { [weak self] in
      DispatchQueue.main.async { [weak self] in
        self?.reconfigureVisibleCell()
        self?.bindViewModel()
      }
    }
  }

  /// Reloads the collection view with a fresh set of fetched items.
  private func updateFeedWithFetchedItems(_ newItems: [VideoFeedItem]) {
    self.dataSource.load(newItems)
    self.collectionView.reloadData()

    DispatchQueue.main.async {
      self.activateCurrentPageCell()
    }
  }

  /// This re-runs `UIHostingConfiguration` on the currently active cell so the SwiftUI view can get any updated values that may have mutated when presenting a view on top of the feed.
  /// (i.e. `watchesCount` and `isSaved` changes made in the Project Page).
  private func reconfigureVisibleCell() {
    guard let indexPath = self.collectionView.indexPathsForVisibleItems.first,
          let cell = self.collectionView.cellForItem(at: indexPath) as? VideoFeedCell else { return }

    let items = self.viewModel.items

    guard indexPath.item < items.count else { return }

    let item = items[indexPath.item]

    cell.configureWith(
      item: Binding(
        get: { self.viewModel.items.first(where: { $0.id == item.id }) ?? item },
        set: { _ in }
      ),
      isSaved: self.viewModel.isSaved(projectId: item.id)
    )
  }

  private func snapToCurrentPage() {
    let pageHeight = self.collectionView.bounds.height

    guard pageHeight > 0 else { return }

    let currentPage = round(self.collectionView.contentOffset.y / pageHeight)

    self.collectionView.contentOffset.y = currentPage * pageHeight
  }

  // MARK: - Audio session

  /// Auto play video audio
  private func configureAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      #if DEBUG
        print("`VideoFeedViewController`: Failed to configure audio session:", error.localizedDescription)
      #endif

      Crashlytics.crashlytics().record(error: error)
    }
  }

  // MARK: - App lifecycle

  /// Pause video on background, resume on foreground, and re-render the active cell after login.
  private func observeAppLifecycle() {
    let center = NotificationCenter.default

    self.lifecycleObservers = [
      center.addObserver(
        forName: UIApplication.didEnterBackgroundNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.pauseVisibleCell()
      },
      center.addObserver(
        forName: UIApplication.willEnterForegroundNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.resumeVisibleCell()
      },
      center.addObserver(
        forName: .ksr_sessionStarted,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        /// Fire any save that was deferred (pending login) then re-render the active cell.
        self?.viewModel.userSessionStarted()

        DispatchQueue.main.async { [weak self] in
          self?.reconfigureVisibleCell()
        }
      }
    ]
  }

  private func pauseVisibleCell() {
    self.collectionView.visibleCells
      .compactMap { $0 as? VideoFeedCell }
      .forEach { $0.pausePlayback() }
  }

  private func resumeVisibleCell() {
    self.activateCurrentPageCell()
  }

  // MARK: - Navigation

  /// TODO: This pattern is duplicated across several VCs.
  /// Its worth pulling into a `UIViewController` extension, with the background color fix keyed off the videoFeed intent.
  private func goToLoginTout(intent: LoginIntent) {
    let loginTout = LoginToutViewController.configuredWith(loginIntent: intent)
    let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad
    let nav = UINavigationController(rootViewController: loginTout)
    nav.modalPresentationStyle = isIpad ? .formSheet : .fullScreen

    /// Presenting fullscreen over a dark video background can cause a black flash since UIKit briefly shows the default window background.
    /// Setting the nav controller's background to match the login screen prevents that.
    if !isIpad {
      nav.view.backgroundColor = Colors.Background.Surface.primary.uiColor()
    }

    self.present(nav, animated: true)
  }

  private func goToCreatorProfile(for item: VideoFeedItem) {
    let vc = ProjectCreatorViewController.configuredWith(project: item)
    vc.isPresentedFromVideoFeed = true

    let nav = UINavigationController(rootViewController: vc)

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      nav.modalPresentationStyle = .formSheet
    } else {
      nav.modalPresentationStyle = .fullScreen
    }

    self.present(nav, animated: true)
  }

  private func goToProjectPage(for item: VideoFeedItem) {
    let vc = ProjectPageViewController.navigationController(
      withProjectOrParam: .right(Param.slug(item.slug)),
      refInfo: RefInfo(.videoFeed)
    )
    vc.modalPresentationStyle = .fullScreen

    self.present(vc, animated: true)
  }
}

extension VideoFeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout _: UICollectionViewLayout,
    sizeForItemAt _: IndexPath
  ) -> CGSize {
    CGSize(width: floor(collectionView.bounds.width), height: floor(collectionView.bounds.height))
  }

  func collectionView(
    _: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    guard let cell = cell as? VideoFeedCell else { return }

    let items = self.viewModel.items

    guard indexPath.item < items.count else { return }

    let item = items[indexPath.item]

    cell.onCloseTapped = { [weak self] in self?.dismiss(animated: true) }
    cell.onCreatorTapped = { [weak self] in self?.goToCreatorProfile(for: item) }
    cell.onShareTapped = { [weak self] in self?.simpleAlert(title: "Share") }
    cell.onMoreTapped = { [weak self] in self?.simpleAlert(title: "More") }
    cell.onCTATapped = { [weak self] in self?.goToProjectPage(for: item) }

    cell.configureWith(
      item: Binding(
        get: { self.viewModel.items.first(where: { $0.id == item.id }) ?? item },
        set: { _ in }
      ),
      isSaved: self.viewModel.isSaved(projectId: item.id)
    )

    if let url = item.videoURL {
      cell.loadVideo(url: url)
    }

    /// Prefetch the next cell's preview image so it's ready before the user swipes.
    /// Cancel any in-flight prefetching first so rapid scrolling doesn't queue up old requests.
    let nextIndex = indexPath.item + 1

    self.previewImagePrefetcher?.stop()
    self.previewImagePrefetcher = nil

    if nextIndex < items.count,
       let nextPreviewURL = items[nextIndex].videoPreviewImageURL {
      let prefetcher = ImagePrefetcher(resources: [nextPreviewURL])

      prefetcher.start()

      self.previewImagePrefetcher = prefetcher
    }
  }

  /// Pauses and rewinds when a cell scrolls offscreen so the next appearance starts fresh.
  func collectionView(
    _: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    self.previewImagePrefetcher?.stop()
    self.previewImagePrefetcher = nil
    (cell as? VideoFeedCell)?.resetVideo()
  }

  // MARK: - Scroll based playback

  func scrollViewWillBeginDragging(_: UIScrollView) {
    self.isScrolling = true
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard !scrollView.isDragging else { return }

    self.isScrolling = false
    self.activateCurrentPageCell()
  }

  private func activateCurrentPageCell() {
    let pageHeight = self.collectionView.bounds.height

    guard pageHeight > 0 else { return }

    let currentPage = Int(round(self.collectionView.contentOffset.y / pageHeight))
    let activeIndexPath = IndexPath(item: currentPage, section: 0)

    for cell in self.collectionView.visibleCells.compactMap({ $0 as? VideoFeedCell }) {
      if self.collectionView.indexPath(for: cell) == activeIndexPath {
        cell.startPlayback()
      } else {
        cell.pausePlayback()
      }
    }
  }

  // MARK: - Helpers

  private func simpleAlert(title: String) {
    let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))

    self.present(alert, animated: true)
  }
}
