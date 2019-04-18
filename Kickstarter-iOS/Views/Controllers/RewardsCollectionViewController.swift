import Foundation
import Library
import KsApi
import Prelude

final class RewardsCollectionViewController: UICollectionViewController {
  private let viewModel = RewardsCollectionViewModel()
  private let dataSource = RewardsCollectionViewDataSource()

  private let layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.minimumLineSpacing .~ 0
      |> \.scrollDirection .~ .horizontal
  }()

  // Custom scrollView for paging
  private let hiddenPagingScrollView: UIScrollView = {
    UIScrollView()
      |> \.isPagingEnabled .~ true
      |> \.isHidden .~ true
  }()

  private var itemSize: CGSize {
    guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }

    return layout.itemSize
  }

  static func instantiate(with project: Project, refTag: RefTag?) -> RewardsCollectionViewController {
    let rewardsCollectionVC = RewardsCollectionViewController()
    rewardsCollectionVC.viewModel.inputs.configure(with: project, refTag: refTag)

    return rewardsCollectionVC
  }

  init() {
    super.init(collectionViewLayout: layout)

    let closeButton = UIBarButtonItem(image: UIImage(named: "icon--cross"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(closeButtonTapped))

    self.navigationItem.setLeftBarButton(closeButton, animated: false)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.hiddenPagingScrollView.delegate = self

    _ = self.collectionView
      |> \.alwaysBounceHorizontal .~ true
      |> \.dataSource .~ dataSource

    self.collectionView.register(RewardCell.self)

    // Disable standard gesture recognizer for UICollectionView scrollView and add custom
    self.collectionView?.addGestureRecognizer(self.hiddenPagingScrollView.panGestureRecognizer)
    self.collectionView?.panGestureRecognizer.isEnabled = false

    _ = self.hiddenPagingScrollView
      |> \.delegate .~ self

    _ = (self.hiddenPagingScrollView, self.view)
      |> ksr_addSubviewToParent()

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
      return
    }

    let collectionViewSize = self.collectionView.frame.size
    layout.itemSize = CGSize(width: collectionViewSize.width, height: self.collectionView.contentSize.height)

//    let pageSize = self.itemSize.width

//    self.collectionView.contentInset = UIEdgeInsets(
//      top: 0,
//      left: (self.view.frame.width - pageSize) / 2,
//      bottom: 0,
//      right: (self.view.frame.width - pageSize) / 2
//    )
//    self.configureHiddenScrollView()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.collectionView
      |> collectionViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadDataWithRewards
      .observeForUI()
      .observeValues { [weak self] rewards in
        self?.dataSource.load(rewards: rewards)
        self?.configureHiddenScrollView()
    }
  }

  // MARK: - Private Helpers
  private func configureHiddenScrollView() {
    // Calculate full width (with spacing) for contentSize
    let numberOfItemsInCollectionView = self.collectionView.numberOfItems(inSection: 0)

    let collectionViewWidth = CGFloat(numberOfItemsInCollectionView) * self.itemSize.width

    self.hiddenPagingScrollView.bounds = CGRect(origin: .zero, size: self.itemSize)

    // Set contentSize
    self.hiddenPagingScrollView.contentSize = CGSize(width: collectionViewWidth, height: itemSize.height)

//    DispatchQueue.main.async {
//      self.collectionView.contentOffset = CGPoint(x: -self.collectionView.contentInset.left, y: 0)
//    }
  }

  // MARK: - Public Functions
  @objc func closeButtonTapped() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

// MARK: - UIScrollViewDelegate
extension RewardsCollectionViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView == self.hiddenPagingScrollView else {
      return
    }
    // Override native UICollectionView scroll events

    // Scroll view's offset ratio (will be used to convert to collection view offset)
    let ratio = scrollView.contentOffset.x / scrollView.contentSize.width

    // Include offset from left
    var contentOffset = scrollView.contentOffset
    contentOffset.x = ratio * self.collectionView.contentSize.width - self.collectionView.contentInset.left

    // ? is necessary (don't know why though)
    self.collectionView?.contentOffset = contentOffset
  }
}

// MARK: Styles
private var collectionViewStyle = { collectionView -> UICollectionView in
  collectionView
    |> \.backgroundColor .~ .ksr_grey_200
    |> \.isPagingEnabled .~ true
    |> \.clipsToBounds .~ false
    |> \.allowsSelection .~ true
}
