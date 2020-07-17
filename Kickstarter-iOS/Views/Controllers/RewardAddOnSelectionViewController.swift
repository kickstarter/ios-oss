import Foundation
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

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  // MARK: - Accessors

  func configureWith(project: Project, reward: Reward, refTag: RefTag?, context: PledgeViewContext) {
    self.viewModel.inputs.configureWith(project: project, reward: reward, refTag: refTag, context: context)
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.continueCTAView, self.view)
      |> ksr_addSubviewToParent()
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
      |> \.text .~ localizedString(
        key: "Customize_your_reward_with_optional_addons",
        defaultValue: "Customize your reward with optional add-ons."
      )

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
      .observeValues { [weak self] rewards in
        self?.dataSource.load(rewards)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.loadAddOnRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] rewards in
        self?.dataSource.load(rewards)
      }
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
}
