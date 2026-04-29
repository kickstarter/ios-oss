import KDS
import UIKit

/// Full-screen swipeable video feed.
///   - Full-screen paging
///   - Plain data source driven by VideoFeedViewModel
final class VideoFeedViewController: UIViewController {
  private enum Constants {
    static let backgroundColor = KDS.Colors.Text.secondary.uiColor()
  }

  private let viewModel = VideoFeedViewModel()
  private let dataSource = VideoFeedDataSource()

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

    self.setupCollectionView()
    self.bindViewModel()

    self.viewModel.viewDidLoad()
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
      self.dataSource.load(self.viewModel.items)
      self.collectionView.reloadData()
    } onChange: { [weak self] in
      DispatchQueue.main.async { [weak self] in
        self?.bindViewModel()
      }
    }
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

    /// Re-configure after wiring callbacks so SwiftUI picks up the closures.
    cell.configureWith(value: item)
  }

  // MARK: - Helpers

  private func simpleAlert(title: String) {
    let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    self.present(alert, animated: true)
  }
}
