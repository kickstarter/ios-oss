import Library
import Prelude
import UIKit

protocol BetaToolsFooterViewDelegate: AnyObject {
  func betaToolsFooterViewDelegateDidTapFeedbackButton()
}

final class BetaToolsFooterView: UIView {
  // MARK: - Properties

  private let appVersionDetailTextView: UITextView = { UITextView(frame: .zero) }()
  private let appVersionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let appVersionTitleLabel: UILabel = { UILabel(frame: .zero) }()
  private let betaFeedbackButton = UIButton(type: .custom)
  private let deviceIdentifierDetailTextView: UITextView = { UITextView(frame: .zero) }()
  private let deviceIdentifierStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let deviceIdentifierTitleLabel: UILabel = { UILabel(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  internal weak var delegate: BetaToolsFooterViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindStyles()
    self.setupConstraints()

    self.betaFeedbackButton.addTarget(
      self, action: #selector(self.betaFeedbackButtonTapped),
      for: .touchUpInside
    )
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.appVersionTitleLabel, self.appVersionDetailTextView], self.appVersionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (
      [self.deviceIdentifierTitleLabel, self.deviceIdentifierDetailTextView],
      self.deviceIdentifierStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    _ = (
      [self.betaFeedbackButton, self.appVersionStackView, self.deviceIdentifierStackView],
      self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.betaFeedbackButton.heightAnchor
        .constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
        |> \.priority .~ .defaultHigh
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.appVersionDetailTextView
      |> appVersionDetailTextViewStyle

    _ = self.appVersionStackView
      |> appVersionStackViewStyle

    _ = self.appVersionTitleLabel
      |> appVersionTitleLabelStyle

    _ = self.betaFeedbackButton
      |> betaFeedbackButtonStyle

    _ = self.deviceIdentifierDetailTextView
      |> deviceIdentifierDetailTextViewStyle

    _ = self.deviceIdentifierStackView
      |> deviceIdentifierStackViewStyle

    _ = self.deviceIdentifierTitleLabel
      |> deviceIdentifierTitleLabelStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Selectors

  @objc private func betaFeedbackButtonTapped() {
    self.delegate?.betaToolsFooterViewDelegateDidTapFeedbackButton()
  }
}

// MARK: - Styles

private let appVersionDetailTextViewStyle: TextViewStyle = { textView in
  textView
    |> baseTextViewStyle
    |> \.text .~ AppEnvironment.current.mainBundle.appVersionString
}

private let appVersionStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

private let appVersionTitleLabelStyle: LabelStyle = { label in
  label
    |> baseTitleLabelStyle
    |> \.text .~ (Strings.App_version() + ": ")
}

private let betaFeedbackButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> UIButton.lens.title(for: .normal) .~ "Submit feedback for beta"
}

private let deviceIdentifierDetailTextViewStyle: TextViewStyle = { textView in
  _ = textView
    |> baseTextViewStyle
    |> \.text .~ AppEnvironment.current.device.identifierForVendor?.uuidString

  return textView
}

private let deviceIdentifierStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

private let deviceIdentifierTitleLabelStyle: LabelStyle = { label in
  label
    |> baseTitleLabelStyle
    |> \.text .~ "Device identifier: "
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(2)
}

private let baseTextViewStyle: TextViewStyle = { textView in
  _ = textView
    |> \.font .~ .ksr_headline(size: 15)
    |> \.textColor .~ .ksr_text_dark_grey_500
    |> \.isScrollEnabled .~ false

  _ = textView
    |> \.textContainerInset .~ UIEdgeInsets.zero
    |> \.textContainer.lineFragmentPadding .~ 0
    |> \.isEditable .~ false
    |> \.isUserInteractionEnabled .~ true
    |> \.adjustsFontForContentSizeCategory .~ true

  return textView
}

private let baseTitleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ .ksr_subhead()
    |> \.textAlignment .~ .left
}
