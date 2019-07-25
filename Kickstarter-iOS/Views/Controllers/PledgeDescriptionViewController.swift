import Foundation
import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum RewardThumbnail {
    static let maxHeight: CGFloat = 130
    static let minWidth: CGFloat = 100
  }
}

final class PledgeDescriptionViewController: UIViewController {
  // MARK: - Properties

  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var descriptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var expandIconImageView: UIImageView = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var learnMoreTextView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()
  private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
    UILongPressGestureRecognizer(
      target: self, action: #selector(PledgeDescriptionViewController.depress(_:))
    )
      |> \.minimumPressDuration .~ CheckoutConstants.RewardCard.Transition
      .DepressAnimation.longPressMinimumDuration
      |> \.delegate .~ self
      |> \.cancelsTouchesInView .~ false
  }()

  internal lazy var rewardCardContainerShadowView: UIView = { UIView(frame: .zero) }()
  internal lazy var rewardCardContainerMaskView: UIView = { UIView(frame: .zero) }()
  private var rewardCardContainerShadowViewHeightConstraint: NSLayoutConstraint?
  private var rewardCardContainerShadowViewWidthConstraint: NSLayoutConstraint?
  internal lazy var rewardCardContainerView: RewardCardContainerView = {
    RewardCardContainerView(frame: .zero)
      |> \.delegate .~ self
      |> \.isUserInteractionEnabled .~ false
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel = PledgeDescriptionViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.descriptionStackView
      |> descriptionStackViewStyle

    _ = self.estimatedDeliveryLabel
      |> checkoutBackgroundStyle
    _ = self.estimatedDeliveryLabel
      |> estimatedDeliveryLabelStyle

    _ = self.dateLabel
      |> checkoutBackgroundStyle
    _ = self.dateLabel
      |> dateLabelStyle

    _ = self.learnMoreTextView
      |> checkoutBackgroundStyle

    _ = self.learnMoreTextView
      |> learnMoreTextViewStyle

    _ = self.rewardCardContainerShadowView
      |> rewardCardContainerShadowViewStyle

    _ = self.expandIconImageView
      |> expandIconImageViewStyle

    _ = self.rewardCardContainerMaskView
      |> rewardCardContainerMaskViewStyle
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.sizeAndTransformRewardCardView()
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.rewardCardContainerShadowView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rewardCardContainerMaskView, self.rewardCardContainerShadowView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.expandIconImageView, self.rewardCardContainerShadowView)
      |> ksr_addSubviewToParent()

    _ = (self.rewardCardContainerView, self.rewardCardContainerMaskView)
      |> ksr_addSubviewToParent()

    self.rewardCardContainerShadowView.addGestureRecognizer(self.longPressGestureRecognizer)

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.rewardCardTapped))
    self.rewardCardContainerShadowView.addGestureRecognizer(tapGestureRecognizer)

    self.configureStackView()
  }

  private func setupConstraints() {
    self.rewardCardContainerShadowViewWidthConstraint = self.rewardCardContainerShadowView.widthAnchor
      .constraint(equalToConstant: 0)
    self.rewardCardContainerShadowViewHeightConstraint = self.rewardCardContainerShadowView.heightAnchor
      .constraint(equalToConstant: 0)

    let rewardCardContainerShadowViewConstraints = [
      self.rewardCardContainerShadowViewWidthConstraint,
      self.rewardCardContainerShadowViewHeightConstraint
    ]
    .compact()

    NSLayoutConstraint.activate([
      self.expandIconImageView.topAnchor
        .constraint(equalTo: self.rewardCardContainerShadowView.topAnchor, constant: -Styles.grid(1)),
      self.expandIconImageView.trailingAnchor
        .constraint(equalTo: self.rewardCardContainerShadowView.trailingAnchor, constant: Styles.grid(1)),
      self.rewardCardContainerView.widthAnchor.constraint(
        equalToConstant: CheckoutConstants.RewardCard.Layout.width
      ),
      self.rewardCardContainerView.leftAnchor.constraint(
        equalTo: self.rewardCardContainerShadowView.leftAnchor
      ),
      self.rewardCardContainerView.topAnchor.constraint(equalTo: self.rewardCardContainerShadowView.topAnchor)
    ] + rewardCardContainerShadowViewConstraints)
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

  private func sizeAndTransformRewardCardView() {
    self.rewardCardContainerView.layoutIfNeeded()

    let cardContainerViewSize = self.rewardCardContainerView.bounds.size
    let thumbnailSize = rewardCardThumbnailViewSize(
      with: cardContainerViewSize, parentWidth: self.view.bounds.width
    )
    guard thumbnailSize.width > 0, thumbnailSize.height > 0 else { return }

    self.rewardCardContainerShadowViewWidthConstraint?.constant = thumbnailSize.width
    self.rewardCardContainerShadowViewHeightConstraint?.constant = min(
      Layout.RewardThumbnail.maxHeight, thumbnailSize.height
    )

    let actualRect = CGRect(origin: .zero, size: cardContainerViewSize)
    let thumbnailRect = CGRect(origin: .zero, size: thumbnailSize)

    self.rewardCardContainerView.transform = transformFromRect(
      from: actualRect,
      toRect: thumbnailRect
    )

    self.view.setNeedsLayout()
  }

  // MARK: - Actions

  @objc private func rewardCardTapped() {
    self.viewModel.inputs.rewardCardTapped()
  }

  // MARK: - Accessors

  public func setThumbnailHidden(_ hidden: Bool) {
    _ = self.rewardCardContainerShadowView
      |> \.alpha .~ (hidden ? 0 : 1)
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.dateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryText

    self.viewModel.outputs.presentTrustAndSafety
      .observeForUI()
      .observeValues { [weak self] in
        self?.presentHelpWebViewController(with: .trust)
      }

    self.viewModel.outputs.configureRewardCardViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        guard let self = self else { return }
        self.rewardCardContainerView.configure(with: data)
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

  // MARK: - Depress Transform

  @objc private func depress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    let animator = UIViewPropertyAnimator(
      duration: CheckoutConstants.RewardCard.Transition.DepressAnimation.duration,
      curve: .linear
    ) {
      let transform: CGAffineTransform
      switch gestureRecognizer.state {
      case .changed:
        return
      case .began:
        let scale = CheckoutConstants.RewardCard.Transition.DepressAnimation.scaleFactor
        transform = CGAffineTransform(scaleX: scale, y: scale)
      default:
        transform = .identity
      }

      _ = self.rewardCardContainerShadowView
        |> \.transform .~ transform
    }

    animator.startAnimation()
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

// MARK: - RewardCardViewDelegate

extension PledgeDescriptionViewController: RewardCardViewDelegate {
  func rewardCardView(_: RewardCardView, didTapWithRewardId _: Int) {
    self.viewModel.inputs.rewardCardTapped()
  }
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.spacing .~ Styles.grid(3)
}

private let descriptionStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
    |> \.spacing .~ Styles.grid(1)
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(1))
}

