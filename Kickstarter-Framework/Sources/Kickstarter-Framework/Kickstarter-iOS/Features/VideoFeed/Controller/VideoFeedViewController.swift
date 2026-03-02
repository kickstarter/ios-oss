import AVFoundation
import KsApi
import ReactiveSwift
import UIKit

/// Full-screen swipeable video feed.
/// Finite batch (no pagination).
/// Simple model: 1 AVPlayer per item, created immediately when items load.
final class VideoFeedViewController: UIViewController {
  private enum Constants {
    static let backgroundColor = VideoFeedColors.black
    static let initialIndexPath = IndexPath(item: 0, section: 0)

    /// Sheet sizing.
    static let sheetCornerRadius: CGFloat = 16
    static let sheetHorizontalInset: CGFloat = 0

    /// Toast.
    static let toastHorizontalInset: CGFloat = 16
    static let toastTopInset: CGFloat = 8
    static let toastHiddenOffset: CGFloat = -80
    static let toastShowDuration: TimeInterval = 0.25
    static let toastHideDelay: TimeInterval = 2.5

    static let notInterestedToastMessage = "You'll see fewer videos like this"
    static let moreLikeThisToastMessage = "We'll suggest more videos like this"
  }

  private enum Section: Hashable { case main }
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

  /// Reusable confirmation toast shown after actions like "Not interested".
  private let confirmationToast = VideoFeedConfirmationToastView()
  private var toastTopConstraint: NSLayoutConstraint?
  private var toastHideWorkItem: DispatchWorkItem?

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

    view.backgroundColor = Constants.backgroundColor

    self.setUpCollectionView()
    self.setUpDataSource()
    setUpConfirmationToast()
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

    /// Pause everything when leaving the screen so audio never leaks.
    self.setActiveCell(to: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()

    /// Under memory pressure, drop cached players.
    self.playersByID.removeAll()
  }

  // MARK: - Layout

  /// Uses Compositional Layout for full-screen vertical paging.
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

  private func setUpCollectionView() {
    self.collectionView.translatesAutoresizingMaskIntoConstraints = false
    self.collectionView.backgroundColor = Constants.backgroundColor
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

  private func setUpDataSource() {
    self
      .dataSource = DataSource(
        collectionView: self
          .collectionView
      ) { [weak self] collectionView, indexPath, item in
        guard let self else { return nil }
        return self.makeCell(collectionView: collectionView, indexPath: indexPath, item: item)
      }
  }

  /// Keeps the data source closure tiny and easy to read.
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

    /// Configure static UI and attach the already-created player.
    cell.configure(with: item)
    cell.setPlayer(self.player(for: item))

    /// Only the snapped cell should play.
    cell.setActive(self.currentActiveIndexPath == indexPath)

    cell.onCloseTapped = { [weak self] in self?.dismiss(animated: true) }
    cell.onCTAButtonTapped = { [weak self] in
      self?.simpleAlert(title: "CTA", message: "Tapped: \(item.ctaTitle)")
    }

    /// Share + More sheets.
    cell.onShareTapped = { [weak self] in
      self?.presentShareSheet(for: item)
    }
    cell.onMoreTapped = { [weak self] in
      self?.presentMoreMenu(for: item)
    }

    return cell
  }

  // MARK: - Sheets

  private func presentShareSheet(for item: VideoFeedItem) {
    let sheet = VideoFeedShareProjectSheetViewController(
      titleText: item.title,
      creatorText: item.creator,
      /// No creator image URL wired in this spike yet.
      imageURL: nil
    )
    self.presentContentHuggingSheet(sheet)
  }

  private func presentMoreMenu(for item: VideoFeedItem) {
    let sheet = VideoFeedMoreMenuSheetViewController()

    sheet.onNotInterestedTapped = { [weak self, weak sheet] in
      /// Dismiss the menu first, then show the reasons sheet.
      sheet?.dismiss(animated: true) {
        self?.presentNotInterestedReasons(for: item)
      }
    }

    sheet.onMoreLikeThisTapped = { [weak self, weak sheet] in
      /// Dismiss the menu first, then confirm with a toast.
      sheet?.dismiss(animated: true) {
        self?.showConfirmationToast(message: Constants.moreLikeThisToastMessage)
      }
    }

    sheet.onDismissRequested = { [weak sheet] in
      sheet?.dismiss(animated: true)
    }

    self.presentContentHuggingSheet(sheet)
  }

  private func presentNotInterestedReasons(for _: VideoFeedItem) {
    let sheet = VideoFeedNotInterestedReasonsSheetViewController()

    sheet.onReasonSelected = { [weak self, weak sheet] _ in
      /// Dismiss the reasons first, then confirm with a toast.
      sheet?.dismiss(animated: true) {
        self?.showConfirmationToast(message: Constants.notInterestedToastMessage)
      }
    }

    self.presentContentHuggingSheet(sheet)
  }

