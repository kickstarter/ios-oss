import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class PledgeDescriptionViewController: UIViewController {
  // MARK: - Properties

  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var descriptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var estimatedDeliveryStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var learnMoreTextView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()
  private lazy var rewardTitleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rewardInfoStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rewardInfoBackgroundView: UIView = { UIView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: PledgeDescriptionViewModelType = PledgeDescriptionViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.descriptionStackView
      |> descriptionStackViewStyle

    _ = self.estimatedDeliveryLabel
      |> estimatedDeliveryLabelStyle

    _ = self.estimatedDeliveryStackView
      |> estimatedDeliveryStackViewStyle

    _ = self.rewardInfoBackgroundView
      |> rewardInfoBackgroundViewStyle

    _ = self.rewardTitleLabel
      |> rewardTItleLabelStyle

    _ = self.dateLabel
      |> dateLabelStyle

    _ = self.learnMoreTextView
      |> checkoutBackgroundStyle

    _ = self.learnMoreTextView
      |> learnMoreTextViewStyle

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.rewardInfoStackView
      |> rewardInfoStackViewStyle(isAccessibilityCategory)

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.estimatedDeliveryLabel, self.dateLabel], self.estimatedDeliveryStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.rewardTitleLabel, self.estimatedDeliveryStackView], self.rewardInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rewardInfoStackView, self.rewardInfoBackgroundView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.rewardInfoBackgroundView, self.learnMoreTextView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func configureStackView() {
    let views = [
      self.estimatedDeliveryLabel,
      self.dateLabel,
      self.learnMoreTextView
    ]

    _ = (views, self.descriptionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.descriptionStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - Actions

  @objc private func rewardCardTapped() {
    self.viewModel.inputs.rewardCardTapped()
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.dateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryText

    self.viewModel.outputs.presentTrustAndSafety
      .observeForUI()
      .observeValues { [weak self] in
        self?.presentHelpWebViewController(with: .trust, presentationStyle: .formSheet)
      }

    self.viewModel.outputs.configureRewardCardViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.rewardTitleLabel
          ?|> \.text .~ data.1.left?.title
      }

    self.viewModel.outputs.popViewController
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      }
  }

  // MARK: - Configuration

  internal func configureWith(value: (project: Project, reward: Reward)) {
    self.viewModel.inputs.configureWith(data: value)
  }
}

extension PledgeDescriptionViewController: UITextViewDelegate {
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

// MARK: Styles

private let descriptionStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
    |> \.spacing .~ Styles.grid(1)
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(1))
}

private let estimatedDeliveryLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text %~ { _ in Strings.Estimated_delivery_of() }
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_caption1()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let estimatedDeliveryStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> verticalStackViewStyle
}

private let dateLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_caption1()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let learnMoreTextViewStyle: TextViewStyle = { (textView: UITextView) -> UITextView in
  _ = textView
    |> tappableLinksViewStyle
    |> \.attributedText .~ attributedLearnMoreText()
    |> \.accessibilityTraits .~ [.staticText]

  return textView
}

private let rewardInfoBackgroundViewStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ .white
    |> \.clipsToBounds .~ true
    |> \.layer.cornerRadius .~ Styles.grid(2)
}

private func rewardInfoStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in

    return stackView
      |> \.alignment .~ .center
      |> \.axis .~ NSLayoutConstraint.Axis.horizontal
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(3), leftRight: Styles.grid(3))
      |> \.spacing .~ Styles.grid(2)
  }
}

private let rewardTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.numberOfLines .~ 2
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> checkoutSubStackViewStyle
    |> verticalStackViewStyle
    |> \.alignment .~ UIStackView.Alignment.top
}

private func attributedLearnMoreText() -> NSAttributedString? {
  guard let trustLink = HelpType.trust.url(
    withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
  )?.absoluteString else { return nil }

  // swiftlint:disable line_length
  let string = Strings.Kickstarter_is_not_a_store_Its_a_way_to_bring_creative_projects_to_life_Learn_more_about_accountability(
    trust_link: trustLink
  )
  // swiftlint:enable line_length

  return checkoutAttributedLink(with: string)
}
