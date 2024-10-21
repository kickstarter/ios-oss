import Library
import Prelude
import UIKit

final class PostCampaignPledgeRewardsSummaryViewController: UIViewController {
  // MARK: - Properties

  private var tableViewContainerHeightConstraint: NSLayoutConstraint?

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var tableViewContainer: UIView = {
    UIView(frame: .zero)
  }()

  private lazy var tableView: UITableView = {
    ContentSizeTableView(frame: .zero, style: .plain)
  }()

  private lazy var dataSource: NoShippingPledgeRewardsSummaryDiffableDataSource =
    NoShippingPledgeRewardsSummaryDiffableDataSource(tableView: self.tableView)

  private lazy var separatorView: UIView = { UIView(frame: .zero) }()

  private lazy var pledgeTotalViewController = {
    PostCampaignPledgeRewardsSummaryTotalViewController.instantiate()
  }()

  private let viewModel: PostCampaignPledgeRewardsSummaryViewModelType =
    PostCampaignPledgeRewardsSummaryViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()
    self.setEntireViewToIsHidden(true)

    self.viewModel.inputs.viewDidLoad()
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (
      [self.tableViewContainer, self.separatorView, self.pledgeTotalViewController.view],
      self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.tableView, self.tableViewContainer)
      |> ksr_addSubviewToParent()

    self.addChild(self.pledgeTotalViewController)
    self.pledgeTotalViewController.didMove(toParent: self)

    self.tableView.registerCellClass(PostCampaignPledgeRewardsSummaryHeaderCell.self)
    self.tableView.registerCellClass(PostCampaignPledgeRewardsSummaryCell.self)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    self.tableViewContainerHeightConstraint?.constant = self.tableView.intrinsicContentSize.height
  }

  private func setupConstraints() {
    let tableViewContainerHeightConstraint = self.tableViewContainer.heightAnchor
      .constraint(equalToConstant: 0)
    self.tableViewContainerHeightConstraint = tableViewContainerHeightConstraint

    NSLayoutConstraint.activate([
      tableViewContainerHeightConstraint,
      self.tableView.leftAnchor.constraint(equalTo: self.tableViewContainer.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.tableViewContainer.rightAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.tableViewContainer.topAnchor),
      self.tableViewContainer.leftAnchor.constraint(equalTo: self.rootStackView.leftAnchor),
      self.tableViewContainer.rightAnchor.constraint(equalTo: self.rootStackView.rightAnchor),
      self.tableViewContainer.topAnchor.constraint(equalTo: self.rootStackView.topAnchor),
      self.separatorView.leftAnchor
        .constraint(equalTo: self.rootStackView.leftAnchor, constant: Styles.grid(4)),
      self.separatorView.rightAnchor
        .constraint(equalTo: self.rootStackView.rightAnchor, constant: -Styles.grid(4)),
      self.separatorView.heightAnchor.constraint(equalToConstant: 1),
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
    ])
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()

    self.view.backgroundColor = .ksr_white
    self.view.clipsToBounds = true

    self.applyRootStackViewStyle(self.rootStackView)

    self.applyTableViewStyle(self.tableView)

    self.applySeparatorViewStyle(self.separatorView)

    self.applyTableViewContainerStyle(self.tableViewContainer)
    self.tableViewContainerHeightConstraint?.constant = self.tableView.intrinsicContentSize.height
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] headerData, rewards in
        guard let self else { return }

        /// Applies a snapshot of all of the data needed to render the table view.
        self.dataSource.apply(
          diffableDataSourceSnapshot(using: headerData, rewards),
          animatingDifferences: true
        )

        self.setEntireViewToIsHidden(false)
        self.tableViewContainerHeightConstraint?.constant = self.tableView.intrinsicContentSize.height
      }

    self.viewModel.outputs.configurePledgeTotalViewWithData
      .observeForUI()
      .observeValues { [weak self] pledgeSummaryData in
        guard let self else { return }

        self.pledgeTotalViewController.configure(with: pledgeSummaryData)
      }
  }

  // MARK: - Configuration

  func configureWith(
    rewardsData: PostCampaignRewardsSummaryViewData,
    bonusAmount: Double?,
    pledgeData: PledgeSummaryViewData
  ) {
    self.viewModel.inputs
      .configureWith(rewardsData: rewardsData, bonusAmount: bonusAmount, pledgeData: pledgeData)

    self.view.setNeedsLayout()
  }

  // MARK: Styles

  private func applyRootStackViewStyle(_ stackView: UIStackView) {
    stackView.axis = NSLayoutConstraint.Axis.vertical
    stackView.spacing = Styles.grid(1)
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.translatesAutoresizingMaskIntoConstraints = false
  }

  private func applyTableViewStyle(_ tableView: UITableView) {
    tableView.separatorInset = .zero
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.isScrollEnabled = false
    tableView.delegate = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.separatorStyle = .none
    tableView.backgroundColor = .ksr_white
    tableView.translatesAutoresizingMaskIntoConstraints = false
  }

  private func applySeparatorViewStyle(_ view: UIView) {
    view.backgroundColor = .ksr_support_200
    view.translatesAutoresizingMaskIntoConstraints = false
  }

  private func applyTableViewContainerStyle(_ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.clipsToBounds = true
  }

  private func applySectionHeaderViewStyle(_ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)
  }

  private func applySectionHeaderLabelStyle(_ label: UILabel) {
    label.font = UIFont.ksr_subhead().bolded
    label.textColor = UIColor.ksr_black
    label.numberOfLines = 0
    label.frame = CGRectMake(
      CheckoutConstants.PledgeView.Inset.leftRight,
      0,
      self.tableView.frame.size.width,
      PledgeRewardsSummaryStyles.Layout.sectionHeaderLabelHeight
    )
  }

  // MARK: - Helpers

  private func setEntireViewToIsHidden(_ isHidden: Bool) {
    self.view.isHidden = isHidden
    self.pledgeTotalViewController.view.isHidden = isHidden
    self.separatorView.isHidden = isHidden
  }

  // MARK: Section Header View

  private func sectionHeaderView(for section: PledgeRewardsSummarySection) -> UIView {
    let headerView = UIView()
    self.applySectionHeaderViewStyle(headerView)

    let headerLabel: UILabel = UILabel(frame: .zero)
    self.applySectionHeaderLabelStyle(headerLabel)

    switch section {
    case .header, .bonusSupport:
      break
    case .reward:
      headerLabel.text = Strings.backer_modal_reward_title()
    case .addOns:
      headerLabel.text = Strings.Add_ons()
    }

    headerView.addSubview(headerLabel)

    return headerView
  }
}

// MARK: - UITableViewDelegate

extension PostCampaignPledgeRewardsSummaryViewController: UITableViewDelegate {
  func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
    return nil
  }

  func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: section) else { return nil }

    return self.sectionHeaderView(for: sectionIdentifier)
  }

  func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return heightForHeaderInPledgeSummarySection(
      sectionIdentifier: self.dataSource
        .sectionIdentifier(for: section)
    )
  }
}
