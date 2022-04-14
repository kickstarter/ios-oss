import KsApi
import Library
import Prelude
import UIKit

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
    UIImage(in: CGRect(x: 0, y: 0, width: 1, height: 0.5), with: .ksr_support_400)
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

    self.viewModel.outputs.goToAddOnSelection
      .observeForControllerAction()
      .observeValues { [weak self] data in
        self?.goToAddOnSelection(data: data)
      }

    self.viewModel.outputs.goToPledge
      .observeForControllerAction()
      .observeValues { [weak self] data in
        self?.goToPledge(data: data)
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

    self.viewModel.outputs.showEditRewardConfirmationPrompt
      .observeForControllerAction()
      .observeValues { [weak self] title, message in
        self?.showEditRewardConfirmationPrompt(title: title, message: message)
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

  private func goToAddOnSelection(data: PledgeViewData) {
    let vc = RewardAddOnSelectionViewController.instantiate()
    vc.pledgeViewDelegate = self.pledgeViewDelegate
    vc.configure(with: data)
    vc.navigationItem.title = self.title
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToPledge(data: PledgeViewData) {
    let pledgeViewController = PledgeViewController.instantiate()
    pledgeViewController.delegate = self.pledgeViewDelegate
    pledgeViewController.configure(with: data)

    self.navigationController?.pushViewController(pledgeViewController, animated: true)
  }

  private func showEditRewardConfirmationPrompt(title: String, message: String) {
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )

    let continueAction = UIAlertAction(title: Strings.Yes_continue(), style: .default) { [weak self] _ in
      self?.viewModel.inputs.confirmedEditReward()
    }

    alert.addAction(continueAction)
    alert.addAction(UIAlertAction(title: Strings.No_go_back(), style: .cancel))
    alert.preferredAction = continueAction

    self.present(alert, animated: true)
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

extension RewardsCollectionViewController {
  public static func controller(
    with project: Project,
    refTag: RefTag?
  ) -> UINavigationController {
    let rewardsCollectionViewController = RewardsCollectionViewController
      .instantiate(with: project, refTag: refTag, context: .createPledge)

    let closeButton = UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: rewardsCollectionViewController,
      action: #selector(RewardsCollectionViewController.closeButtonTapped)
    )

    _ = closeButton
      |> \.width .~ Styles.minTouchSize.width
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }

    rewardsCollectionViewController.navigationItem.setLeftBarButton(closeButton, animated: false)

    let navigationController = RewardPledgeNavigationController(
      rootViewController: rewardsCollectionViewController
    )

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = navigationController
        |> \.modalPresentationStyle .~ .pageSheet
    }

    return navigationController
  }
}
