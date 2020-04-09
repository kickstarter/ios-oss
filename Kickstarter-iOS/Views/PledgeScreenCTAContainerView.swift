import KsApi
import Library
import PassKit
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let minHeight: CGFloat = 49.0
    static let minWidth: CGFloat = 162.0
  }
}

final class PledgeScreenCTAContainerView: UIView {
  // MARK: - Properties

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()

  private lazy var ctaStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var disclaimerLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var disclaimerView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pledgeCTAButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var spacer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.applePayButton
      |> applePayButtonStyle

    _ = self.ctaStackView
      |> ctaStackViewStyle

    _ = self.disclaimerLabel
      |> disclaimerLabelStyle

    _ = self.layer
      |> checkoutLayerCardRoundedStyle
      |> \.backgroundColor .~ UIColor.white.cgColor
      |> \.shadowColor .~ UIColor.black.cgColor
      |> \.shadowOpacity .~ 0.12
      |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
      |> \.shadowRadius .~ CGFloat(1.0)
      |> \.maskedCorners .~ [
        CACornerMask.layerMaxXMinYCorner,
        CACornerMask.layerMinXMinYCorner
      ]

    _ = self.pledgeCTAButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Pledge() }

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.rootStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()
  }

  // MARK: - Configuration

  //TODO: Will be addressed in functionality PR
//  func configureWith(value: ) {
//  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.pledgeCTAButton, self.applePayButton], self.ctaStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.disclaimerLabel, self.disclaimerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.ctaStackView, self.disclaimerView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.pledgeCTAButton.addTarget(
      self, action: #selector(self.pledgeCTAButtonTapped), for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.pledgeCTAButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight),
      self.pledgeCTAButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minWidth),
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight),
      self.applePayButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minWidth),
      self.disclaimerLabel.leadingAnchor.constraint(
         equalTo: self.disclaimerView.leadingAnchor, constant: Styles.grid(4)
       ),
      self.disclaimerLabel.trailingAnchor.constraint(
         equalTo: self.disclaimerView.trailingAnchor, constant: Styles.grid(-3)
       )
    ])
  }

  @objc func pledgeCTAButtonTapped() {
  }
}

// MARK: - Styles

private func adaptableStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : Styles.grid(1))

    return stackView
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ UIEdgeInsets.init(top: Styles.grid(2),
                                              left: Styles.grid(3),
                                              bottom: Styles.grid(6),
                                              right: Styles.grid(3))
      |> \.spacing .~ spacing
  }
}

private let disclaimerLabelStyle: LabelStyle = { label in
  label
   |> \.font .~ .ksr_footnote()
   |> \.textColor .~ .ksr_text_dark_grey_500
   |> \.numberOfLines .~ 0
   |> \.textAlignment .~ .center
   |> \.text %~ { _ in "By pledging you agree to Kickstarter's Terms of Use, Privacy Policy and Cookie Policy" }
}

private let ctaStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.distribution .~ .fillEqually
    |> \.spacing .~ Styles.grid(2)
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(2), leftRight: Styles.grid(0))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
