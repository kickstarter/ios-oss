import KsApi
import Library
import Prelude
import UIKit

final class ActivityErroredBackingsTopCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let dataSource: ErroredBackingsDataSource = ErroredBackingsDataSource()
  private let labelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let subtitleLabel: UILabel = { UILabel(frame: .zero) }()
  private let tableView: UITableView = { UITableView(frame: .zero) }()
  private let titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.tableView.registerCellClass(ErroredBackingCell.self)
    self.tableView.translatesAutoresizingMaskIntoConstraints = false
    self.tableView.estimatedRowHeight = UITableView.automaticDimension

    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Configuration

  internal func configureWith(value backings: [GraphBacking]) {
    self.tableView.dataSource = self.dataSource
    self.dataSource.load(backings)
    self.tableView.reloadData()
  }

  private func configureViews() {
    _ = ([self.titleLabel, self.subtitleLabel], self.labelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.labelsStackView, self.tableView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.titleLabel.text = "Title"
    self.subtitleLabel.text = "Subtitle"
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.labelsStackView
      |> labelsStackViewStyle

    _ = self.rootStackView
      |> rootStackVIewStyle
  }
}

// MARK: Styles

private let labelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

private let rootStackVIewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}
