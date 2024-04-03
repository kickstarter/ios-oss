import KsApi
import Library
import Prelude
import UIKit

public typealias ConfirmDetailsContinueCTAViewData = (
  project: Project,
  total: Double
)

private enum Layout {
  enum Button {
    static let minHeight: CGFloat = 48.0
  }
}

protocol ConfirmDetailsContinueCTAViewDelegate: AnyObject {
  func continueButtonTapped()
}

final class ConfirmDetailsContinueCTAView: UIView {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private(set) lazy var titleAndAmountStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var amountLabel: UILabel = { UILabel(frame: .zero) }()

  private(set) lazy var continueButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public weak var delegate: ConfirmDetailsContinueCTAViewDelegate?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()

    self.continueButton.addTarget(
      self, action: #selector(self.continueButtonTapped),
      for: .touchUpInside
    )
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.layer
      |> checkoutLayerCardRoundedStyle
      |> \.backgroundColor .~ UIColor.ksr_white.cgColor
      |> \.shadowColor .~ UIColor.ksr_black.cgColor
      |> \.shadowOpacity .~ 0.12
      |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
      |> \.shadowRadius .~ CGFloat(1.0)
      |> \.maskedCorners .~ [
        CACornerMask.layerMaxXMinYCorner,
        CACornerMask.layerMinXMinYCorner
      ]

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> \.spacing .~ Styles.grid(3)

    _ = self.titleAndAmountStackView
      |> self.titleAndAmountStackViewStyle

    _ = self.titleLabel
      |> self.titleLabelStyle

    _ = self.amountLabel
      |> self.amountLabelStyle

    _ = self.continueButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue() }
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.titleAndAmountStackView, self.continueButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.amountLabel], self.titleAndAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight)
    ])
  }

  func configure(with data: ConfirmDetailsContinueCTAViewData) {
    if let attributedAmount = attributedCurrency(withProject: data.project, total: data.total) {
      self.amountLabel.attributedText = attributedAmount
    }
  }

  private func attributedCurrency(withProject project: Project, total: Double) -> NSAttributedString? {
    let defaultAttributes = checkoutCurrencyDefaultAttributes()
      .withAllValuesFrom([.foregroundColor: UIColor.ksr_support_700])
    let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country

    return Format.attributedCurrency(
      total,
      country: projectCurrencyCountry,
      omitCurrencyCode: project.stats.omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: checkoutCurrencySuperscriptAttributes()
    )
  }

  // MARK: - Accessors

  @objc func continueButtonTapped() {
    self.delegate?.continueButtonTapped()
  }

  // MARK: - Styles

  private let titleLabelStyle: LabelStyle = { (label: UILabel) -> UILabel in
    _ = label
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Total_amount() }

    return label
  }

  private let amountLabelStyle: LabelStyle = { (label: UILabel) in
    _ = label
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.textAlignment .~ NSTextAlignment.right
      |> \.isAccessibilityElement .~ true
      |> \.minimumScaleFactor .~ 0.75

    return label
  }

  private let titleAndAmountStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
    stackView
      |> \.backgroundColor .~ .ksr_white
      |> \.layoutMargins .~ UIEdgeInsets(leftRight: Styles.gridHalf(4))
  }
}
