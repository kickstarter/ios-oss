import Library
import Prelude
import UIKit

public enum PledgeRewardsSummaryStyles {
  public enum Layout {
    public static let sectionHeaderLabelHeight: CGFloat = 20
  }
}

final class NoShippingPledgeRewardsSummaryViewController: UIViewController {
  // MARK: - Properties

  private var tableViewContainerHeightConstraint: NSLayoutConstraint?

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
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

    self.rootStackViewStyle(self.rootStackView)

    self.tableViewStyle(self.tableView)

    self.separatorViewStyle(self.separatorView)

    self.tableViewContainerStyle(self.tableViewContainer)
    self.tableViewContainerHeightConstraint?.constant = self.tableView.intrinsicContentSize.height
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] data in
        guard let self else { return }

        self.applySnapshotToDataSource(from: data)

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

  private func tableViewStyle(_ tableView: UITableView) {
    tableView.separatorInset = .zero
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.isScrollEnabled = false
    tableView.delegate = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.separatorStyle = .none
    tableView.backgroundColor = .ksr_white
    tableView.translatesAutoresizingMaskIntoConstraints = false
  }

  private func rootStackViewStyle(_ stackView: UIStackView) {
    stackView.axis = NSLayoutConstraint.Axis.vertical
    stackView.spacing = Styles.grid(1)
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.translatesAutoresizingMaskIntoConstraints = false
  }

  private func separatorViewStyle(_ view: UIView) {
    view.backgroundColor = .ksr_support_200
    view.translatesAutoresizingMaskIntoConstraints = false
  }

  private func sectionHeaderViewStyle(_ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)
  }

  private func sectionHeaderLabelStyle(_ label: UILabel) {
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

  private func tableViewContainerStyle(_ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.clipsToBounds = true
  }

  // MARK: - Helpers

  private func setEntireViewToIsHidden(_ isHidden: Bool) {
    self.view.isHidden = isHidden
    self.pledgeTotalViewController.view.isHidden = isHidden
    self.separatorView.isHidden = isHidden
  }

  // MARK: Apply DataSource Snapshot

  private func applySnapshotToDataSource(from data: [PostCampaignRewardsSummaryItem]) {
    var snapshot = NSDiffableDataSourceSnapshot<PledgeRewardsSummarySection, PledgeRewardsSummaryRow>()

    /// Decipher header vs reward objects from the `[PostCampaignRewardsSummaryItem]` data object.
    let headerItemData = data.compactMap { item -> PledgeExpandableHeaderRewardCellData? in
      guard case let .header(data) = item else { return nil }
      return data
    }

    let rewardData = data.compactMap { item -> PledgeExpandableHeaderRewardCellData? in
      guard case let .reward(data) = item else { return nil }
      return data
    }

    // MARK: Header Section

    /// Define the sections of the table and what data to use in each section.
    snapshot.appendSections([.header])
    snapshot.appendItems([.header(headerItemData[0])], toSection: .header)

    // MARK: Reward Section

    if rewardData.isEmpty == false {
      let baseReward = rewardData[0]
      snapshot.appendSections([.reward])
      snapshot.appendItems([.reward(baseReward)], toSection: .reward)

      // MARK: Add-Ons

      let addOns = rewardData
        .filter { reward in reward != baseReward && reward.text != Strings.Bonus_support() }
        .map { PledgeRewardsSummaryRow.addOns($0) }

      /// We only want to add an add-ons section if any have been selected
      if addOns.isEmpty == false {
        snapshot.appendSections([.addOns])
        snapshot.appendItems(addOns, toSection: .addOns)
      }
    }

    // MARK: Bonus Support

    let bonusSupportReward = rewardData
      .filter { reward in reward.text == Strings.Bonus_support() }
      .map { PledgeRewardsSummaryRow.bonusSupport($0) }

    if let bonusSupport = bonusSupportReward.first {
      snapshot.appendSections([.bonusSupport])
      snapshot.appendItems([bonusSupport], toSection: .bonusSupport)
    }

    /// Applys the changes above as a snapshot of all of the data needed to render the `UITableView `.
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }

  // MARK: Section Header View

  private func sectionHeaderView(for section: PledgeRewardsSummarySection) -> UIView {
    let headerView = UIView()
    self.sectionHeaderViewStyle(headerView)

    let headerLabel: UILabel = UILabel(frame: .zero)
    self.sectionHeaderLabelStyle(headerLabel)

    switch section {
    case .header:
      break
    case .reward:
      headerLabel.text = Strings.backer_modal_reward_title()
    case .addOns:
      headerLabel.text = Strings.Add_ons()
    case .bonusSupport:
      break
    }

    headerView.addSubview(headerLabel)

    return headerView
  }
}

// MARK: - UITableViewDelegate

extension NoShippingPledgeRewardsSummaryViewController: UITableViewDelegate {
  func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
    return nil
  }

  func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let section = PledgeRewardsSummarySection.allCases[section]

    return self.sectionHeaderView(for: section)
  }

  func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    /// Hides the first section header because we're using our own UITableCell here.
    return section == 0 ? 0 : UITableView.automaticDimension
  }
}
