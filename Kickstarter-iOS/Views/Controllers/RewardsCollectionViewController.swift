import Foundation
import KsApi
import Library
import Prelude

final class RewardsCollectionViewController: UICollectionViewController {
  // MARK: - Properties

  private let dataSource = RewardsCollectionViewDataSource()

  private let layout: UICollectionViewFlowLayout = {
    UICollectionViewFlowLayout()
      |> \.minimumLineSpacing .~ Styles.grid(3)
      |> \.minimumInteritemSpacing .~ 0
      |> \.sectionInset .~ .init(leftRight: Styles.grid(6))
      |> \.scrollDirection .~ .horizontal
  }()

  private var flowLayout: UICollectionViewFlowLayout? {
    return self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
  }

  private lazy var rewardsCollectionFooterView: RewardsCollectionViewFooter = {
    RewardsCollectionViewFooter(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var collectionViewBottomConstraintSuperview: NSLayoutConstraint?
  private var collectionViewBottomConstraintFooterView: NSLayoutConstraint?

  private let viewModel = RewardsCollectionViewModel()

  static func instantiate(with project: Project, refTag: RefTag?) -> RewardsCollectionViewController {
    let rewardsCollectionVC = RewardsCollectionViewController()
    rewardsCollectionVC.viewModel.inputs.configure(with: project, refTag: refTag)

    return rewardsCollectionVC
  }

  init() {
    super.init(collectionViewLayout: self.layout)

    let closeButton = UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: self,
      action: #selector(RewardsCollectionViewController.closeButtonTapped)
    )

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
    }
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    self.viewModel.inputs.traitCollectionDidChange(self.traitCollection)
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

    self.viewModel.outputs.reloadDataWithValues
      .observeForUI()
      .observeValues { [weak self] values in
        self?.dataSource.load(values)
        self?.collectionView.reloadData()
      }

    self.viewModel.outputs.goToPledge
      .observeForControllerAction()
      .observeValues { [weak self] project, reward, refTag in
        self?.goToPledge(project: project, reward: reward, refTag: refTag)
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
    let topBottomContentInsets = adjustedContentInset.top + adjustedContentInset.bottom

    let itemHeight = collectionView.frame.height - topBottomSectionInsets - topBottomContentInsets
    let itemWidth = CheckoutConstants.RewardCard.Layout.width

    return CGSize(width: itemWidth, height: itemHeight)
  }

  private func configureRewardsCollectionViewFooter(with count: Int) {
    self.rewardsCollectionFooterView.configure(with: count)
  }

  private func updateRewardCollectionViewFooterConstraints(_ isHidden: Bool) {
    self.collectionViewBottomConstraintSuperview?.isActive = false
    self.collectionViewBottomConstraintFooterView?.isActive = false

    _ = self.collectionViewBottomConstraintSuperview
      ?|> \.isActive .~ isHidden

    _ = self.collectionViewBottomConstraintFooterView
      ?|> \.isActive .~ !isHidden

    self.collectionView.setNeedsLayout()
  }

  private func goToPledge(project: Project, reward: Reward, refTag _: RefTag?) {
    let pledgeViewController = PledgeViewController.instantiate()
    pledgeViewController.configureWith(project: project, reward: reward)

    self.navigationController?.pushViewController(pledgeViewController, animated: true)
  }

  private func goToDeprecatedPledge(project: Project, reward: Reward, refTag _: RefTag?) {
    let pledgeViewController = DeprecatedRewardPledgeViewController
      .configuredWith(
        project: project, reward: reward
      )

    self.navigationController?.pushViewController(pledgeViewController, animated: true)
  }

  // MARK: - Public Functions

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
}

// MARK: - RewardPledgeTransitionAnimatorDelegate

extension RewardsCollectionViewController: RewardPledgeTransitionAnimatorDelegate {
  func beginTransition(_: UINavigationController.Operation) {
    self.selectedRewardCell()?.alpha = 0
  }

  func snapshotData(withContainerView view: UIView) -> RewardPledgeTransitionSnapshotData? {
    guard
      let cell = self.selectedRewardCell(),
      let snapshotView = cell.rewardCardContainerView.snapshotView(afterScreenUpdates: false),
      let sourceFrame = cell.rewardCardContainerView.superview?
      .convert(cell.rewardCardContainerView.frame, to: view)
    else { return nil }

    return (snapshotView, sourceFrame, snapshotView.bounds)
  }

  func destinationFrameData(withContainerView _: UIView) -> RewardPledgeTransitionDestinationFrameData? {
    guard
      let cell = self.selectedRewardCell(),
      let frame = cell.rewardCardContainerView.superview?
      .convert(cell.rewardCardContainerView.frame, to: self.view)
    else { return nil }

    return (frame, CGRect(origin: .zero, size: frame.size))
  }

  func endTransition(_: UINavigationController.Operation) {
    self.selectedRewardCell()?.alpha = 1
  }

  private func selectedRewardCell() -> RewardCell? {
    guard
      let selectedReward = self.viewModel.outputs.selectedReward(),
      let cell = self.cell(for: selectedReward)
    else { return nil }

    return cell
  }

  private func cell(for reward: Reward) -> RewardCell? {
    return self.collectionView.visibleCells
      .compactMap { $0 as? RewardCell }
      .filter { cell in cell.currentReward(is: reward) }
      .first
  }
}

// MARK: Styles

private var collectionViewStyle: CollectionViewStyle = { collectionView -> UICollectionView in
  collectionView
    |> \.backgroundColor .~ .ksr_grey_200
    |> \.clipsToBounds .~ false
    |> \.allowsSelection .~ true
    |> \.showsHorizontalScrollIndicator .~ true
}
