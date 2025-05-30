import Library
import Prelude
import UIKit

final class PostCampaignPledgeRewardsSummaryHeaderCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var containerStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var rootStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var subtitleLabel: UILabel = UILabel(frame: .zero)
  private lazy var titleLabel: UILabel = UILabel(frame: .zero)
  private lazy var separatorView: UIView = { UIView(frame: .zero) }()

  private let viewModel: PledgeExpandableHeaderRewardCellViewModelType
    = PledgeExpandableHeaderRewardCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectionStyle .~ .none
      |> \.separatorInset .~ .init(leftRight: CheckoutConstants.PledgeView.Inset.leftRight)

    self.applyContainerStackViewStyle(self.containerStackView)

    self.contentView.backgroundColor = LegacyColors.ksr_white.uiColor()

    _ = self.rootStackView
      |> self
      .applyRcootStackViewStyle(self.traitCollection.preferredContentSizeCategory > .accessibilityLarge)
      |> verticalStackViewStyle
      |> \.spacing .~ Styles.grid(1)

    _ = self.titleLabel
      |> self.applyTitleLabelStyle

    _ = self.subtitleLabel
      |> self.applySubtitleLabelStyle

    self.applySeparatorViewStyle(self.separatorView)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.labelText
      .observeForUI()
      .observeValues { [weak self] titleText in
        self?.subtitleLabel.text = titleText
        self?.subtitleLabel.isHidden = titleText.isEmpty
      }
  }

  // MARK: - Configuration

  func configureWith(value: PledgeSummaryRewardCellData) {
    self.viewModel.inputs.configure(with: value)
  }

  private func configureViews() {
    _ = (self.containerStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.rootStackView, self.separatorView], self.containerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.subtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.separatorView.leftAnchor
        .constraint(
          equalTo: self.rootStackView.leftAnchor,
          constant: PledgeRewardsSummaryStyles.Layout.separatorViewLeftAnchorConstant
        ),
      self.separatorView.rightAnchor
        .constraint(
          equalTo: self.rootStackView.rightAnchor,
          constant: PledgeRewardsSummaryStyles.Layout.separatorViewRightAnchorConstant
        ),
      self.separatorView.heightAnchor
        .constraint(equalToConstant: PledgeRewardsSummaryStyles.Layout.separatorViewHeight)
    ])
  }

  // MARK: - Styles

  private let applySubtitleLabelStyle: LabelStyle = { label in
    label
      |> \.font .~ UIFont.ksr_caption1()
      |> \.textColor .~ LegacyColors.ksr_support_400.uiColor()
      |> \.numberOfLines .~ 0
  }

  private let applyTitleLabelStyle: LabelStyle = { label in
    label
      |> \.font .~ UIFont.ksr_headline().bolded
      |> \.textColor .~ LegacyColors.ksr_support_700.uiColor()
      |> \.numberOfLines .~ 0
      |> \.text .~ Strings.Your_pledge()
  }

  private func applyContainerStackViewStyle(_ stackView: UIStackView) {
    stackView.axis = NSLayoutConstraint.Axis.vertical
    stackView.spacing = Styles.grid(2)
  }

  private func applyRcootStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
    let alignment: UIStackView.Alignment = (isAccessibilityCategory ? .leading : .top)
    let axis: NSLayoutConstraint.Axis = (isAccessibilityCategory ? .vertical : .horizontal)
    let distribution: UIStackView.Distribution = (isAccessibilityCategory ? .equalSpacing : .fill)
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

    return { (stackView: UIStackView) in
      stackView
        |> \.insetsLayoutMarginsFromSafeArea .~ false
        |> \.alignment .~ alignment
        |> \.axis .~ axis
        |> \.distribution .~ distribution
        |> \.spacing .~ spacing
        |> \.isLayoutMarginsRelativeArrangement .~ true
        |> \.layoutMargins .~ .init(
          topBottom: Styles.grid(1),
          leftRight: CheckoutConstants.PledgeView.Inset.leftRight
        )
    }
  }

  private func applySeparatorViewStyle(_ view: UIView) {
    view.backgroundColor = LegacyColors.ksr_support_200.uiColor()
    view.translatesAutoresizingMaskIntoConstraints = false
  }
}