  /// Presents a bottom sheet that hugs its content height.
  private func presentContentHuggingSheet(_ viewController: UIViewController) {
    viewController.modalPresentationStyle = .pageSheet

    /// Force a layout pass so we can compute a stable fitting height.
    viewController.loadViewIfNeeded()
    viewController.view.setNeedsLayout()
    viewController.view.layoutIfNeeded()

    let targetWidth = view.bounds.width - (Constants.sheetHorizontalInset * 2)
    let targetSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
    let fitted = viewController.view.systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )
    viewController.preferredContentSize = CGSize(width: targetWidth, height: fitted.height)

    if let sheet = viewController.sheetPresentationController {
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = Constants.sheetCornerRadius
      sheet.prefersScrollingExpandsWhenScrolledToEdge = false

      /// iOS 18 min: use a single custom detent that matches the fitted content height.
      let id = UISheetPresentationController.Detent.Identifier("contentHeight")
      sheet.detents = [
        .custom(identifier: id) { [weak viewController] _ in
          viewController?.preferredContentSize.height ?? 0
        }
      ]
      sheet.selectedDetentIdentifier = id
      sheet.largestUndimmedDetentIdentifier = id
    }

    present(viewController, animated: true)
  }

  // MARK: - ViewModel Binding

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
    self.buildAllPlayersImmediately(for: items)

    var snapshot: Snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)

    /// No animation to avoid jank during initial load.
    self.dataSource.apply(snapshot, animatingDifferences: false)

    /// Autoplay the first item after the collection view lays out its cells.
    DispatchQueue.main.async { [weak self] in
      self?.setActiveCell(to: Constants.initialIndexPath)
    }
  }

  // MARK: - Playback

  /// Create one player per item (simple + predictable).
  private func buildAllPlayersImmediately(for items: [VideoFeedItem]) {
    self.playersByID.removeAll()

    for item in items {
      let playerItem = AVPlayerItem(url: item.videoURL)
      let player = AVPlayer(playerItem: playerItem)
      player.actionAtItemEnd = .pause
      self.playersByID[item.id] = player
    }
  }

  /// Returns the cached player for this item (or creates one as a fallback).
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
    /// `bounds` already includes `contentOffset`, so we do NOT add it again.
    let center = CGPoint(x: collectionView.bounds.midX, y: self.collectionView.bounds.midY)
    return self.collectionView.indexPathForItem(at: center)
  }

  /// Pauses all visible cells and activates just one index path.
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

  /// Called after scrolling settles so the snapped cell plays.
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
    /// When paging settles, play the snapped cell.
    self.updateActiveCellAfterSnap()
  }

  func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
    /// If the user stops dragging without decelerating, treat it like "settled".
    if !decelerate { self.updateActiveCellAfterSnap() }
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
}

// MARK: - Minimal alert helper

private extension VideoFeedViewController {
  func simpleAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }

  func setUpConfirmationToast() {
    self.confirmationToast.alpha = 0
    view.addSubview(self.confirmationToast)

    let top = self.confirmationToast.topAnchor.constraint(
      equalTo: view.safeAreaLayoutGuide.topAnchor,
      constant: Constants.toastHiddenOffset
    )
    self.toastTopConstraint = top

    NSLayoutConstraint.activate([
      top,
      self.confirmationToast.leadingAnchor.constraint(
        equalTo: view.leadingAnchor,
        constant: Constants.toastHorizontalInset
      ),
      self.confirmationToast.trailingAnchor.constraint(
        equalTo: view.trailingAnchor,
        constant: -Constants.toastHorizontalInset
      )
    ])
  }

  func showConfirmationToast(message: String) {
    self.toastHideWorkItem?.cancel()

    self.confirmationToast.configure(with: .init(message: message, undoTapped: nil))
    self.toastTopConstraint?.constant = Constants.toastTopInset

    UIView.animate(withDuration: Constants.toastShowDuration, delay: 0, options: [.curveEaseOut]) {
      self.confirmationToast.alpha = 1
      self.view.layoutIfNeeded()
    }

    let workItem = DispatchWorkItem { [weak self] in
      self?.hideConfirmationToast()
    }
    self.toastHideWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.toastHideDelay, execute: workItem)
  }

  func hideConfirmationToast() {
    self.toastTopConstraint?.constant = Constants.toastHiddenOffset

    UIView.animate(withDuration: Constants.toastShowDuration, delay: 0, options: [.curveEaseIn]) {
      self.confirmationToast.alpha = 0
      self.view.layoutIfNeeded()
    }
  }
}
