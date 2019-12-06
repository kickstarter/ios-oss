import KsApi
import Library
import Prelude
import UIKit

final class ActivityErroredPledgesTopCell: UITableViewCell {
  // MARK: - Properties

  private let labelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let subtitleLabel: UILabel = { UILabel(frame: .zero) }()
  private let tableView: UITableView = { UITableView(frame: .zero) }()
  private let titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.tableView.registerCellClass(ErroredPledgeCell.self)

    self.bindStyles()
    self.configureViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: Configuration

  private func configureWith(value backings: [GraphBacking]) {

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

  // MARK: View model

  override func bindViewModel() {
    super.bindViewModel()
  }
}
