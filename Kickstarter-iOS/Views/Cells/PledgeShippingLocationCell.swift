import KsApi
import Library
import Prelude
import UIKit

final class PledgeShippingLocationCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var countryButton: UIButton = { UIButton(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var spacer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    _ = self
      |> \.accessibilityElements .~ [self.titleLabel, self.countryButton, self.amountLabel]

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.adaptableStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.countryButton, self.spacer, self.amountLabel], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(3)).isActive = true

    self.amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutBackgroundStyle

    _ = self.adaptableStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )

    _ = self.amountLabel
      |> checkoutBackgroundStyle
    _ = self.amountLabel
      |> amountLabelStyle

    _ = self.countryButton
      |> countryButtonStyle
      |> checkoutWhiteBackgroundStyle
      |> checkoutRoundedCornersStyle

    _ = self.countryButton.titleLabel
      ?|> countryButtonTitleLabelStyle

    _ = self.titleLabel
      |> checkoutBackgroundStyle
    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Your_shipping_location() }

    _ = self.rootStackView
      |> checkoutStackViewStyle
  }

  // MARK: - Configuration

  func configureWith(value: PledgeDataSource.PledgeInputRow) {
    guard case let .shippingLocation(location, shippingCost, project) = value else {
      return
    }

    self.countryButton.setTitle(location, for: .normal)
    self.amountLabel.attributedText = shippingValue(for: shippingCost, project: project)
  }

  // MARK: - Public Functions

  func animate(_: Bool) {}
}

// MARK: - Styles

private let amountLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let countryButtonStyle: ButtonStyle = { (button: UIButton) in
  button
    |> \.contentEdgeInsets .~ UIEdgeInsets(
      topBottom: Styles.grid(1) + Styles.gridHalf(1), leftRight: Styles.grid(2)
    )
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_body().bolded
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_green_500
    |> UIButton.lens.titleColor(for: .highlighted) .~ UIColor.ksr_green_700
}

private let countryButtonTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.lineBreakMode .~ .byTruncatingTail
}

// MARK: - Functions
// TODO: Move this to the future `PledgeShippingLocationCellViewModel`
private func shippingValue(for shippingCost: Double, project: Project) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      shippingCost,
      country: project.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  let combinedAttributes = defaultAttributes.merging(superscriptAttributes) { _, new in new }

  return Format.attributedPlusSign(combinedAttributes) + attributedCurrency
}
