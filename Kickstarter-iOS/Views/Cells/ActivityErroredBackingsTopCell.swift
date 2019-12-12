import KsApi
import Library
import Prelude
import UIKit

final class ActivityErroredBackingsTopCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let backgroundContainerView: UIView = { UIView(frame: .zero) }()
  private let dataSource: ErroredBackingsDataSource = ErroredBackingsDataSource()
  private let headerView: ActivityErroredBackingsTopCellHeader = {
    ActivityErroredBackingsTopCellHeader(frame: .zero)
  }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let tableView: UITableView = { UITableView(frame: .zero) }()
  private let viewModel: ActivityErroredBackingsTopCellViewModelType =
    ActivityErroredBackingsTopCellViewModel()

  private lazy var tableViewHeightConstraint: NSLayoutConstraint = {
    self.tableView.heightAnchor.constraint(equalToConstant: 0)
      |> \.priority .~ .defaultHigh
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.tableView.registerCellClass(ErroredBackingCell.self)
    self.tableView.estimatedRowHeight = UITableView.automaticDimension
    self.tableView.translatesAutoresizingMaskIntoConstraints = false
    self.tableView.dataSource = self.dataSource
    self.tableView.delegate = self

    self.bindStyles()
    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Configuration

  internal func configureWith(value backings: [GraphBacking]) {
    self.viewModel.inputs.configure(with: backings)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([self.tableViewHeightConstraint])
  }

  private func configureViews() {
    _ = self
      |> \.selectionStyle .~ .none

    _ = (self.backgroundContainerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.tableView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.backgroundContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.erroredBackings
      .observeForUI()
      .observeValues { [weak self] backings in
        self?.dataSource.load(backings)
        self?.updateTableViewConstraints()
        self?.tableView.reloadData()
      }
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> tableViewStyle

    _ = self.backgroundContainerView
      |> backgroundContainerViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Private Helpers

  private func updateTableViewConstraints() {
    self.tableView.layoutIfNeeded()

    self.tableViewHeightConstraint.constant = self.tableView.contentSize.height

    self.setNeedsLayout()
  }
}

// MARK: Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.isScrollEnabled .~ false
    |> \.backgroundColor .~ .ksr_grey_300
    |> \.separatorInset .~ UIEdgeInsets(topBottom: 0)
}

private let backgroundContainerViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_grey_300
    |> \.clipsToBounds .~ true
    |> \.layer.cornerRadius .~ Styles.grid(2)
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

extension ActivityErroredBackingsTopCell: UITableViewDelegate {
  func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
    return self.headerView
  }

  func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
    return  UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView() |> \.backgroundColor .~ .ksr_grey_300
  }

  func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
    return 0.1
  }
}
