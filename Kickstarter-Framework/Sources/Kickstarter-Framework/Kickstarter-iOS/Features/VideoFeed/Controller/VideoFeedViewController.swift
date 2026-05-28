import AVFoundation
import FirebaseCrashlytics
import KDS
import Kingfisher
import KsApi
import Library
import UIKit

/// Full-screen swipeable video feed.
///   - Full-screen paging
///   - Plain data source driven by `VideoFeedViewModel`
///   - Cells start loading video on `willDisplay` and reset on `didEndDisplaying`
///   - Pauses video on background, resumes on foreground
final class VideoFeedViewController: UIViewController {
  private enum Constants {
    static let backgroundColor = KDS.Colors.Icon.dark.uiColor()
  }

  private let viewModel = VideoFeedViewModel()
  private let dataSource = VideoFeedDataSource()

  private var lifecycleObservers: [any NSObjectProtocol] = []
  private var previewImagePrefetcher: ImagePrefetcher?

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

    self.viewModel.viewDidLoad()
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
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
        self.bindViewModel()
      }
    }
  }

  /// Reloads the collection view with a fresh set of fetched items.
  private func updateFeedWithFetchedItems(_ newItems: [VideoFeedItem]) {
    self.dataSource.load(newItems)
    self.collectionView.reloadData()
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
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      #if DEBUG
        print("`VideoFeedViewController`: Failed to configure audio session:", error.localizedDescription)
      #endif

      Crashlytics.crashlytics().record(error: error)
    }
  }

  // MARK: - App lifecycle

  /// Pause video on background and resumes on foreground.
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
      }
    ]
  }

  private func pauseVisibleCell() {
    self.collectionView.visibleCells
      .compactMap { $0 as? VideoFeedCell }
      .forEach { $0.pausePlayback() }
  }

  private func resumeVisibleCell() {
    self.collectionView.visibleCells
      .compactMap { $0 as? VideoFeedCell }
      .forEach { $0.resumePlayback() }
  }

  // MARK: - Navigation

  private func goToCreatorProfile(for item: VideoFeedItem) {
    let vc = ProjectCreatorViewController.configuredWith(project: item)

    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .formSheet
      self.present(nav, animated: true)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
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
    collectionView.bounds.size
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
      value: item,
      isSaved: self.viewModel.isSaved(id: item.id)
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

  // MARK: - Helpers

  private func simpleAlert(title: String) {
    let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))

    self.present(alert, animated: true)
  }
}
