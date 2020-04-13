import KsApi
import Library
import PassKit
import Prelude
import UIKit

protocol PledgeViewCTAContainerViewDelegate: AnyObject {
  func pledgeCTAButtonTapped()
  func applePayButtonTapped()
}

private enum Layout {
  enum Button {
    static let minHeight: CGFloat = 48.0
  }
}

final class PledgeViewCTAContainerView: UIView {
  // MARK: - Properties

  private lazy var applePayButton: PKPaymentButton = { PKPaymentButton() }()

  private lazy var ctaStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var disclaimerLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var disclaimerStackView: UIStackView = {
    UIStackView(frame: .zero)
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

  weak var delegate: PledgeViewCTAContainerViewDelegate?

  private let viewModel: PledgeViewCTAContainerViewModelType = PledgeViewCTAContainerViewModel()

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

    _ = self.disclaimerStackView
      |> disclaimerStackViewStyle

    _ = self.layer
      |> layerStyle

    _ = self.pledgeCTAButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Pledge() }

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegatePledgeButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.pledgeCTAButtonTapped()
      }

    self.viewModel.outputs.notifyDelegateApplePayButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.applePayButtonTapped()
      }
  }

  // MARK: - Configuration

  // TODO: Will be addressed in functionality PR
//  func configureWith(value: ) {
//  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.pledgeCTAButton, self.applePayButton], self.ctaStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.disclaimerLabel], self.disclaimerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.ctaStackView, self.disclaimerStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.pledgeCTAButton.addTarget(
      self, action: #selector(self.pledgeButtonTapped), for: .touchUpInside
    )

    self.applePayButton.addTarget(
      self,
      action: #selector(self.applePayButtonTapped),
      for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.pledgeCTAButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight),
      self.applePayButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight)
    ])
  }

  @objc func pledgeButtonTapped() {
    self.viewModel.inputs.pledgeCTAButtonTapped()
  }

  @objc func applePayButtonTapped() {
    self.viewModel.inputs.applePayButtonTapped()
  }
}

// MARK: - Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(
      top: Styles.grid(2),
      left: Styles.grid(3),
      bottom: Styles.grid(0),
      right: Styles.grid(3)
    )
    |> \.spacing .~ Styles.grid(1)
}

private let disclaimerLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ .ksr_footnote()
    |> \.textColor .~ .ksr_text_dark_grey_500
    |> \.numberOfLines .~ 0
    |> \.textAlignment .~ .center
    |> \.text %~ { _ in
      "By pledging you agree to Kickstarter's Terms of Use, Privacy Policy and Cookie Policy"
    }
}

private let ctaStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.distribution .~ .fillEqually
    |> \.spacing .~ Styles.grid(2)
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(2), leftRight: Styles.grid(0))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let disclaimerStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.layoutMargins .~ UIEdgeInsets.init(
      top: Styles.grid(0),
      left: Styles.grid(5),
      bottom: Styles.grid(1),
      right: Styles.grid(5)
    )
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let layerStyle: LayerStyle = { layer in
  layer
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
}
