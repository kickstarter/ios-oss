import Library
import Prelude
import Prelude_UIKit
import UIKit

final class RiskMessagingViewController: UIViewController {
  // MARK: - Properties

  private lazy var bannerImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var confirmButton: UIButton = { UIButton(frame: .zero) }()
  private lazy var footnoteLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var headingLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var subtitleLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: PledgeViewModelType = PledgeViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (
      [self.bannerImageView, self.headingLabel, self.subtitleLabel, self.confirmButton, self.footnoteLabel],
      self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    self.setupConstraints()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.bannerImageView
      |> bannerImageViewStyle

    _ = self.confirmButton
      |> confirmButtonStyle

    _ = self.footnoteLabel
      |> footnoteLabelStyle
      |> \.attributedText .~ attributedTextForFootnoteLabel()

    _ = self.headingLabel
      |> headingLabelStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.subtitleLabel
      |> subtitleLabelStyle

    _ = self.view
      |> \.backgroundColor .~ .ksr_white
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.confirmButton.heightAnchor
        .constraint(equalToConstant: Styles.minTouchSize.height)
        |> \.priority .~ .defaultHigh
    ])
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
  }
}

// MARK: - Helpers

private func attributedTextForFootnoteLabel() -> NSAttributedString {
  let attributes: String.Attributes = [
    .font: UIFont.ksr_footnote(),
    .underlineStyle: NSUnderlineStyle.single.rawValue
  ]

  return NSMutableAttributedString(
    string: Strings.Learn_more_about_accountability(),
    attributes: attributes
  )
}

// MARK: - Styles

private let bannerImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> UIImageView.lens.contentMode .~ .scaleAspectFit
    |> UIImageView.lens.image .~ image(named: "risk-messaging")
    |> UIImageView.lens.contentHuggingPriority(for: .vertical) .~ .required
}

// TODO: Internationalize text
private let confirmButtonStyle: ButtonStyle = { button in
  button
    |> baseButtonStyle
    |> blackButtonStyle
    |> UIButton.lens.titleLabel.lineBreakMode .~ .byWordWrapping
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_callout().bolded
    |> UIButton.lens.title(for: .normal) %~ { _ in "I understand" }
    |> UIButton.lens.contentHorizontalAlignment .~ .center
}

private let footnoteLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ .ksr_support_700
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textAlignment .~ .center
    |> \.adjustsFontForContentSizeCategory .~ true
}

// TODO: Internationalize text
private let headingLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption1()
    |> \.textColor .~ .ksr_support_500
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text .~ "Backing means supporting a creative project, regardless of the outcome."
    |> \.textAlignment .~ .left
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.distribution .~ .fill
    |> \.alignment .~ .fill
    |> \.spacing .~ Styles.grid(3)
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

// TODO: Internationalize text
private let subtitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.textColor .~ .ksr_support_500
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text .~
    "By pledging, you acknowledge that rewards or reimbursements aren’t guaranteed by either Kickstarter or the creator."
    |> \.textAlignment .~ .left
    |> \.adjustsFontForContentSizeCategory .~ true
}
