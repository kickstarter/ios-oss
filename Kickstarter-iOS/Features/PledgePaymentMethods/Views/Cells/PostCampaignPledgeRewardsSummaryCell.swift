import Library
import Prelude
import UIKit

private enum PledgeRewardsSummaryCellLabelType {
  case reward
  case bonusSupport
}

final class PostCampaignPledgeRewardsSummaryCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var amountLabel: UILabel = UILabel(frame: .zero)
  private lazy var containerStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var rootStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var titleLabel: UILabel = UILabel(frame: .zero)
  private lazy var separatorView: UIView = { UIView(frame: .zero) }()

  private var labelType: PledgeRewardsSummaryCellLabelType = .reward

  private let viewModel: PledgeExpandableHeaderRewardCellViewModelType
    = PledgeExpandableHeaderRewardCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.bindViewModel()
    self.setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    self.selectionStyle = .none
    self.separatorInset = UIEdgeInsets(leftRight: CheckoutConstants.PledgeView.Inset.leftRight)

    self.amountLabel.adjustsFontForContentSizeCategory = true

    self.containerStackViewStyle(self.containerStackView)

    self.rootStackViewStyle(self.rootStackView)

    self.labelStyle(self.titleLabel)

    self.amountLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    self.separatorViewStyle(self.separatorView)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountAttributedText

    self.viewModel.outputs.labelText
      .observeForUI()
      .observeValues { [weak self] titleText in
        self?.titleLabel.text = titleText
        self?.labelType = titleText == Strings.Bonus_support() ? .bonusSupport : .reward
        self?.titleLabel.setNeedsLayout()
      }
  }

  // MARK: - Configuration

  func configureWith(value: PledgeExpandableHeaderRewardCellData) {
    self.viewModel.inputs.configure(with: value)

    self.contentView.layoutIfNeeded()
  }

  private func configureViews() {
    _ = (self.containerStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.rootStackView, self.separatorView], self.containerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleLabel, self.amountLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.amountLabel.topAnchor.constraint(equalTo: self.titleLabel.topAnchor),
      self.separatorView.leftAnchor
        .constraint(equalTo: self.rootStackView.leftAnchor, constant: Styles.grid(4)),
      self.separatorView.rightAnchor
        .constraint(equalTo: self.rootStackView.rightAnchor, constant: -Styles.grid(4)),
      self.separatorView.heightAnchor.constraint(equalToConstant: 1)
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.titleLabel.preferredMaxLayoutWidth = self.titleLabel.frame.size.width
    super.layoutSubviews()
  }

  // MARK: - Styles

  private func labelStyle(_ label: UILabel) {
    label.font = UIFont.ksr_subhead().bolded
    label.textColor = self.labelType == .bonusSupport ? UIColor.ksr_black : UIColor.ksr_support_400
    label.numberOfLines = 0
  }

  private func rootStackViewStyle(_ stackView: UIStackView) {
    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory > .accessibilityLarge
    let alignment: UIStackView.Alignment = (isAccessibilityCategory ? .center : .bottom)
    let axis: NSLayoutConstraint.Axis = (isAccessibilityCategory ? .vertical : .horizontal)
    let distribution: UIStackView
      .Distribution = (isAccessibilityCategory ? .equalSpacing : .fillProportionally)
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

    stackView.insetsLayoutMarginsFromSafeArea = false
    stackView.alignment = alignment
    stackView.axis = axis
    stackView.distribution = distribution
    stackView.spacing = spacing
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(
      top: self.labelType == .bonusSupport ? 0 : Styles.grid(3),
      left: CheckoutConstants.PledgeView.Inset.leftRight,
      bottom: Styles.grid(3),
      right: CheckoutConstants.PledgeView.Inset.leftRight
    )
  }

  private func containerStackViewStyle(_ stackView: UIStackView) {
    stackView.axis = NSLayoutConstraint.Axis.vertical
    stackView.spacing = 0
  }

  private func separatorViewStyle(_ view: UIView) {
    view.backgroundColor = .ksr_support_200
    view.translatesAutoresizingMaskIntoConstraints = false
  }
}
