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
      |> \.isHidden .~ false
  }()

  private let layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.minimumLineSpacing .~ Styles.grid(3)
      |> \.minimumInteritemSpacing .~ 0
      |> \.sectionInset .~ .init(all: Styles.grid(6))
      |> \.scrollDirection .~ .horizontal
  }()

  private var flowLayout: UICollectionViewFlowLayout? {
    return self.collectionViewLayout as? UICollectionViewFlowLayout
  }

  static func instantiate(with project: Project, refTag: RefTag?) -> RewardsCollectionViewController {
    let rewardsCollectionVC = RewardsCollectionViewController()
    rewardsCollectionVC.viewModel.inputs.configure(with: project, refTag: refTag)

    return rewardsCollectionVC
  }

  private var isLandscapeOrientation: Bool {
    return [.landscapeLeft, .landscapeRight].contains(UIDevice.current.orientation)
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

    layout.sectionInset = self.isLandscapeOrientation ?
      .init(topBottom: Styles.grid(6), leftRight: Styles.grid(8)) : .init(all: Styles.grid(6))

    let sectionInsets = layout.sectionInset
    let topBottomInsets = sectionInsets.top + sectionInsets.bottom
    let leftRightInsets = sectionInsets.left + sectionInsets.right
    let collectionViewSize = self.collectionView.frame.size

    let itemHeight = self.collectionView.contentSize.height - topBottomInsets
    var itemWidth = collectionViewSize.width - leftRightInsets

    if self.isLandscapeOrientation {
      itemWidth = collectionViewSize.width / 2 - leftRightInsets
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
        self?.collectionView.reloadData()
    }
  }

  private func configureHiddenScrollView() {
    _ = self.hiddenPagingScrollView
      |> \.delegate .~ self

    _ = (self.hiddenPagingScrollView, self.view)
      |> ksr_addSubviewToParent()

    self.view.sendSubviewToBack(self.hiddenPagingScrollView)

    self.collectionView.addGestureRecognizer(self.hiddenPagingScrollView.panGestureRecognizer)
  }

  private func updateHiddenScrollViewBounds() {
    guard let layout = flowLayout else { return }

    let numberOfItemsInCollectionView = self.collectionView.numberOfItems(inSection: 0)
    let itemSize = layout.itemSize
    let lineSpacing = layout.minimumLineSpacing
    let totalItemWidth = itemSize.width + lineSpacing

    let collectionViewWidth = CGFloat(numberOfItemsInCollectionView) * totalItemWidth

    let pageWidth = self.isLandscapeOrientation ? 2 * totalItemWidth : totalItemWidth
    let pageHeight = itemSize.height

    if self.hiddenPagingScrollView.bounds.width != pageWidth {
      _ = self.hiddenPagingScrollView
        |> \.frame .~ self.collectionView.frame
        |> \.bounds .~ CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        |> \.contentSize .~ CGSize(width: collectionViewWidth, height: pageHeight)

      print("Updating hidden scroll view bounds: \(self.hiddenPagingScrollView.bounds)")
    }
  }

  // MARK: - Public Functions
  @objc func closeButtonTapped() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension RewardsCollectionViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView == self.hiddenPagingScrollView else { return }

    self.collectionView.contentOffset.x = scrollView.contentOffset.x
  }
}

// MARK: Styles
private var collectionViewStyle = { collectionView -> UICollectionView in
  collectionView
    |> \.backgroundColor .~ .ksr_grey_200
    |> \.isPagingEnabled .~ false
    |> \.clipsToBounds .~ false
    |> \.allowsSelection .~ false
}
