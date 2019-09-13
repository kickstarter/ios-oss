import Foundation
import Library
import KsApi
import Prelude
import UIKit

final class PledgeSummaryView: UIView {
  // MARK: Properties

  private lazy var backerInfoStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var backerNumberLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var backingDateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var pledgeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var pledgeAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var pledgeAmountStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var shippingLocationLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingLocationStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var totalLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalAmountStackView: UIStackView = { UIStackView(frame: .zero) }()

  public func configureWith(_ project: Project) {
    _ = self.totalAmountLabel
      |> \.attributedText .~ attributedCurrency(with: (project, 10.0))
  }

  // MARK: Life cycle

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Functions

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.backerNumberLabel, self.backingDateLabel], self.backerInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.pledgeLabel, self.pledgeAmountLabel], self.pledgeAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.shippingLocationLabel, self.shippingAmountLabel], self.shippingLocationStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.totalLabel, self.totalAmountLabel], self.totalAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.backerInfoStackView,
          self.pledgeAmountStackView,
          self.shippingLocationStackView,
          self.totalAmountStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}


private func attributedCurrency(with data: PledgeSummaryCellData) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: UIColor.ksr_green_500])
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      data.total,
      country: data.project.country,
      omitCurrencyCode: data.project.stats.omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  let combinedAttributes = defaultAttributes
    .withAllValuesFrom(superscriptAttributes)

  return Format.attributedPlusSign(combinedAttributes) + attributedCurrency
}

// MARK: Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> checkoutStackViewStyle
}

private let backerNumberLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let backingDateLabelStyel: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption1().bolded
    |> \.textColor .~ UIColor.ksr_dark_grey_500
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let pledgeLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_dark_grey_500
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in Strings.Pledge() }
}

private let pledgeAmountLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.isAccessibilityElement .~ true
    |> \.minimumScaleFactor .~ 0.75
}

private let shippingLocationLabel: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_dark_grey_500
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in Strings.Pledge() }
}

private let totalLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.black
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in Strings.Pledge() }
}

private let totalAmountLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.isAccessibilityElement .~ true
    |> \.minimumScaleFactor .~ 0.75
}
