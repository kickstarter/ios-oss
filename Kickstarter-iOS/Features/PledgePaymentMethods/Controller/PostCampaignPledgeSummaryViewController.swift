import Library
import Prelude
import UIKit

final class PostCampaignPledgeExpandableRewardsViewController: UIViewController {
  // MARK: - Properties

  private let dataSource = PledgeExpandableRewardsHeaderDataSource()

  private var tableViewContainerHeightConstraint: NSLayoutConstraint?

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

  private let viewModel: PledgeExpandableRewardsHeaderViewModelType = PledgeExpandableRewardsHeaderViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  private func configureSubviews() {
    _ = (self.tableView, self.tableViewContainer)
      |> ksr_addSubviewToParent()

    _ = (self.tableViewContainer, self.view)
      |> ksr_addSubviewToParent()

    self.tableView.registerCellClass(PostCampaignPledgeRewardsSummaryHeaderCell.self)
    self.tableView.registerCellClass(PledgeExpandableHeaderRewardCell.self)
  }

  /*
   tableView is not pinned to bottom of container to allow it to size freely and for us to manage its height
   with constraints
   */
  private func setupConstraints() {
    let tableViewContainerHeightConstraint = self.tableViewContainer.heightAnchor
      .constraint(equalToConstant: 0)
    self.tableViewContainerHeightConstraint = tableViewContainerHeightConstraint

    NSLayoutConstraint.activate([
      tableViewContainerHeightConstraint,
      self.tableView.leftAnchor.constraint(equalTo: self.tableViewContainer.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.tableViewContainer.rightAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.tableViewContainer.topAnchor),
      self.tableViewContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableViewContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.tableViewContainer.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.tableViewContainer.bottomAnchor
        .constraint(equalTo: self.view.bottomAnchor, constant: -Styles.grid(3))
    ])
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.clipsToBounds .~ true
      |> checkoutWhiteBackgroundStyle

    _ = self.tableView
      |> checkoutWhiteBackgroundStyle
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] data in
        guard let self else { return }

        self.dataSource.load(data, isInPostCampaign: true)
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()

        DispatchQueue.main.async {
          self.tableViewContainerHeightConstraint?.constant = self.tableView.intrinsicContentSize.height
        }
      }
  }

  // MARK: - Configuration

  func configure(with data: PledgeExpandableRewardsHeaderViewData) {
    self.viewModel.inputs.configure(with: data)

    self.view.setNeedsLayout()
  }
}

// MARK: - UITableViewDelegate

extension PostCampaignPledgeExpandableRewardsViewController: UITableViewDelegate {
  func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
    return nil
  }
}
