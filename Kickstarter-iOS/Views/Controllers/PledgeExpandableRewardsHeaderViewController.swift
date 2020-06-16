import KsApi
import Library
import PassKit
import Prelude
import UIKit

final class PledgeExpandableRewardsHeaderViewController: UIViewController {
  // MARK: - Properties

  private let dataSource = PledgeExpandableRewardsHeaderDataSource()

  private lazy var expandButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
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
    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.expandButton, self.view)
      |> ksr_addSubviewToParent()

    self.tableView.registerCellClass(PledgeExpandableHeaderRewardHeaderCell.self)
    self.tableView.registerCellClass(PledgeExpandableHeaderRewardCell.self)
  }

  private func setupConstraints() {
    let centerYConstraint = NSLayoutConstraint(
      item: self.expandButton,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: self.view,
      attribute: .bottomMargin,
      multiplier: 1,
      constant: 0
    )

    NSLayoutConstraint.activate([
      centerYConstraint,
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -Styles.grid(1)),
      self.expandButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    ])
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutWhiteBackgroundStyle

    _ = self.tableView
      |> checkoutWhiteBackgroundStyle
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    _ = self.expandButton
      |> expandButtonStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] data in
        self?.dataSource.load(data)
      }
  }

  // MARK: - Configuration

  func configure(with data: PledgeExpandableRewardsHeaderViewData) {
    self.viewModel.inputs.configure(with: data)
  }
}

// MARK: - Styles

private let expandButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "icon-expand-chevron")
}

// MARK: - UITableViewDelegate

extension PledgeExpandableRewardsHeaderViewController: UITableViewDelegate {
  func tableView(_: UITableView, willSelectRowAt _: IndexPath) -> IndexPath? {
    return nil
  }
}
