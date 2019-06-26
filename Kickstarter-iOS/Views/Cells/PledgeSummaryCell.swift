import KsApi
import Library
import Prelude
import UIKit

public typealias PledgeSummaryCellData = (project: Project, total: Double)

internal protocol PledgeSummaryCellDelegate: AnyObject {
  func pledgeSummaryCell(_ cell: PledgeSummaryCell, didOpen helpType: HelpType)
}

final class PledgeSummaryCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  internal weak var delegate: PledgeSummaryCellDelegate?
  private var viewModel = PledgeSummaryCellViewModel()

  // MARK: - Subview Properties

  private lazy var adaptableStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var termsTextView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()
  private var termsTextViewHeightConstraint: NSLayoutConstraint?
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutBackgroundStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.adaptableStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> adaptableStackViewStyle

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.termsTextView
      |> termsTextViewStyle

    _ = self.amountLabel
      |> amountLabelStyle
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.adaptableStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.termsTextView, self.amountLabel], self.adaptableStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - Binding

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateOpenHelpType
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }
        self.delegate?.pledgeSummaryCell(self, didOpen: helpType)
      }
  }

  // MARK: - Configuration

  internal func configureWith(value: PledgeSummaryCellData) {
    _ = self.amountLabel
      |> \.attributedText .~ attributedCurrency(with: value)
  }
}

extension PledgeSummaryCell: UITextViewDelegate {
  func textView(
    _: UITextView, shouldInteractWith _: NSTextAttachment,
    in _: NSRange, interaction _: UITextItemInteraction
  ) -> Bool {
    return false
  }

  func textView(
    _: UITextView, shouldInteractWith url: URL, in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    self.viewModel.inputs.tapped(url)
    return false
  }
}

// MARK: - Styles

private let amountLabelStyle: LabelStyle = { (label: UILabel) in
  _ = label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.adjustsFontSizeToFitWidth .~ true
    |> \.isAccessibilityElement .~ true
    |> \.minimumScaleFactor .~ 0.75

  _ = label
    |> checkoutBackgroundStyle

  return label
}

private let adaptableStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(5), leftRight: Styles.grid(4))
    |> \.spacing .~ Styles.gridHalf(3)
}

private let termsTextViewStyle: TextViewStyle = { (textView: UITextView) -> UITextView in
  _ = textView
    |> tappableLinksViewStyle
    |> \.attributedText .~ attributedTermsText()
    |> \.accessibilityTraits .~ [.staticText]

  _ = textView
    |> checkoutBackgroundStyle

  return textView
}

private let titleLabelStyle: LabelStyle = { (label: UILabel) -> UILabel in
  _ = label
    |> checkoutTitleLabelStyle
    |> \.text %~ { _ in Strings.Total() }

  _ = label
    |> checkoutBackgroundStyle

  return label
}

private func attributedTermsText() -> NSAttributedString? {
  let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl

  // swiftlint:disable line_length
  let string = localizedString(
    key: "By_pledging_you_agree_to_Kickstarters_Terms_of_Use_Privacy_Policy_and_Cookie_Policy",
    defaultValue: "<p>By pledging you agree to Kickstarter's <a href=\"%{terms_of_use_link}\">Terms of Use</a>, <a href=\"%{privacy_policy_link}\">Privacy Policy</a> and <a href=\"%{cookie_policy_link}\">Cookie Policy</a>.<p>",
    substitutions: [
      "terms_of_use_link": HelpType.terms.url(withBaseUrl: baseUrl)?.absoluteString,
      "privacy_policy_link": HelpType.privacy.url(withBaseUrl: baseUrl)?.absoluteString,
      "cookie_policy_link": HelpType.cookie.url(withBaseUrl: baseUrl)?.absoluteString
    ]
    .compactMapValues { $0.coalesceWith("") }
  )
  // swiftlint:enable line_length

  return checkoutAttributedLink(with: string)
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
