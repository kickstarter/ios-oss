import Library
import Prelude
import UIKit

protocol PledgeDisclaimerViewDelegate: AnyObject {
  func pledgeDisclaimerViewDidTapLearnMore(_ view: PledgeDisclaimerView)
}

final class PledgeDisclaimerView: UIView {
  // MARK: - Properties

  private lazy var iconImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var leftColumnStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var textView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()

  weak var delegate: PledgeDisclaimerViewDelegate?
  private let viewModel: PledgeDisclaimerViewModelType = PledgeDisclaimerViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Views

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()

    _ = ([self.leftColumnStackView, self.textView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.iconImageView], self.leftColumnStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self)
      |> ksr_constrainViewToEdgesInParent()

    self.leftColumnStackView.widthAnchor.constraint(equalToConstant: Styles.grid(6)).isActive = true
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_400

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.iconImageView
      |> iconImageViewStyle(self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory)

    _ = self.textView
      |> textViewStyle

    _ = self.leftColumnStackView
      |> leftColumnStackViewStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegatePresentTrustAndSafety
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.pledgeDisclaimerViewDidTapLearnMore(self)
      }
  }
}

extension PledgeDisclaimerView: UITextViewDelegate {
  func textView(
    _: UITextView, shouldInteractWith _: NSTextAttachment,
    in _: NSRange, interaction _: UITextItemInteraction
  ) -> Bool {
    return false
  }

  func textView(
    _: UITextView, shouldInteractWith _: URL, in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    self.viewModel.inputs.learnMoreTapped()
    return false
  }
}

// MARK: - Styles

private let textViewStyle: TextViewStyle = { (textView: UITextView) -> UITextView in
  textView
    |> tappableLinksViewStyle
    |> \.font .~ UIFont.ksr_caption1()
    |> \.attributedText .~ attributedLearnMoreText()
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.accessibilityTraits .~ [.staticText]
    |> \.backgroundColor .~ .ksr_grey_400
}

private func iconImageViewStyle(_ isAccessibilityCategory: Bool) -> (ImageViewStyle) {
  return { (imageView: UIImageView) in
    let image = Library.image(named: "icon-not-a-store")?.withRenderingMode(.alwaysTemplate)

    return imageView
      |> \.image .~ image
      |> \.tintColor .~ .ksr_green_500
      |> \.contentMode .~ (isAccessibilityCategory ? .top : .center)
  }
}

private let leftColumnStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.gridHalf(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(2), leftRight: Styles.grid(3))
    |> \.spacing .~ Styles.grid(2)
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

// MARK: - Functions

private func attributedLearnMoreText() -> NSAttributedString? {
  guard let trustLink = HelpType.trust.url(
    withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
  )?.absoluteString else { return nil }

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.lineSpacing = 2

  let attributedLine1String = Strings.Kickstarter_is_not_a_store()
    .attributed(
      with: UIFont.ksr_footnote(),
      foregroundColor: .ksr_text_dark_grey_500,
      attributes: [.paragraphStyle: paragraphStyle],
      bolding: [Strings.Kickstarter_is_not_a_store()]
    )

  let line2String = Strings.Its_a_way_to_bring_creative_projects_to_life_Learn_more_about_accountability(
    trust_link: trustLink
  )

  guard let attributedLine2String = try? NSMutableAttributedString(
    data: Data(line2String.utf8),
    options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ],
    documentAttributes: nil
  ) else { return nil }

  let attributes: String.Attributes = [
    .font: UIFont.ksr_footnote(),
    .foregroundColor: UIColor.ksr_text_dark_grey_500,
    .paragraphStyle: paragraphStyle,
    .underlineStyle: 0
  ]

  let fullRange = (attributedLine2String.string as NSString).range(of: attributedLine2String.string)
  attributedLine2String.addAttributes(attributes, range: fullRange)

  let attributedString = attributedLine1String + NSAttributedString(string: "\n") + attributedLine2String

  return attributedString
}
