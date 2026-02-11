import AVFoundation
import KsApi
import ReactiveSwift
import UIKit

final class VideoFeedViewController: UIViewController {
  // MARK: - Types

  /// Diffable data source still needs a "section id" type, even if there's only one section.
  private typealias Section = Int
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, VideoFeedItem>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, VideoFeedItem>

  // MARK: - Dependencies

  /// The project we’re showing in the feed (same project repeated for 20 items in this spike).
  private let project: Project

  /// View model owns the list-building logic from the project + video URL.
  private let viewModel: VideoFeedViewModelType

  /// Holds ReactiveSwift disposables so we can clean up on deinit.
  private let disposable = CompositeDisposable()

  // MARK: - UI

  private lazy var collectionView: UICollectionView = {
    /// Full-screen, vertically-paging collection view like TikTok/Reels.
    let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.backgroundColor = .black
    cv.isPagingEnabled = true
    cv.showsVerticalScrollIndicator = false
    cv.decelerationRate = .fast
    cv.contentInsetAdjustmentBehavior = .never
    cv.register(VideoFeedCell.self, forCellWithReuseIdentifier: VideoFeedCell.reuseIdentifier)

    /// We rely on scroll view delegate callbacks to start/stop playback.
    cv.delegate = self
    return cv
  }()

  // MARK: - Data

  /// The 20 feed items currently shown in the list.
  private var items: [VideoFeedItem] = []

  /// Diffable data source that renders `items` into cells.
  private var dataSource: DataSource!

  // MARK: - Playback

  /// One player per item (no warming / preheating strategy).
  /// Players are created immediately once we have the items list.
  private var playersByID: [String: AVPlayer] = [:]

  /// Tracks which cell should currently be playing.
  private var currentActiveIndexPath: IndexPath?

  // MARK: - Init

