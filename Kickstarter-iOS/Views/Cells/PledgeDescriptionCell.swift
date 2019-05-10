import Library
import Prelude
import UIKit

private enum Layout {
  enum ImageView {
    static let width: CGFloat = 90
    static let height: CGFloat = 120
  }

  enum SpacerView {
    static let height: CGFloat = 10
  }
}

internal protocol PledgeDescriptionCellDelegate: class {
  func pledgeDescriptionCellDidPresentTrustAndSafety(_ cell: PledgeDescriptionCell)
}

final class PledgeDescriptionCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = PledgeDescriptionCellViewModel()
  internal weak var delegate: PledgeDescriptionCellDelegate?

  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var containerImageView: UIView = {
    return UIView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false }()
  private lazy var pledgeImageView: UIImageView = {
    return UIImageView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false }()
  private lazy var descriptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var spacerView = UIView(frame: .zero)
  private lazy var learnMoreTextView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutBackgroundStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.pledgeImageView
      |> \.backgroundColor .~ UIColor.orange

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
  }

  private func configureSubviews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.containerImageView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.pledgeImageView, self.containerImageView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.configureStackView()

    NSLayoutConstraint.activate([
      self.containerImageView.widthAnchor.constraint(equalToConstant: Layout.ImageView.width),
      self.containerImageView.heightAnchor.constraint(equalToConstant: Layout.ImageView.height),
      self.pledgeImageView.centerXAnchor.constraint(equalTo: self.containerImageView.centerXAnchor)
      ])
  }

  private func configureStackView() {
    NSLayoutConstraint.activate([
      self.spacerView.heightAnchor.constraint(equalToConstant: Layout.SpacerView.height)
    ])

    let views = [
      self.spacerView,
      self.estimatedDeliveryLabel,
      self.dateLabel,
      self.learnMoreTextView
    ]

   _ = (views, self.descriptionStackView)
    |> ksr_addArrangedSubviewsToStackView()

    if #available(iOS 11.0, *) {
      self.descriptionStackView.setCustomSpacing(10.0, after: self.dateLabel)
    } else {
      let view: UIView = {
        return UIView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
      }()
      view.heightAnchor.constraint(equalToConstant: Layout.SpacerView.height).isActive = true
      self.descriptionStackView.insertArrangedSubview(view, at: 3)
    }
    _ = ([self.descriptionStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - Binding

  internal override func bindViewModel() {
    super.bindViewModel()

    self.dateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryText

    self.viewModel.outputs.presentTrustAndSafety
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.pledgeDescriptionCellDidPresentTrustAndSafety(_self)
    }
  }

  // MARK: - Configuration

  internal func configureWith(value: String) {
    self.viewModel.inputs.configureWith(estimatedDeliveryDate: value)
  }
}

extension PledgeDescriptionCell: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment,
                in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    return false
  }

  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange,
                interaction: UITextItemInteraction) -> Bool {
    self.viewModel.inputs.learnMoreTapped()
    return false
  }
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(5), leftRight: Styles.grid(4))
    |> \.spacing .~ Styles.grid(3)
}

private let descriptionStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
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
    |> \.attributedText .~ attributedLearnMoreText()
    |> \.isScrollEnabled .~ false
    |> \.isEditable .~ false
    |> \.isUserInteractionEnabled .~ true
    |> \.adjustsFontForContentSizeCategory .~ true

  _ = textView
    |> \.textContainerInset .~ UIEdgeInsets.zero
    |> \.textContainer.lineFragmentPadding .~ 0
    |> \.linkTextAttributes .~ [
      .foregroundColor: UIColor.ksr_green_500
  ]

  return textView
}

private func attributedLearnMoreText() -> NSAttributedString {
  let string = """
  \(Strings.Kickstarter_is_not_a_store_Its_a_way_to_bring_creative_projects_to_life())
  \(Strings.Learn_more_about_accountability())
  """ as NSString

  let linkRange = string.range(of: Strings.Learn_more_about_accountability())
  let stringRange = string.range(of: string as String)

  let attributedString = NSMutableAttributedString(string: string as String)

  let url = urlForHelpType(
    HelpType.trust, baseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
  )

  attributedString.addAttribute(.font, value: UIFont.ksr_caption1(), range: stringRange)
  attributedString.addAttribute(.foregroundColor, value: UIColor.ksr_text_dark_grey_500, range: stringRange)
  attributedString.addAttribute(.link, value: url as Any, range: linkRange)

  return attributedString
}
