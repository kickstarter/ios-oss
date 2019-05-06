import Foundation
import Library
import KsApi
import Prelude

final class RewardsCollectionViewController: UICollectionViewController {

  // MARK: - Properties

  private let dataSource = RewardsCollectionViewDataSource()
  private let viewModel = RewardsCollectionViewModel()

  private let hiddenPagingScrollView: UIScrollView = {
    UIScrollView()
      |> \.isPagingEnabled .~ true
      |> \.isHidden .~ true
  }()

  private let layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.minimumLineSpacing .~ Styles.grid(3)
      |> \.sectionInset .~ .init(all: Styles.grid(6))
      |> \.scrollDirection .~ .horizontal
  }()

  private var flowLayout: UICollectionViewFlowLayout? {
    return self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
  }

  private let peekAmountInset = Styles.grid(3)

  static func instantiate(with project: Project, refTag: RefTag?) -> RewardsCollectionViewController {
    let rewardsCollectionVC = RewardsCollectionViewController()
    rewardsCollectionVC.viewModel.inputs.configure(with: project, refTag: refTag)

    return rewardsCollectionVC
  }

  init() {
    super.init(collectionViewLayout: self.layout)

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
      |> \.dataSource .~ self.dataSource

    self.collectionView.register(RewardCell.self)

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
    }
  }

  // MARK: - Public Functions

  @objc func closeButtonTapped() {
    self.navigationController?.dismiss(animated: true)
  }
}

// MARK: - Styles

private var collectionViewStyle: CollectionViewStyle = { collectionView -> UICollectionView in
  collectionView
    |> \.alwaysBounceHorizontal .~ true
    |> \.backgroundColor .~ .ksr_grey_200
    |> \.isPagingEnabled .~ true
    |> \.clipsToBounds .~ false
    |> \.allowsSelection .~ true
}