  init(project: Project, viewModel: VideoFeedViewModelType? = nil) {
    self.project = project
    self.viewModel = viewModel ?? VideoFeedViewModel(project: project)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    disposable.dispose()
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    view.addSubview(self.collectionView)
    NSLayoutConstraint.activate([
      self.collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      self.collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      self.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    self.setUpDataSource()
    self.bindViewModel()

    /// Kick off view model work.
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    /// Stop playback when leaving the screen so audio doesn’t keep going.
    for case let cell as VideoFeedCell in collectionView.visibleCells {
      cell.setActive(false)
    }
  }

  // MARK: - Binding

  public override func bindViewModel() {
    /// Whenever the VM publishes a new list, rebuild players + reload the UI.
    self.disposable += self.viewModel.outputs.items.observeValues { [weak self] newItems in
      guard let self else { return }

      self.items = newItems

      /// Create every player up front so swipes feel instant.
      self.buildAllPlayersImmediately(for: newItems)

      /// Render the list into the collection view.
      self.applySnapshot()

      /// Autoplay the first cell after layout has a chance to happen.
      DispatchQueue.main.async { [weak self] in
        self?.setActiveCell(to: IndexPath(item: 0, section: 0))
      }
    }
  }

  private func buildAllPlayersImmediately(for items: [VideoFeedItem]) {
    /// Reset any old players when the feed content changes.
    self.playersByID.removeAll()

    /// This is intentionally “simple + heavy”: one AVPlayer per item, created right away.
    for item in items {
      let asset = AVURLAsset(url: item.videoURL)
      let playerItem = AVPlayerItem(asset: asset)
      let player = AVPlayer(playerItem: playerItem)

      /// We want playback to stop at end (no looping in this spike).
      player.actionAtItemEnd = .pause

      self.playersByID[item.id] = player
    }
  }

  // MARK: - Layout

  private func makeLayout() -> UICollectionViewLayout {
    /// Full-screen cell (1 item per “page”).
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 0

    return UICollectionViewCompositionalLayout(section: section)
  }

  // MARK: - Data Source

  private func setUpDataSource() {
    /// Cell provider is where we connect each `VideoFeedItem` to a `VideoFeedCell`.
    self
      .dataSource = DataSource(
        collectionView: self
          .collectionView
      ) { [weak self] collectionView, indexPath, item in
        guard let self else { return nil }

        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: VideoFeedCell.reuseIdentifier,
          for: indexPath
        ) as? VideoFeedCell else { return nil }

        /// Apply static text/UI.
        cell.configure(with: item)

        /// Give the cell its player (one per item).
        cell.setPlayer(self.player(for: item))

        /// Only the snapped/active cell should play.
        cell.setActive(self.currentActiveIndexPath == indexPath)

        /// Spike-level callbacks.
        cell.onCloseTapped = { [weak self] in self?.dismiss(animated: true) }
        cell.onCTAButtonTapped = { [weak self] in
          self?.simpleAlert(title: "CTA", message: "Tapped: \(item.ctaTitle)")
        }

        return cell
      }
  }

  private func applySnapshot() {
    /// Single section = `0`.
    var snapshot = Snapshot()
    snapshot.appendSections([0])
    snapshot.appendItems(self.items, toSection: 0)
    self.dataSource.apply(snapshot, animatingDifferences: false)
  }

  private func player(for item: VideoFeedItem) -> AVPlayer {
    /// Return the pre-created player if available.
    if let player = playersByID[item.id] {
      return player
    }

    /// Fallback path (should be rare in this spike).
    let asset = AVURLAsset(url: item.videoURL)
    let playerItem = AVPlayerItem(asset: asset)
    let player = AVPlayer(playerItem: playerItem)
    player.actionAtItemEnd = .pause
    self.playersByID[item.id] = player
    return player
  }

  // MARK: - Active cell management

  private func centeredIndexPath() -> IndexPath? {
    /// `bounds` already includes `contentOffset`, so we do NOT add it here.
    /// This returns the cell that is visually centered on screen (i.e. the snapped page).
    let center = CGPoint(x: collectionView.bounds.midX, y: self.collectionView.bounds.midY)
    return self.collectionView.indexPathForItem(at: center)
  }

  private func setActiveCell(to indexPath: IndexPath?) {
    /// First: pause all visible cells so only one can play.
    for case let cell as VideoFeedCell in collectionView.visibleCells {
      cell.setActive(false)
    }

    guard let indexPath else { return }
    self.currentActiveIndexPath = indexPath

    /// Then: activate the snapped/centered cell.
    if let cell = collectionView.cellForItem(at: indexPath) as? VideoFeedCell {
      cell.setActive(true)
    }
  }

  private func updateActiveCellAfterSnap() {
    /// Called after scrolling settles so we start playback on the correct page.
    self.setActiveCell(to: self.centeredIndexPath())
  }

  // MARK: - Helpers

  private func simpleAlert(title: String, message: String) {
    /// Simple spike-only alert helper.
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}

extension VideoFeedViewController: UICollectionViewDelegate {
  func collectionView(
    _: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    guard let cell = cell as? VideoFeedCell else { return }
    guard indexPath.item < self.items.count else { return }

    /// Cells can be reused; make sure the right item + player are applied.
    let item = self.items[indexPath.item]
    cell.configure(with: item)
    cell.setPlayer(self.player(for: item))

    /// First page should autoplay as soon as it appears.
    if self.currentActiveIndexPath == nil && indexPath.item == 0 {
      self.setActiveCell(to: indexPath)
    }
  }

  func collectionView(
    _: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    /// Safety: pause anything that scrolled off screen.
    (cell as? VideoFeedCell)?.setActive(false)
  }

  // MARK: UIScrollViewDelegate snap points

  func scrollViewDidEndDecelerating(_: UIScrollView) {
    /// User finished a swipe and the page snapped into place.
    self.updateActiveCellAfterSnap()
  }

  func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
    /// If there’s no deceleration, snapping is already done here.
    if !decelerate { self.updateActiveCellAfterSnap() }
  }

  func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
    /// Handles programmatic scrolls (if you add them later).
    self.updateActiveCellAfterSnap()
  }
}
