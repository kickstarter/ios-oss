import AVFoundation
import KsApi
import ReactiveSwift
import UIKit

/// Full-screen swipeable video feed.
/// Finite batch (no pagination).
final class VideoFeedViewController: UIViewController {
  private enum Section: Hashable {
    case main
  }

  private typealias DataSource = UICollectionViewDiffableDataSource<Section, VideoFeedItem>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, VideoFeedItem>

  private let viewModel: VideoFeedViewModelType

  /// One player per feed item for smooth snapping playback.
  private var playersByID: [String: AVPlayer] = [:]

  private var items: [VideoFeedItem] = []

  /// Tracks which cell should currently be playing.
  private var currentActiveIndexPath: IndexPath?

  private let collectionView: UICollectionView
  private var dataSource: DataSource!

  private var itemsDisposable: Disposable?

  init(project: Project) {
    self.viewModel = VideoFeedViewModel(project: project)

    let layout = VideoFeedViewController.makeLayout()
    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    itemsDisposable?.dispose()
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .black

    self.setupCollectionView()
    self.setupDataSource()
    self.bindViewModel()

    /// Kick off initial finite batch load.
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    /// Ensure the currently snapped cell plays when the screen appears.
    self.updateActiveCellAfterSnap()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    /// Pause everything when leaving the screen so audio won't leak.
    self.setActiveCell(to: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()

    /// Drop cached players if we're getting memory warnings.
    self.playersByID.removeAll()
  }

  // MARK: - Layout

  private static func makeLayout() -> UICollectionViewLayout {
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

  private func setupCollectionView() {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = false
    self.collectionView.backgroundColor = .black
    self.collectionView.isPagingEnabled = true
    self.collectionView.showsVerticalScrollIndicator = false
    self.collectionView.contentInsetAdjustmentBehavior = .never

    self.collectionView.delegate = self

    self.collectionView.register(
      VideoFeedCell.self,
      forCellWithReuseIdentifier: VideoFeedCell.reuseIdentifier
    )

    view.addSubview(self.collectionView)

    NSLayoutConstraint.activate([
      self.collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      self.collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      self.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  // MARK: - Data Source

  private func setupDataSource() {
    self
      .dataSource = DataSource(
        collectionView: self
          .collectionView
      ) { [weak self] collectionView, indexPath, item in
        guard let self else { return nil }

        return self.makeCell(collectionView: collectionView, indexPath: indexPath, item: item)
      }
  }

  private func makeCell(
    collectionView: UICollectionView,
    indexPath: IndexPath,
    item: VideoFeedItem
  ) -> UICollectionViewCell? {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: VideoFeedCell.reuseIdentifier,
      for: indexPath
    ) as? VideoFeedCell else {
      return nil
    }

    /// Configure static UI and attach the  player.
    cell.configure(with: item)
    cell.setPlayer(self.player(for: item))

    /// Only the snapped cell should play.
    cell.setActive(self.currentActiveIndexPath == indexPath)

    cell.onCloseTapped = { [weak self] in self?.dismiss(animated: true) }
    cell.onCTAButtonTapped = { [weak self] in
      self?.simpleAlert(title: "CTA", message: "Tapped: \(item.ctaTitle)")
    }

    /// Wire up actions
    cell.onShareTapped = { [weak self] in
      self?.presentShareSheet(for: item)
    }

    cell.onMoreTapped = { [weak self] in
      self?.presentMoreMenu(for: item)
    }

    return cell
  }

  // MARK: - Binding

  public override func bindViewModel() {
    self.itemsDisposable = self.viewModel.outputs.items
      .observe(on: UIScheduler())
      .observeValues { [weak self] newItems in
        self?.applySnapshot(items: newItems)
      }
  }

  private func applySnapshot(items: [VideoFeedItem]) {
    self.items = items

    /// Create all players up-front so swipes feel instant.
    self.buildAllVideoPlayers(for: items)

    var snapshot: Snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)

    /// No animation to avoid jank during initial load.
    self.dataSource.apply(snapshot, animatingDifferences: false)

    /// Autoplay the first item after the collection view lays out its cells.
    DispatchQueue.main.async { [weak self] in
      self?.setActiveCell(to: IndexPath(item: 0, section: 0))
    }
  }

  // MARK: - Playback

  private func buildAllVideoPlayers(for items: [VideoFeedItem]) {
    self.playersByID.removeAll()

    for item in items {
      let playerItem = AVPlayerItem(url: item.videoURL)
      let player = AVPlayer(playerItem: playerItem)
      player.actionAtItemEnd = .pause

      self.playersByID[item.id] = player
    }
  }

  /// Returns the cached player from item (or creates one as a fallback).
  private func player(for item: VideoFeedItem) -> AVPlayer {
    if let player = playersByID[item.id] {
      return player
    }

    let playerItem = AVPlayerItem(url: item.videoURL)
    let player = AVPlayer(playerItem: playerItem)
    player.actionAtItemEnd = .pause

    self.playersByID[item.id] = player

    return player
  }

  /// Gets the item currently centered on screen.
  private func centeredIndexPath() -> IndexPath? {
    let center = CGPoint(x: collectionView.bounds.midX, y: self.collectionView.bounds.midY)

    return self.collectionView.indexPathForItem(at: center)
  }

  private func setActiveCell(to indexPath: IndexPath?) {
    for case let cell as VideoFeedCell in collectionView.visibleCells {
      cell.setActive(false)
    }

    self.currentActiveIndexPath = indexPath

    guard let indexPath,
          let cell = collectionView.cellForItem(at: indexPath) as? VideoFeedCell else {
      return
    }

    cell.setActive(true)
  }

  /// Called after scrolling finishes snapping into place
  private func updateActiveCellAfterSnap() {
    self.setActiveCell(to: self.centeredIndexPath())
  }
}

// MARK: - UICollectionViewDelegate

extension VideoFeedViewController: UICollectionViewDelegate {
  func scrollViewWillBeginDragging(_: UIScrollView) {
    /// Pause immediately when the user starts swiping.
    self.setActiveCell(to: nil)
  }

  func scrollViewDidEndDecelerating(_: UIScrollView) {
    self.updateActiveCellAfterSnap()
  }

  func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.updateActiveCellAfterSnap()
    }
  }

  func collectionView(
    _: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    /// Ensure reused cells get their correct player and active state.
    guard indexPath.item < self.items.count,
          let cell = cell as? VideoFeedCell else { return }

    let item = self.items[indexPath.item]

    cell.configure(with: item)
    cell.setPlayer(self.player(for: item))
    cell.setActive(self.currentActiveIndexPath == indexPath)
  }

  // MARK: - Helpers

  func simpleAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }

  func presentShareSheet(for item: VideoFeedItem) {
    let vc = VideoFeedShareProjectSheetViewController(
      titleText: item.title,
      creatorText: item.creator,
      imageURL: nil
    )
    present(vc, animated: true)
  }

  func presentMoreMenu(for item: VideoFeedItem) {
    let vc = VideoFeedMoreMenuSheetViewController()

    vc.onDismissRequested = { [weak vc] in
      vc?.dismiss(animated: true)
    }

    vc.onNotInterestedTapped = { [weak self, weak vc] in
      /// Dismiss the menu first so the reasons sheet stacks cleanly.
      vc?.dismiss(animated: true) {
        self?.presentNotInterestedReasons(for: item)
      }
    }
    present(vc, animated: true)
  }

  func presentNotInterestedReasons(for _: VideoFeedItem) {
    let vc = VideoFeedNotInterestedReasonsSheetViewController()

    vc.onReasonSelected = { [weak vc] _ in
      /// simply dismiss for now
      vc?.dismiss(animated: true)
    }

    present(vc, animated: true)
  }
}
