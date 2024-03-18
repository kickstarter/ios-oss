import Library
import Prelude
import UIKit

final class PostCampaignPledgeRewardsSummaryViewController: UIViewController {
  // MARK: - Properties

  private let dataSource = PostCampaignPledgeRewardsSummaryDataSource()

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
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.rowHeight .~ UITableView.automaticDimension
  }()

  private lazy var separatorView: UIView = { UIView(frame: .zero) }()

  private lazy var pledgeTotalViewController = {
    PostCampaignPledgeRewardsSummaryTotalViewController.instantiate()
  }()

  private let viewModel: PostCampaignPledgeRewardsSummaryViewModelType =
    PostCampaignPledgeRewardsSummaryViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.isHidden = true
    self.pledgeTotalViewController.view.isHidden = true
    self.configureSubviews()
    self.setupConstraints()

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

    self.tableView.registerCellClass(PostCampaignPledgeRewardsSummaryHeaderCell.self)
    self.tableView.registerCellClass(PostCampaignPledgeRewardsSummaryCell.self)
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
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] data in
        guard let self else { return }

        self.dataSource.load(data)
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()

        self.view.isHidden = false
        self.pledgeTotalViewController.view.isHidden = false
        self.tableViewContainerHeightConstraint?.constant = self.tableView.intrinsicContentSize.height
      }

    self.viewModel.outputs.configurePledgeTotalViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        guard let self else { return }

        self.pledgeTotalViewController.configure(with: data)
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
}

// MARK: - UITableViewDelegate

extension PostCampaignPledgeRewardsSummaryViewController: UITableViewDelegate {
  func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
    return nil
  }
}
