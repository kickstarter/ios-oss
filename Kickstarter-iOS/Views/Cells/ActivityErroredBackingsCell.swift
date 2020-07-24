import KsApi
import Library
import Prelude
import UIKit

final class ActivityErroredBackingsCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let backgroundContainerView: UIView = { UIView(frame: .zero) }()
  private let erroredBackingsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let headerView: ActivityErroredBackingsCellHeader = {
    ActivityErroredBackingsCellHeader(frame: .zero)
  }()

  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  public weak var delegate: ErroredBackingViewDelegate? {
    didSet {
      self.rootStackView.arrangedSubviews
        .compactMap { $0 as? ErroredBackingView }
        .forEach { $0.delegate = self.delegate }
    }
  }

  private let viewModel: ActivityErroredBackingsCellViewModelType =
    ActivityErroredBackingsCellViewModel()

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

    _ = ([self.headerView, self.erroredBackingsStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
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

    _ = self.erroredBackingsStackView
      |> \.axis .~ .vertical
  }

  // MARK: - Private Helpers

  private func configureErroredBackingViews(with backings: [GraphBacking]) {
    self.erroredBackingsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let erroredBackingsViews = backings.map { backing -> ErroredBackingView in
      let view = ErroredBackingView(frame: .zero)
        |> \.delegate .~ self.delegate
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

    _ = (allItemViews, self.erroredBackingsStackView)
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
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
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
