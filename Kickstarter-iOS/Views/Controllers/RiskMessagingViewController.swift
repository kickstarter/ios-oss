import Library
import Prelude
import Prelude_UIKit
import UIKit

protocol RiskMessagingViewControllerDelegate: AnyObject {
  func riskMessagingViewControllerDismissed(
    _ viewController: RiskMessagingViewController,
    isApplePay: Bool
  )
}

final class RiskMessagingViewController: UIViewController {
  // MARK: - Properties

  private lazy var bannerImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var bannerImageStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var bannerLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var cartIconImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var confirmButton: UIButton = { UIButton(frame: .zero) }()
  private lazy var footnoteLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var headingLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var subtitleLabel: UILabel = { UILabel(frame: .zero) }()

  internal weak var delegate: RiskMessagingViewControllerDelegate?
  private let viewModel: RiskMessagingViewModelType = RiskMessagingViewModel()

  func configure(isApplePay: Bool) {
    self.viewModel.inputs.configure(isApplePay: isApplePay)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.cartIconImageView, self.bannerLabel], self.bannerImageStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.bannerImageStackView, self.bannerImageView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (
      [self.bannerImageView, self.headingLabel, self.subtitleLabel, self.confirmButton, self.footnoteLabel],
      self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    self.setupConstraints()

    self.confirmButton.addTarget(self, action: #selector(self.confirmButtonTapped), for: .touchUpInside)

    let footnoteLabelTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(self.footnoteLabelTapped)
    )
    self.footnoteLabel.addGestureRecognizer(footnoteLabelTapGesture)
  }

  // MARK: - Actions

  @objc private func confirmButtonTapped() {
    self.viewModel.inputs.confirmButtonTapped()
  }

  @objc private func footnoteLabelTapped() {
    self.viewModel.inputs.footnoteLabelTapped()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.bannerImageView
      |> bannerImageViewStyle

    _ = self.bannerImageStackView
      |> bannerImageStackViewStyle

    _ = self.bannerLabel
      |> bannerLabelStyle

    _ = self.cartIconImageView
      |> cartIconImageViewStyle

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

    // Prevents large amount of spacing on form sheet presented for iPads
    self.headingLabel.setContentHuggingPriority(.required, for: .vertical)
    self.subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
    self.footnoteLabel.setContentHuggingPriority(.required, for: .vertical)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.confirmButton.heightAnchor
        .constraint(equalToConstant: Styles.minTouchSize.height)
        |> \.priority .~ .defaultHigh,
      self.cartIconImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Styles.grid(4))
    ])
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.dismissAndNotifyDelegate
      .observeForControllerAction()
      .observeValues { [weak self] isApplePay in
        self?.dismiss(animated: true) { [weak self] in
          guard let self = self else { return }
          self.delegate?.riskMessagingViewControllerDismissed(self, isApplePay: isApplePay)
        }
      }

    self.viewModel.outputs.presentHelpWebViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.presentHelpWebViewController(with: .trust, presentationStyle: .formSheet)
      }
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
    |> UIImageView.lens.contentMode .~ .scaleAspectFill
    |> UIImageView.lens.image .~ image(named: "risk-messaging-banner")
}

private let bannerImageStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.distribution .~ .fill
    |> \.alignment .~ .fill
    |> \.spacing .~ Styles.grid(1)
    |> \.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(10))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let bannerLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.textColor .~ .ksr_white
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text .~ Strings.Rewards_arent_guaranteed()
    |> \.textAlignment .~ .left
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let cartIconImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> UIImageView.lens.contentMode .~ .scaleAspectFit
    |> UIImageView.lens.image .~ image(named: "risk-messaging-cart")
}

private let confirmButtonStyle: ButtonStyle = { button in
  button
    |> baseButtonStyle
    |> blackButtonStyle
    |> UIButton.lens.titleLabel.lineBreakMode .~ .byWordWrapping
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_callout().bolded
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.I_understand() }
    |> UIButton.lens.contentHorizontalAlignment .~ .center
}

private let footnoteLabelStyle: LabelStyle = { label in
  label
    |> \.isUserInteractionEnabled .~ true
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ .ksr_support_700
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textAlignment .~ .center
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let headingLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption1()
    |> \.textColor .~ .ksr_support_500
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text .~ Strings.Backing_means_supporting()
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

private let subtitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.textColor .~ .ksr_support_500
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text .~ Strings.By_pledging_you_acknowledge()
    |> \.textAlignment .~ .left
    |> \.adjustsFontForContentSizeCategory .~ true
}
