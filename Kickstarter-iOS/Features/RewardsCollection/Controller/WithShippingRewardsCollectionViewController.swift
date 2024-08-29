import KsApi
import Library
import Prelude
import UIKit

final class WithShippingRewardsCollectionViewController: UICollectionViewController {
  // MARK: - Properties

  private var collectionViewBottomConstraintSuperview: NSLayoutConstraint?
  private var collectionViewBottomConstraintFooterView: NSLayoutConstraint?

  private let dataSource = RewardsCollectionViewDataSource()

  private var flowLayout: UICollectionViewFlowLayout? {
    return self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
  }

  private lazy var headerView: RewardsWithShippingCollectionViewHeaderView = {
    RewardsWithShippingCollectionViewHeaderView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  /// The bottom-up modal for selecting a new shipping location
  private lazy var pledgeShippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
      |> \.delegate .~ self
      |> \.view.layoutMargins .~ .init(all: Styles.grid(3))
  }()

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
  public weak var noShippingPledgeViewDelegate: NoShippingPledgeViewControllerDelegate?

  private lazy var rewardsCollectionFooterView: RewardsCollectionViewFooter = {
    RewardsCollectionViewFooter(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: WithShippingRewardsCollectionViewModelType = WithShippingRewardsCollectionViewModel()

  static func instantiate(
    with project: Project,
    refTag: RefTag?,
    context: RewardsCollectionViewContext
  ) -> WithShippingRewardsCollectionViewController {
    let rewardsCollectionVC = WithShippingRewardsCollectionViewController()
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

    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    /// Adding this to the CollectionView Header's rootStackView from here so that we can handle the shipping view's delegates from this view controller.
    _ = ([self.pledgeShippingLocationViewController.view], self.headerView.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.addChild(self.pledgeShippingLocationViewController)
    self.pledgeShippingLocationViewController.didMove(toParent: self)

    _ = (self.rewardsCollectionFooterView, self.view)
      |> ksr_addSubviewToParent()

    self.collectionView.register(RewardCell.self)

    self.collectionView.register(
      RewardsCollectionViewHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: RewardsCollectionViewHeaderView.defaultReusableId
    )

    self.setupConstraints()
    self.viewModel.inputs.shippingRuleSelected(nil)

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let layout = self.flowLayout else { return }

    self.headerView.layoutIfNeeded()

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

    _ = self.headerView
      |> \.backgroundColor .~ .ksr_alert
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

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
        if featureNoShippingAtCheckout() {
          self?.goToNoShippingAddOnSelection(data: data)
        } else {
          self?.goToAddOnSelection(data: data)
        }
      }

    self.viewModel.outputs.goToPledge
      .observeForControllerAction()
      .observeValues { [weak self] data in
        guard let self else { return }

        if featureNoShippingAtCheckout() {
          self.goToNoShippingAddOnSelection(data: data)
        } else if data.context == .latePledge {
          self.goToConfirmDetails(data: data)
        } else {
          self.goToPledge(data: data)
        }
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

    // MARK: - Shipping Location Outputs

    self.pledgeShippingLocationViewController.view.rac.hidden = self.viewModel.outputs
      .shippingLocationViewHidden

    self.viewModel.outputs.configureShippingLocationViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeShippingLocationViewController.configureWith(value: data)
      }
  }

  // MARK: - Functions

  private func setupConstraints() {
    _ = self.collectionView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    NSLayoutConstraint.activate([
      self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.rewardsCollectionFooterView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.rewardsCollectionFooterView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.rewardsCollectionFooterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.collectionView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor)
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

  private func goToNoShippingAddOnSelection(data: PledgeViewData) {
    let vc = RewardAddOnSelectionNoShippingViewController.instantiate()
    vc.pledgeViewDelegate = self.pledgeViewDelegate
    vc.configure(with: data)
    vc.navigationItem.title = self.title
    self.navigationController?.pushViewController(vc, animated: true)
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

  private func goToConfirmDetails(data: PledgeViewData) {
    let vc = ConfirmDetailsViewController.instantiate()
    vc.configure(with: data)
    vc.title = self.title

    self.navigationController?.pushViewController(vc, animated: true)
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

extension WithShippingRewardsCollectionViewController {
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

extension WithShippingRewardsCollectionViewController: UICollectionViewDelegateFlowLayout {
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

extension WithShippingRewardsCollectionViewController: RewardCellDelegate {
  func rewardCellDidTapPledgeButton(_: RewardCell, rewardId: Int) {
    self.viewModel.inputs.rewardSelected(with: rewardId)
  }

  func rewardCell(_: RewardCell, shouldShowDividerLine show: Bool) {
    self.viewModel.inputs.rewardCellShouldShowDividerLine(show)
  }
}

// MARK: - PledgeShippingLocationViewControllerDelegate

extension WithShippingRewardsCollectionViewController: PledgeShippingLocationViewControllerDelegate {
  func pledgeShippingLocationViewController(
    _: PledgeShippingLocationViewController,
    didSelect shippingRule: ShippingRule
  ) {
    self.viewModel.inputs.shippingRuleSelected(shippingRule)
  }

  func pledgeShippingLocationViewControllerLayoutDidUpdate(_: PledgeShippingLocationViewController) {}
  func pledgeShippingLocationViewControllerFailedToLoad(_: PledgeShippingLocationViewController) {
    self.viewModel.inputs.shippingLocationViewDidFailToLoad()
  }
}

// MARK: Styles

private var collectionViewStyle: CollectionViewStyle = { collectionView -> UICollectionView in
  collectionView
    |> \.allowsSelection .~ true
    |> \.showsHorizontalScrollIndicator .~ true
}

extension WithShippingRewardsCollectionViewController {
  public static func controller(
    with project: Project,
    refTag: RefTag?
  ) -> UINavigationController {
    let rewardsWithShippingCollectionViewController = WithShippingRewardsCollectionViewController
      .instantiate(with: project, refTag: refTag, context: .createPledge)

    let closeButton = UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: rewardsWithShippingCollectionViewController,
      action: #selector(WithShippingRewardsCollectionViewController.closeButtonTapped)
    )

    _ = closeButton
      |> \.width .~ Styles.minTouchSize.width
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }

    rewardsWithShippingCollectionViewController.navigationItem.setLeftBarButton(closeButton, animated: false)

    let navigationController = RewardPledgeNavigationController(
      rootViewController: rewardsWithShippingCollectionViewController
    )

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = navigationController
        |> \.modalPresentationStyle .~ .pageSheet
    }

    return navigationController
  }
}
