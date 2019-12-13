import KsApi
import Library
import Prelude
import UIKit

final class ActivityErroredBackingsTopCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let backgroundContainerView: UIView = { UIView(frame: .zero) }()
  private let headerView: ActivityErroredBackingsTopCellHeader = {
    ActivityErroredBackingsTopCellHeader(frame: .zero)
  }()

  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let viewModel: ActivityErroredBackingsTopCellViewModelType =
    ActivityErroredBackingsTopCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Configuration

  internal func configureWith(value backings: [GraphBacking]) {
    self.viewModel.inputs.configure(with: backings)
  }

  private func configureViews() {
    _ = (self.backgroundContainerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

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
        self?.configureErroredBackingViews(with: backings)
      }
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> cellStyle

    _ = self.contentView
      |> contentViewStyle
    
    _ = self.backgroundContainerView
      |> backgroundContainerViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Private Helpers

  private func configureErroredBackingViews(with backings: [GraphBacking]) {
    self.rootStackView.addArrangedSubview(self.headerView)

    let erroredBackingsViews = backings.map { backing -> ErroredBackingView in
      let view = ErroredBackingView()
        |> \.delegate .~ self
      view.configureWith(value: backing)
      return view
    }

    let erroredBackingsViewsWithSeparators = erroredBackingsViews.dropLast().map { view -> [UIView] in
      let separator = UIView()
        |> separatorStyleDark
      separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

      return [view, separator]
    }
    .flatMap { $0 }

    let allItemViews = erroredBackingsViewsWithSeparators + [erroredBackingsViews.last].compact()

    _ = (allItemViews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}

// MARK: Styles

private let backgroundContainerViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_grey_300
    |> \.clipsToBounds .~ true
    |> \.layer.cornerRadius .~ Styles.grid(2)
}

private let cellStyle: TableViewCellStyle = { cell in
  cell
    |> \.selectionStyle .~ .none
    |> \.layoutMargins .~ UIEdgeInsets.init(all: Styles.grid(2))
    |> \.preservesSuperviewLayoutMargins .~ false
}

private let contentViewStyle: ViewStyle = { view in
  view
    |> \.preservesSuperviewLayoutMargins .~ true
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

extension ActivityErroredBackingsTopCell: ErroredBackingViewDelegate {
  func erroredBackingViewDidTapManage(_: ErroredBackingView, backing _: GraphBacking) {}
}
