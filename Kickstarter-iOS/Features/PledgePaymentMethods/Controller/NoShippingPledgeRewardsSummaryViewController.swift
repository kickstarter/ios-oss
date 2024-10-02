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
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var tableViewContainer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.clipsToBounds .~ true
  }()

  private lazy var tableView: UITableView = {
    ContentSizeTableView(frame: .zero, style: .plain)
      |> \.separatorInset .~ .zero
      |> \.contentInsetAdjustmentBehavior .~ .never
      |> \.isScrollEnabled .~ false
      |> \.delegate .~ self
      |> \.rowHeight .~ UITableView.automaticDimension
      |> \.sectionHeaderTopPadding .~ 0
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

    _ = self.view
      |> \.clipsToBounds .~ true
      |> checkoutWhiteBackgroundStyle

    _ = self.rootStackView
      |> self.rootStackViewStyle

    _ = self.tableView
      |> checkoutWhiteBackgroundStyle
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    _ = self.separatorView
      |> self.separatorViewStyle

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

  private let rootStackViewStyle: StackViewStyle = { stackView in
    stackView
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.spacing .~ Styles.grid(1)
      |> \.isLayoutMarginsRelativeArrangement .~ true
  }

  private let separatorViewStyle: ViewStyle = { view in
    view
      |> \.backgroundColor .~ .ksr_support_200
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }

  // MARK: - Helpers

  private func setEntireViewToIsHidden(_ isHidden: Bool) {
    self.view.isHidden = isHidden
    self.pledgeTotalViewController.view.isHidden = isHidden
    self.separatorView.isHidden = isHidden
  }

  private func applySnapshotToDataSource(from data: [PostCampaignRewardsSummaryItem]) {
    var snapshot = NSDiffableDataSourceSnapshot<PledgeRewardsSummarySection, PledgeRewardsSummaryRow>()

    let headerItemData = data.compactMap { item -> PledgeExpandableHeaderRewardCellData? in
      guard case let .header(data) = item else { return nil }
      return data
    }

    let rewardData = data.compactMap { item -> PledgeExpandableHeaderRewardCellData? in
      guard case let .reward(data) = item else { return nil }
      return data
    }

    let baseReward = rewardData[0]

    // MARK: Header + Reward Sections

    snapshot.appendSections([.header, .reward])
    snapshot.appendItems([.header(headerItemData[0])], toSection: .header)
    snapshot.appendItems([.reward(baseReward)], toSection: .reward)

    // MARK: Add-Ons

    let addOns = rewardData.filter { $0 != baseReward }.map { PledgeRewardsSummaryRow.addOns($0) }
    /// We only want to add an add-ons section if any have been selected
    if addOns.isEmpty == false {
      snapshot.appendSections([.addOns])
      snapshot.appendItems(addOns, toSection: .addOns)
    }

    self.dataSource.apply(snapshot, animatingDifferences: true)
  }

  private func headerView(for section: PledgeRewardsSummarySection) -> UIView {
    let headerView: UIView = UIView(
      frame: CGRectMake(0, 0, tableView.frame.size.width, self.tableView.frame.size.height)
    )

    let headerLabel: UILabel = UILabel(frame: .zero)
    headerLabel.frame = CGRectMake(
      CheckoutConstants.PledgeView.Inset.leftRight,
      0,
      self.tableView.frame.size.width,
      PledgeRewardsSummaryStyles.Layout.sectionHeaderLabelHeight
    )
    headerLabel.font = UIFont.ksr_subhead().bolded
    headerLabel.textColor = UIColor.ksr_black
    headerLabel.numberOfLines = 0

    switch section {
    case .header:
      break
    case .reward:
      headerLabel.text = Strings.project_subpages_menu_buttons_rewards()
    case .addOns:
      headerLabel.text = Strings.Add_ons()
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

    return self.headerView(for: section)
  }
}
