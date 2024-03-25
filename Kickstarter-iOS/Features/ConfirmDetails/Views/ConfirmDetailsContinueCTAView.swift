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

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    self.layoutMargins = .init(all: Styles.grid(3))

    self.layer.cornerRadius = 16.0
    self.layer.backgroundColor = UIColor.ksr_white.cgColor
    self.layer.shadowColor = UIColor.ksr_black.cgColor
    self.layer.shadowOpacity = 0.12
    self.layer.shadowOffset = CGSize(width: 0, height: -1.0)
    self.layer.shadowRadius = CGFloat(1.0)
    self.layer.maskedCorners = [
      CACornerMask.layerMaxXMinYCorner,
      CACornerMask.layerMinXMinYCorner
    ]

    self.rootStackView.axis = NSLayoutConstraint.Axis.vertical
    self.rootStackView.spacing = Styles.grid(3)

    self.titleAndAmountStackView.backgroundColor = .ksr_white
    self.titleAndAmountStackView.layoutMargins = UIEdgeInsets(leftRight: Styles.gridHalf(4))

    self.titleLabel.accessibilityTraits = UIAccessibilityTraits.header
    self.titleLabel.adjustsFontForContentSizeCategory = true
    self.titleLabel.font = UIFont.ksr_headline(size: 15)
    self.titleLabel.numberOfLines = 0
    self.titleLabel.text = Strings.Total_amount()

    self.amountLabel.adjustsFontForContentSizeCategory = true
    self.amountLabel.textAlignment = NSTextAlignment.right
    self.amountLabel.isAccessibilityElement = true
    self.amountLabel.minimumScaleFactor = 0.75

    self.continueButton.setTitle(Strings.Continue(), for: .normal)
    self.continueButton.setTitleColor(.ksr_white, for: .normal)
    self.continueButton.setTitleColor(.ksr_white, for: .highlighted)
    self.continueButton.setBackgroundColor(.ksr_create_700, for: .normal)
    self.continueButton.setBackgroundColor(UIColor.ksr_create_700.mixDarker(0.36), for: .highlighted)
    self.continueButton.setBackgroundColor(UIColor.ksr_create_700.mixLighter(0.36), for: .disabled)
    self.continueButton.clipsToBounds = true
    self.continueButton.layer.masksToBounds = true
    self.continueButton.layer.cornerRadius = Styles.grid(2)
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
      self.layoutIfNeeded()
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
}
