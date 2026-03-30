import KDS
import UIKit

/// Full-screen swipeable video feed
///   - Full-screen paging
///   - Plain data source driven by VideoFeedViewModel
final class VideoFeedViewController: UIViewController {
  private enum Constants {
    static let backgroundColor = KDS.Colors.Background.Surface.secondary.uiColor()
  }

  private let viewModel = VideoFeedViewModel()
  private let dataSource = VideoFeedDataSource()

  private lazy var collectionView: UICollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: VideoFeedViewController.setupCollectionViewLayout()
  )

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = Constants.backgroundColor

    self.setupCollectionView()
    self.bindViewModel()

    self.viewModel.viewDidLoad()
  }

  // MARK: - Layout

  private static func setupCollectionViewLayout() -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.itemSize = UIScreen.main.bounds.size
    layout.minimumLineSpacing = 0
    return layout
  }

  // MARK: - CollectionView

  private func setupCollectionView() {
    self.collectionView.dataSource = self.dataSource
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
    self.viewModel.onItemsChanged = { [weak self] items in
      guard let self else { return }

      DispatchQueue.main.async {
        self.dataSource.load(items)
        self.collectionView.reloadData()
      }
    }
  }
}
