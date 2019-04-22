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

  // Hidden scroll view used for paging
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

    _ = closeButton
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }

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

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
      return
    }

    let collectionViewSize = self.collectionView.frame.size
    layout.itemSize = CGSize(width: collectionViewSize.width, height: self.collectionView.contentSize.height)
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
    self.navigationController?.dismiss(animated: true, completion: nil)
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
