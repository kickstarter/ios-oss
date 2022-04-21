import KsApi
import Library
import Prelude
import UIKit

final class RewardAddOnSelectionViewController: UIViewController {
  // MARK: - Properties

  private let dataSource = RewardAddOnSelectionDataSource()

  private lazy var headerLabel: UILabel = UILabel(frame: .zero)
  private lazy var headerView: UIView = UIView(frame: .zero)
  private lazy var headerRootStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var pledgeShippingLocationViewController: PledgeShippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var continueCTAView: RewardAddOnSelectionContinueCTAView = {
    RewardAddOnSelectionContinueCTAView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public weak var pledgeViewDelegate: PledgeViewControllerDelegate?

  private lazy var refreshControl: UIRefreshControl = { UIRefreshControl() }()

  private lazy var tableView: UITableView = {
    let tv = UITableView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.alwaysBounceVertical .~ true
      |> \.dataSource .~ self.dataSource
    return tv
      |> \.delegate .~ self
      |> \.rowHeight .~ UITableView.automaticDimension
      |> \.tableFooterView .~ UIView(frame: .zero)
      |> \.tableHeaderView .~ self.headerView
  }()

  private let viewModel: RewardAddOnSelectionViewModelType = RewardAddOnSelectionViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()
    self.configureHeaderView()
    self.setupConstraints()

    self.tableView.registerCellClass(RewardAddOnCell.self)
    self.tableView.registerCellClass(EmptyStateCell.self)

    self.continueCTAView.continueButton.addTarget(
      self,
      action: #selector(RewardAddOnSelectionViewController.continueButtonTapped),
      for: .touchUpInside
    )

    self.refreshControl.addTarget(
      self,
      action: #selector(RewardAddOnSelectionViewController.beginRefresh),
      for: .valueChanged
    )

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  // MARK: - Accessors

  func configure(with data: PledgeViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.continueCTAView, self.view)
      |> ksr_addSubviewToParent()

    _ = self.tableView
      |> \.refreshControl .~ self.refreshControl
  }

  private func configureHeaderView() {
    _ = (self.headerRootStackView, self.headerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent(priority: UILayoutPriority(rawValue: 999))

    _ = ([self.headerLabel, self.pledgeShippingLocationViewController.view], self.headerRootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.addChild(self.pledgeShippingLocationViewController)
    self.pledgeShippingLocationViewController.didMove(toParent: self)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.continueCTAView.topAnchor),
      self.continueCTAView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.continueCTAView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.continueCTAView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.tableView
      |> checkoutBackgroundStyle

    _ = self.headerLabel
      |> checkoutBackgroundStyle

    _ = self.headerLabel
      |> \.numberOfLines .~ 0
      |> \.font .~ UIFont.ksr_title2().bolded
      |> \.text .~ Strings.Customize_your_reward_with_optional_addons()

    _ = self.headerRootStackView
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(4))
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(3)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.pledgeShippingLocationViewController.view.rac.hidden
      = self.viewModel.outputs.shippingLocationViewIsHidden

    self.viewModel.outputs.configureContinueCTAViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.continueCTAView.configure(with: data)
      }

    self.viewModel.outputs.configurePledgeShippingLocationViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeShippingLocationViewController.configureWith(value: data)
      }

    self.viewModel.outputs.loadAddOnRewardsIntoDataSourceAndReloadTableView
      .observeForUI()
      .observeValues { [weak self] items in
        self?.dataSource.load(items)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.loadAddOnRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] items in
        self?.dataSource.load(items)
      }

    self.viewModel.outputs.goToPledge
      .observeForControllerAction()
      .observeValues { data in
        let vc = PledgeViewController.instantiate()
        vc.delegate = self.pledgeViewDelegate
        vc.configure(with: data)
        self.navigationController?.pushViewController(vc, animated: true)
      }

    self.viewModel.outputs.startRefreshing
      .observeForUI()
      .observeValues { [weak self] in
        self?.refreshControl.ksr_beginRefreshing()
      }

    self.viewModel.outputs.endRefreshing
      .observeForUI()
      .observeValues { [weak self] in
        self?.refreshControl.endRefreshing()
      }
  }

  // MARK: - Actions

  @objc func continueButtonTapped() {
    self.viewModel.inputs.continueButtonTapped()
  }

  @objc private func beginRefresh() {
    self.viewModel.inputs.beginRefresh()
  }
}

// MARK: - PledgeShippingLocationViewControllerDelegate

extension RewardAddOnSelectionViewController: PledgeShippingLocationViewControllerDelegate {
  func pledgeShippingLocationViewController(
    _: PledgeShippingLocationViewController,
    didSelect shippingRule: ShippingRule
  ) {
    self.viewModel.inputs.shippingRuleSelected(shippingRule)
  }

  func pledgeShippingLocationViewControllerLayoutDidUpdate(_: PledgeShippingLocationViewController) {
    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  func pledgeShippingLocationViewControllerFailedToLoad(_: PledgeShippingLocationViewController) {
    self.viewModel.inputs.shippingLocationViewDidFailToLoad()
  }
}

// MARK: - RewardAddOnCardViewDelegate

extension RewardAddOnSelectionViewController: RewardAddOnCardViewDelegate {
  func rewardAddOnCardView(
    _: RewardAddOnCardView,
    didSelectQuantity quantity: Int,
    rewardId: Int
  ) {
    self.viewModel.inputs.rewardAddOnCardViewDidSelectQuantity(quantity: quantity, rewardId: rewardId)
  }
}

// MARK: - UITableViewDelegate

extension RewardAddOnSelectionViewController: UITableViewDelegate {
  func tableView(
    _: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt _: IndexPath
  ) {
    guard let cell = cell as? RewardAddOnCell else { return }

    cell.rewardAddOnCardView.delegate = self
  }

  func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
    return nil
  }

  func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if self.dataSource.isEmptyStateIndexPath(indexPath) {
      return (self.view.safeAreaLayoutGuide.layoutFrame.height * 0.90)
        - self.headerView.frame.size.height
        - self.continueCTAView.frame.size.height
    }

    return UITableView.automaticDimension
  }
}
