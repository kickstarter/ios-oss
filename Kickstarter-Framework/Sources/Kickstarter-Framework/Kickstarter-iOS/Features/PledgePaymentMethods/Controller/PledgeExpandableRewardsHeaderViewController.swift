import KsApi
import Library
import PassKit
import Prelude
import UIKit

final class PledgeExpandableRewardsHeaderViewController: UIViewController {
  // MARK: - Properties

  public weak var animatingViewDelegate: UIView?

  private let dataSource = PledgeExpandableRewardsHeaderDataSource()

  private lazy var expandButton: EasyButton = {
    EasyButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.hitMargin .~ 10
  }()

  private lazy var coverView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

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

    self.expandButton.addTarget(self, action: #selector(self.expandButtonTapped), for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  private func configureSubviews() {
    _ = (self.tableView, self.tableViewContainer)
      |> ksr_addSubviewToParent()

    _ = (self.tableViewContainer, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.coverView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.expandButton, self.view)
      |> ksr_addSubviewToParent()

    self.tableView.registerCellClass(PledgeExpandableHeaderRewardHeaderCell.self)
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
        .constraint(equalTo: self.view.bottomAnchor, constant: -Styles.grid(3)),
      self.coverView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.coverView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.coverView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.coverView.heightAnchor.constraint(equalTo: self.expandButton.heightAnchor, multiplier: 0.5),
      self.expandButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.expandButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  // MARK: - Bind Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.clipsToBounds .~ true
      |> checkoutWhiteBackgroundStyle

    _ = self.coverView
      |> checkoutBackgroundStyle

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
        self?.tableView.reloadData()
        self?.tableView.setNeedsLayout()

        self?.updateTableViewContainerHeight(expanded: false, animated: false)
      }

    self.viewModel.outputs.expandRewards
      .observeForUI()
      .observeValues { [weak self] expanded in
        self?.updateTableViewContainerHeight(expanded: expanded, animated: true)
      }
  }

  private func updateTableViewContainerHeight(expanded: Bool, animated: Bool) {
    DispatchQueue.main.async {
      guard animated else {
        self.tableViewContainerHeightConstraint?.constant = self.collapsedHeight()
        self.expandButton.transform = self.expandButton.transform.rotated(by: .pi)
        return
      }

      if expanded {
        self.tableViewContainerHeightConstraint?.constant = self.expandedHeight()
      } else {
        self.tableViewContainerHeightConstraint?.constant = self.collapsedHeight()
      }

      UIView.animate(
        withDuration: 0.33,
        delay: 0,
        usingSpringWithDamping: 0.65,
        initialSpringVelocity: 0.88,
        options: .curveEaseInOut,
        animations: {
          self.expandButton.transform = expanded ? .identity : self.expandButton.transform.rotated(by: .pi)
          self.animatingViewDelegate?.layoutIfNeeded()
        }
      ) { _ in }
    }
  }

  // MARK: - Actions

  @objc func expandButtonTapped() {
    self.viewModel.inputs.expandButtonTapped()
  }

  // MARK: - Configuration

  func configure(with data: PledgeExpandableRewardsHeaderViewData) {
    self.viewModel.inputs.configure(with: data)

    self.view.setNeedsLayout()
  }

  // MARK: - Accessors

  public func expandedHeight() -> CGFloat {
    return self.tableView.intrinsicContentSize.height
  }

  public func collapsedHeight() -> CGFloat {
    return (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.frame.size.height ?? 0) - 1
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
