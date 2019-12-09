import KsApi
import Library
import Prelude
import UIKit

final class ActivityErroredBackingsTopCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let backgroundContainerView: UIView = { UIView(frame: .zero) }()
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
    self.updateTableViewConstraints()
  }

  private func updateTableViewConstraints() {
    self.tableView.layoutIfNeeded()
    NSLayoutConstraint.activate([
      self.tableView.heightAnchor.constraint(
        equalToConstant: self.tableView.contentSize.height + self.labelsStackView.frame.size.height
      )
    ])
    self.setNeedsLayout()
  }

  private func configureViews() {
    _ = (self.backgroundContainerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.titleLabel, self.subtitleLabel], self.labelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.labelsStackView, self.tableView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.backgroundContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
    
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.backgroundContainerView
      |> backgroundContainerViewStyle

    _ = self.labelsStackView
      |> labelsStackViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.subtitleLabel
      |> subtitleLabelStyle

    _ = self.titleLabel
      |> titleLabelStyle
  }
}

// MARK: Styles

private let backgroundContainerViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_grey_300
    |> \.clipsToBounds .~ true
    |> \.layer.cornerRadius .~ Styles.grid(1)
}

private let labelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(1)
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

private let subtitleLabelStyle: LabelStyle = { label in
  label
    |> \.text %~ { _ in Strings.We_cant_process_your_pledge_for() }
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ .ksr_soft_black
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.text %~ { _ in Strings.Payment_failure() }
    |> \.font .~ UIFont.ksr_title2().bolded
    |> \.textColor .~ .ksr_soft_black
}
