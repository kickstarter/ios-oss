import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Description {
    static let spacing: CGFloat = 10
  }
}

internal protocol PledgeDescriptionCellDelegate: AnyObject {
  func pledgeDescriptionCellDidPresentTrustAndSafety(_ cell: PledgeDescriptionCell)
  func pledgeDescriptionCellDidTapRewardThumbnail(_ cell: PledgeDescriptionCell)
}

final class PledgeDescriptionCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = PledgeDescriptionCellViewModel()
  internal weak var delegate: PledgeDescriptionCellDelegate?

  // MARK: - Properties

  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var descriptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var learnMoreTextView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()
  private lazy var rewardCardContainerMaskView: UIView = { UIView(frame: .zero) }()
  private var rewardCardContainerMaskViewHeightConstraint: NSLayoutConstraint?
  private var rewardCardContainerMaskViewWidthConstraint: NSLayoutConstraint?
  private lazy var rewardCardContainerView: UIView = { UIView(frame: .zero) }()
  private lazy var rewardCardView: RewardCardView = { RewardCardView(frame: .zero) |> \.delegate .~ self }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var spacerView = UIView(frame: .zero)

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
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

    _ = self.rewardCardContainerView
      |> rewardCardContainerViewStyle

    _ = self.rewardCardContainerMaskView
      |> rewardCardContainerMaskViewStyle
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.sizeAndTransformRewardCardView()
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.rewardCardContainerMaskView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rewardCardView, self.rewardCardContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rewardCardContainerView, self.rewardCardContainerMaskView)
      |> ksr_addSubviewToParent()

    self.rewardCardContainerMaskViewWidthConstraint = self.rewardCardContainerMaskView.widthAnchor
      .constraint(equalToConstant: 0)
    self.rewardCardContainerMaskViewHeightConstraint = self.rewardCardContainerMaskView.heightAnchor
      .constraint(equalToConstant: 0)

    self.rewardCardContainerMaskViewHeightConstraint?.priority = .defaultLow

    let rewardConstainerConstraints = [
      self.rewardCardContainerMaskViewWidthConstraint,
      self.rewardCardContainerMaskViewHeightConstraint
    ]
    .compact()

    NSLayoutConstraint.activate([
      self.rewardCardView.widthAnchor.constraint(equalToConstant: RewardCardView.cardWidth),
      self.rewardCardContainerView.leftAnchor.constraint(
        equalTo: self.rewardCardContainerMaskView.leftAnchor
      ),
      self.rewardCardContainerView.topAnchor.constraint(equalTo: self.rewardCardContainerMaskView.topAnchor)
    ] + rewardConstainerConstraints)

    self.configureStackView()
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

    let (actualSize, thumbnailSize) = rewardCardViewSizes(with: self.rewardCardContainerView)

    guard thumbnailSize.width > 0, thumbnailSize.height > 0 else { return }

    self.rewardCardContainerMaskViewWidthConstraint?.constant = thumbnailSize.width
    self.rewardCardContainerMaskViewHeightConstraint?.constant = thumbnailSize.height

    self.rewardCardContainerView.transform = transformFromRect(
      from: CGRect(origin: .zero, size: actualSize),
      toRect: CGRect(origin: .zero, size: thumbnailSize)
    )

    _ = self.rewardCardContainerMaskView
      |> roundedStyle(cornerRadius: Styles.grid(1))
  }

  // MARK: - Binding

  internal override func bindViewModel() {
    super.bindViewModel()

    self.dateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryText

    self.viewModel.outputs.presentTrustAndSafety
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.pledgeDescriptionCellDidPresentTrustAndSafety(self)
      }

    self.viewModel.outputs.configureRewardCardViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        guard let self = self else { return }
        self.rewardCardView.configure(with: data)
      }
  }

  // MARK: - Configuration

  internal func configureWith(value: (project: Project, reward: Reward)) {
    self.viewModel.inputs.configure(with: value)
  }
}

// MARK : - UITextViewDelegate

extension PledgeDescriptionCell: UITextViewDelegate {
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

extension PledgeDescriptionCell: RewardCardViewDelegate {
  func rewardCardView(_ rewardCardView: RewardCardView, didTapWithRewardId rewardId: Int) {
    self.delegate?.pledgeDescriptionCellDidTapRewardThumbnail(self)
  }
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(5), leftRight: Styles.grid(3))
    |> \.spacing .~ Styles.grid(3)
}

private let descriptionStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
    |> \.spacing .~ Layout.Description.spacing
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Layout.Description.spacing)
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

private let rewardCardViewStyle: ViewStyle = { (view: UIView) -> UIView in
  view
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let rewardCardContainerMaskViewStyle: ViewStyle = { (view: UIView) -> UIView in
  view
    |> \.clipsToBounds .~ true
}

private let rewardCardContainerViewStyle: ViewStyle = { (view: UIView) -> UIView in
  view
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> checkoutWhiteBackgroundStyle
    |> roundedStyle(cornerRadius: Styles.grid(3))
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
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

public func rewardCardViewSizes(with cardContainerView: UIView) -> (CGSize, CGSize) {
  let cardViewSize = cardContainerView.bounds.size
  let width = cardViewSize.width
  let height = cardViewSize.height

  let minWidth = CGFloat(100)

  // Max allowed width for the minified tile is 1/3 of the device width, minus padding
  // Max allowed height for the minified tile is 120 points
  let maxWidth = UIScreen.main.bounds.width / 3 - 2 * 20
  let aspectRatio = height / width

  let newWidth = min(maxWidth, max(width / 3, minWidth))
  let newHeight = newWidth * aspectRatio

  return (cardViewSize, .init(width: newWidth, height: newHeight))
}

func transformFromRect(from source: CGRect, toRect destination: CGRect) -> CGAffineTransform {
  return CGAffineTransform.identity
    .translatedBy(x: destination.midX - source.midX, y: destination.midY - source.midY)
    .scaledBy(x: destination.width / source.width, y: destination.height / source.height)
}
