import Foundation
import Library
import KsApi
import Prelude

final class RewardsCollectionViewController: UICollectionViewController {
  private let dataSource = RewardsCollectionViewDataSource()
  private let viewModel = RewardsCollectionViewModel()

  // Hidden scroll view used for paging
  private let hiddenPagingScrollView: UIScrollView = {
    UIScrollView()
      |> \.backgroundColor .~ UIColor.red
      |> \.isPagingEnabled .~ true
      |> \.isHidden .~ true
  }()

  private let layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.minimumLineSpacing .~ Styles.grid(3)
      |> \.sectionInset .~ .init(all: Styles.grid(6))
      |> \.scrollDirection .~ .horizontal
  }()

  private let peekAmountInset = Styles.grid(3)

  private var flowLayout: UICollectionViewFlowLayout? {
    return self.collectionViewLayout as? UICollectionViewFlowLayout
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

    _ = closeButton
      |> \.width .~ Styles.minTouchSize.width
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }

    _ = self
      |> \.title %~ { _ in Strings.Back_this_project() }

    self.navigationItem.setLeftBarButton(closeButton, animated: false)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.collectionView
      |> \.dataSource .~ dataSource

    self.collectionView.register(RewardCell.self)

    self.configureHiddenScrollView()

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let layout = self.flowLayout else { return }

    let sectionInsets = layout.sectionInset
    let topBottomInsets = sectionInsets.top + sectionInsets.bottom
    let collectionViewSize = self.collectionView.frame.size

    let itemHeight = self.collectionView.contentSize.height - topBottomInsets
    var itemWidth = collectionViewSize.width - sectionInsets.left - 2 * peekAmountInset

    if [.landscapeLeft, .landscapeRight].contains(UIDevice.current.orientation) {
      itemWidth = collectionViewSize.width / 3 - sectionInsets.left - 2 * peekAmountInset
    }

    layout.itemSize = CGSize(width: itemWidth, height: itemHeight)

    self.updateHiddenScrollViewBounds()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.collectionView
      |> collectionViewStyle

    _ = self.collectionView.panGestureRecognizer
      |> \.isEnabled .~ false

  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadDataWithRewards
      .observeForUI()
      .observeValues { [weak self] rewards in
        self?.dataSource.load(rewards: rewards)
    }
  }

  private func configureHiddenScrollView() {
    // Add custom paging scrollView
    self.view.addSubview(self.hiddenPagingScrollView)

    _ = self.hiddenPagingScrollView
      |> \.delegate .~ self

    // Disable standard gesture recognizer for UICollectionView scrollView and add custom
    self.collectionView.addGestureRecognizer(self.hiddenPagingScrollView.panGestureRecognizer)
  }

  private func updateHiddenScrollViewBounds() {
    let numberOfItemsInCollectionView = self.collectionView.numberOfItems(inSection: 0)

    guard let layout = flowLayout else { return }

    let itemSize = layout.itemSize
    let interItemSpacing = layout.minimumInteritemSpacing
    let totalItemWidth = itemSize.width + interItemSpacing

    let collectionViewWidth = CGFloat(numberOfItemsInCollectionView) * totalItemWidth

    self.hiddenPagingScrollView.frame = CGRect(x: 0, y: 0, width: totalItemWidth, height: itemSize.height)
    self.hiddenPagingScrollView.bounds = CGRect(x: 0, y: 0, width: totalItemWidth, height: itemSize.height)
    self.hiddenPagingScrollView.contentSize = CGSize(width: collectionViewWidth, height: itemSize.height)
  }

  // MARK: - Public Functions
  @objc func closeButtonTapped() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension RewardsCollectionViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView == self.hiddenPagingScrollView else { return }

    print("content offset x: \(scrollView.contentOffset.x)")

    let adjustedContentOffsetX = scrollView.contentOffset.x - peekAmountInset

    self.collectionView.contentOffset.x = adjustedContentOffsetX
  }
}

// MARK: Styles
private var collectionViewStyle = { collectionView -> UICollectionView in
  collectionView
    |> \.alwaysBounceHorizontal .~ true
    |> \.backgroundColor .~ .ksr_grey_200
    |> \.isPagingEnabled .~ true
    |> \.clipsToBounds .~ false
    |> \.allowsSelection .~ true
}