private let expandIconImageViewStyle: ImageViewStyle = { (imageView: UIImageView) in
  imageView
    |> \.image .~ image(named: "icon-expansion")
}

private let estimatedDeliveryLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text %~ { _ in Strings.Estimated_delivery_of() }
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_headline()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let dateLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_headline()
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

private let rewardCardContainerMaskViewStyle: ViewStyle = { (view: UIView) -> UIView in
  view
    |> roundedStyle(cornerRadius: Styles.grid(1))
}

private let rewardCardContainerShadowViewStyle: ViewStyle = { (view: UIView) -> UIView in
  view
    |> rewardCardShadowStyle
}

private func attributedLearnMoreText() -> NSAttributedString? {
  // swiftlint:disable line_length
  let string = localizedString(
    key: "Kickstarter_is_not_a_store_Its_a_way_to_bring_creative_projects_to_life_Learn_more_about_accountability",
    defaultValue: "Kickstarter is not a store. It's a way to bring creative projects to life.</br><a href=\"%{trust_link}\">Learn more about accountability</a>",
    substitutions: [
      "trust_link": HelpType.trust.url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl)?.absoluteString
    ]
    .compactMapValues { $0.coalesceWith("") }
  )
  // swiftlint:enable line_length

  return checkoutAttributedLink(with: string)
}

// MARK: - RewardPledgeTransitionAnimatorDelegate

extension PledgeDescriptionViewController: RewardPledgeTransitionAnimatorDelegate {
  func beginTransition(_: UINavigationController.Operation) {
    self.setThumbnailHidden(true)
  }

  func snapshotData(withContainerView view: UIView) -> RewardPledgeTransitionSnapshotData? {
    guard
      let snapshotView = self.rewardCardContainerView.snapshotView(afterScreenUpdates: false),
      let sourceFrame = self.rewardCardContainerView.superview?
      .convert(self.rewardCardContainerView.frame, to: view)
    else { return nil }

    let maskFrame = CGRect(origin: .zero, size: self.rewardCardContainerShadowView.frame.size)

    return (snapshotView, sourceFrame, maskFrame)
  }

  func destinationFrameData(withContainerView view: UIView) -> RewardPledgeTransitionDestinationFrameData? {
    guard
      let containerFrame = self.rewardCardContainerView.superview?
      .convert(self.rewardCardContainerView.frame, to: view)
    else { return nil }

    let mask = self.rewardCardContainerShadowView.bounds

    return (containerFrame, mask)
  }

  func endTransition(_: UINavigationController.Operation) {
    self.setThumbnailHidden(false)
  }
}

// MARK: - UIGestureRecognizerDelegate

extension PledgeDescriptionViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    if gestureRecognizer is UILongPressGestureRecognizer, otherGestureRecognizer is UITapGestureRecognizer {
      return true
    }

    return false
  }
}

// MARK: - Reward card thumbnail size calculations

private func rewardCardThumbnailViewSize(
  with cardContainerViewSize: CGSize,
  parentWidth: CGFloat
) -> CGSize {
  let width = cardContainerViewSize.width
  let height = cardContainerViewSize.height

  let maxWidth = parentWidth / 4.5
  let aspectRatio = height / width

  let newWidth = min(maxWidth, max(width / 3, Layout.RewardThumbnail.minWidth))
  let newHeight = newWidth * aspectRatio

  return .init(width: newWidth, height: newHeight)
}

private func transformFromRect(from source: CGRect, toRect destination: CGRect) -> CGAffineTransform {
  return CGAffineTransform.identity
    .translatedBy(x: destination.midX - source.midX, y: destination.midY - source.midY)
    .scaledBy(x: destination.width / source.width, y: destination.height / source.height)
}
