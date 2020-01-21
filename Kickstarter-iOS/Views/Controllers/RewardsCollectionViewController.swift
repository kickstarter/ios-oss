import Foundation
import KsApi
import Library
import Prelude

final class RewardsCollectionViewController: UICollectionViewController {
  // MARK: - Properties

  private var collectionViewBottomConstraintSuperview: NSLayoutConstraint?
  private var collectionViewBottomConstraintFooterView: NSLayoutConstraint?

  private let dataSource = RewardsCollectionViewDataSource()

  private var flowLayout: UICollectionViewFlowLayout? {
    return self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
  }

  private let layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.minimumLineSpacing .~ Styles.grid(3)
      |> \.minimumInteritemSpacing .~ 0
      |> \.sectionInset .~ .init(leftRight: Styles.grid(6))
      |> \.scrollDirection .~ .horizontal
  }()

  private lazy var navigationBarShadowImage: UIImage? = {
    UIImage(in: CGRect(x: 0, y: 0, width: 1, height: 0.5), with: .ksr_dark_grey_400)
  }()

  public weak var pledgeViewDelegate: PledgeViewControllerDelegate?

  private lazy var rewardsCollectionFooterView: RewardsCollectionViewFooter = {
    RewardsCollectionViewFooter(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: RewardsCollectionViewModelType = RewardsCollectionViewModel()

  static func instantiate(
    with project: Project,
    refTag: RefTag?,
    context: RewardsCollectionViewContext
  ) -> RewardsCollectionViewController {
    let rewardsCollectionVC = RewardsCollectionViewController()
    rewardsCollectionVC.viewModel.inputs.configure(with: project, refTag: refTag, context: context)

    return rewardsCollectionVC
  }

  init() {
    super.init(collectionViewLayout: self.layout)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    _ = self.collectionView
      |> \.dataSource .~ self.dataSource

    _ = (self.rewardsCollectionFooterView, self.view)
      |> ksr_addSubviewToParent()

    self.collectionView.register(RewardCell.self)

    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let layout = self.flowLayout else { return }

    let itemSize = self.calculateItemSize(from: layout, using: self.collectionView)

    if itemSize != layout.itemSize {
      layout.invalidateLayout()
    } else {
      self.viewModel.inputs.viewDidLayoutSubviews()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    self.viewModel.inputs.traitCollectionDidChange(self.traitCollection)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.collectionView
      |> collectionViewStyle
      |> checkoutBackgroundStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak self] title in
        _ = self
          ?|> \.title .~ title
      }

    self.viewModel.outputs.reloadDataWithValues
      .observeForUI()
      .observeValues { [weak self] values in
        self?.dataSource.load(values)
        self?.collectionView.reloadData()
      }

    self.viewModel.outputs.scrollToBackedRewardIndexPath
      .observeForUI()
      .observeValues { [weak self] indexPath in
        self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
      }

    self.viewModel.outputs.goToPledge
      .observeForControllerAction()
      .observeValues { [weak self] data, context in
        self?.goToPledge(project: data.project, reward: data.reward, refTag: data.refTag, context: context)
      }

    self.viewModel.outputs.goToDeprecatedPledge
      .observeForControllerAction()
      .observeValues { [weak self] project, reward, refTag in
        self?.goToDeprecatedPledge(project: project, reward: reward, refTag: refTag)
      }

    self.viewModel.outputs.rewardsCollectionViewFooterIsHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.updateRewardCollectionViewFooterConstraints(isHidden)
      }

    self.viewModel.outputs.configureRewardsCollectionViewFooterWithCount
      .observeForUI()
      .observeValues { [weak self] count in
        self?.configureRewardsCollectionViewFooter(with: count)
      }

    self.viewModel.outputs.flashScrollIndicators
      .observeForUI()
      .observeValues { [weak self] in
        self?.collectionView.flashScrollIndicators()
      }

    self.rewardsCollectionFooterView.rac.hidden = self.viewModel.outputs.rewardsCollectionViewFooterIsHidden

    self.viewModel.outputs.navigationBarShadowImageHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        guard let self = self else { return }
        self.navigationController?.navigationBar.shadowImage = hidden
          ? UIImage()
          : self.navigationBarShadowImage
      }
  }

  // MARK: - Functions

  private func setupConstraints() {
    _ = self.collectionView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    NSLayoutConstraint.activate([
      self.rewardsCollectionFooterView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.rewardsCollectionFooterView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.rewardsCollectionFooterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor)
    ])

    self.collectionViewBottomConstraintFooterView = self.collectionView.bottomAnchor
      .constraint(equalTo: self.rewardsCollectionFooterView.topAnchor)
    self.collectionViewBottomConstraintSuperview = self.collectionView.bottomAnchor
      .constraint(equalTo: self.view.bottomAnchor)
  }

  private func calculateItemSize(
    from layout: UICollectionViewFlowLayout,
    using collectionView: UICollectionView
  ) -> CGSize {
    let sectionInsets = layout.sectionInset
    let adjustedContentInset = collectionView.adjustedContentInset

    let topBottomSectionInsets = sectionInsets.top + sectionInsets.bottom
    let leftRightSectionInsets = sectionInsets.left + sectionInsets.right
    let topBottomContentInsets = adjustedContentInset.top + adjustedContentInset.bottom

    let itemHeight = collectionView.frame.height - topBottomSectionInsets - topBottomContentInsets
    let widthByBounds = collectionView.bounds.width - leftRightSectionInsets
    let itemWidth = min(CheckoutConstants.RewardCard.Layout.width, widthByBounds)

    return CGSize(width: itemWidth, height: itemHeight)
  }

  private func configureRewardsCollectionViewFooter(with count: Int) {
    self.rewardsCollectionFooterView.configure(with: count)
  }

  private func updateRewardCollectionViewFooterConstraints(_ isHidden: Bool) {
    _ = self.collectionViewBottomConstraintSuperview
      ?|> \.isActive .~ isHidden

    _ = self.collectionViewBottomConstraintFooterView
      ?|> \.isActive .~ !isHidden
  }

  private func goToPledge(project: Project, reward: Reward, refTag: RefTag?, context: PledgeViewContext) {
    let pledgeViewController = PledgeViewController.instantiate()
    pledgeViewController.delegate = self.pledgeViewDelegate
    pledgeViewController.configureWith(project: project, reward: reward, refTag: refTag, context: context)

    self.navigationController?.pushViewController(pledgeViewController, animated: true)
  }

  private func goToDeprecatedPledge(project: Project, reward: Reward, refTag _: RefTag?) {
    let pledgeViewController = DeprecatedRewardPledgeViewController
      .configuredWith(
        project: project, reward: reward
      )

    self.navigationController?.pushViewController(pledgeViewController, animated: true)
  }

  // MARK: - Actions

  @objc func closeButtonTapped() {
    self.navigationController?.dismiss(animated: true)
  }
}

// MARK: - UICollectionViewDelegate

extension RewardsCollectionViewController {
  override func collectionView(
    _: UICollectionView, willDisplay cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    if let rewardCell = cell as? RewardCell {
      rewardCell.delegate = self
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RewardsCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt _: IndexPath
  ) -> CGSize {
    guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
      return .zero
    }

    layout.itemSize = self.calculateItemSize(from: layout, using: collectionView)

    return layout.itemSize
  }
}

// MARK: - RewardCellDelegate

extension RewardsCollectionViewController: RewardCellDelegate {
  func rewardCellDidTapPledgeButton(_: RewardCell, rewardId: Int) {
    self.viewModel.inputs.rewardSelected(with: rewardId)
  }

  func rewardCell(_: RewardCell, shouldShowDividerLine show: Bool) {
    self.viewModel.inputs.rewardCellShouldShowDividerLine(show)
  }
}

// MARK: Styles

private var collectionViewStyle: CollectionViewStyle = { collectionView -> UICollectionView in
  collectionView
    |> \.allowsSelection .~ true
    |> \.showsHorizontalScrollIndicator .~ true
}
