import AVFoundation
import FirebaseCrashlytics
import KDS
import Library
import UIKit

/// Full-screen swipeable video feed.
///   - Full-screen paging
///   - Plain data source driven by `VideoFeedViewModel`
///   - Scrolling locked until the first video is ready to play
///   - Cells starts to load video on `willDisplay` and loops on `didEndDisplaying`
///   - Pauses video on background, resumes on foreground
final class VideoFeedViewController: UIViewController {
  private enum Constants {
    static let backgroundColor = KDS.Colors.Icon.dark.uiColor()
  }

  private let viewModel = VideoFeedViewModel()
  private let dataSource = VideoFeedDataSource()

  private var lifecycleObservers: [any NSObjectProtocol] = []

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
    self.navigationController?.navigationBar.isHidden = true

    self.configureAudioSession()
    self.observeAppLifecycle()

    self.setupCollectionView()
    self.bindViewModel()

    self.viewModel.viewDidLoad()
  }

  deinit {
    self.lifecycleObservers.forEach(NotificationCenter.default.removeObserver)
  }

  // MARK: - CollectionView

  private func setupCollectionView() {
    self.collectionView.dataSource = self.dataSource
    self.collectionView.delegate = self
    self.collectionView.translatesAutoresizingMaskIntoConstraints = false
    self.collectionView.backgroundColor = Constants.backgroundColor
    self.collectionView.isPagingEnabled = true
    self.collectionView.isScrollEnabled = false
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
      self.dataSource.load(self.viewModel.items)
      self.collectionView.reloadData()
    } onChange: { [weak self] in
      DispatchQueue.main.async { [weak self] in
        self?.bindViewModel()
      }
    }
  }

  // MARK: - Scroll locking

  /// Unlocks scrolling once the first video is ready to play.
  private func unlockScrollingIfNeeded() {
    guard !self.collectionView.isScrollEnabled else { return }

    self.collectionView.isScrollEnabled = true
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
    cell.onCreatorTapped = { [weak self] in self?.simpleAlert(title: "Creator") }
    cell.onSaveTapped = { [weak self] in self?.simpleAlert(title: "Saved") }
    cell.onShareTapped = { [weak self] in self?.simpleAlert(title: "Share") }
    cell.onMoreTapped = { [weak self] in self?.simpleAlert(title: "More") }
    cell.onVideoReady = { [weak self] in self?.unlockScrollingIfNeeded() }
    /// Failed videos still need scroll unlocked so the user can swipe past.
    cell.onVideoFailed = { [weak self] in self?.unlockScrollingIfNeeded() }

    /// Re-configure after wiring callbacks so SwiftUI picks up the closures.
    cell.configureWith(value: item)

    if let url = item.videoURL {
      cell.loadVideo(url: url)
    }
  }

  /// Pauses and rewinds when a cell scrolls offscreen so the next appearance starts fresh.
  func collectionView(
    _: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    (cell as? VideoFeedCell)?.resetVideo()
  }

  // MARK: - Helpers

  private func simpleAlert(title: String) {
    let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))

    self.present(alert, animated: true)
  }
}
