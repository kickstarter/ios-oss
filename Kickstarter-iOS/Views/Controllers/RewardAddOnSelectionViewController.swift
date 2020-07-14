import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class RewardAddOnSelectionViewController: UITableViewController {
  // MARK: - Properties

  private let dataSource = RewardAddOnSelectionDataSource()

  public lazy var headerLabel: UILabel = UILabel(frame: .zero)
  public lazy var headerView: UIView = UIView(frame: .zero)
  public lazy var headerRootStackView: UIStackView = UIStackView(frame: .zero)
  public lazy var pledgeShippingLocationViewController: PledgeShippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
      |> \.delegate .~ self
  }()

  private let viewModel: RewardAddOnSelectionViewModelType = RewardAddOnSelectionViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureHeaderView()

    self.tableView.dataSource = self.dataSource
    self.tableView.tableHeaderView = self.headerView
    self.tableView.tableFooterView = UIView(frame: .zero)
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

  private func configureHeaderView() {
    _ = (self.headerRootStackView, self.headerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent(priority: UILayoutPriority(rawValue: 999))

    _ = ([self.headerLabel, self.pledgeShippingLocationViewController.view], self.headerRootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.addChild(self.pledgeShippingLocationViewController)
    self.pledgeShippingLocationViewController.didMove(toParent: self)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
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

    self.viewModel.outputs.configurePledgeShippingLocationViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeShippingLocationViewController.configureWith(value: data)
      }

    self.viewModel.outputs.loadAddOnRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] rewards in
        self?.dataSource.load(rewards)
        self?.tableView.reloadData()
      }
  }
}

// MARK: - PledgeShippingLocationViewControllerDelegate

extension RewardAddOnSelectionViewController: PledgeShippingLocationViewControllerDelegate {
  func pledgeShippingLocationViewController(
    _: PledgeShippingLocationViewController,
    didSelect shippingRule: ShippingRule
  ) {
    self.tableView.ksr_sizeHeaderFooterViewsToFit()
    self.viewModel.inputs.shippingRuleSelected(shippingRule)
  }

  func pledgeShippingLocationViewControllerLayoutDidUpdate(_: PledgeShippingLocationViewController) {
    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }
}
