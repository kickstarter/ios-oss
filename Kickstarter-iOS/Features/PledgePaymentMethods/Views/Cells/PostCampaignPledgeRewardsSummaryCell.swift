import Library
import Prelude
import UIKit

final class PostCampaignPledgeRewardsSummaryCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var amountLabel: UILabel = UILabel(frame: .zero)
  private lazy var rootStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var labelsStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var headerLabel: UILabel = UILabel(frame: .zero)
  private lazy var titleLabel: UILabel = UILabel(frame: .zero)

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

    _ = self.rootStackView
      |> rootStackViewStyle(self.traitCollection.preferredContentSizeCategory > .accessibilityLarge)

    _ = self.labelsStackView
      |> labelStackViewStyle

    _ = self.titleLabel
      |> labelStyle

    self.amountLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountAttributedText

    self.viewModel.outputs.headerLabelText
      .observeForUI()
      .observeValues { [weak self] text in
        guard let self, text != nil else { return }
        self.headerLabel.attributedText = text
        self.headerLabel.setNeedsLayout()
      }

    self.viewModel.outputs.labelText
      .observeForUI()
      .observeValues { [weak self] titleText in
        self?.titleLabel.text = titleText
        self?.titleLabel.setNeedsLayout()
      }
  }

  // MARK: - Configuration

  func configureWith(value: PledgeExpandableHeaderRewardCellData) {
    self.viewModel.inputs.configure(with: value)

    self.contentView.layoutIfNeeded()
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.labelsStackView, self.amountLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.headerLabel, self.titleLabel], self.labelsStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.amountLabel.topAnchor.constraint(equalTo: self.titleLabel.topAnchor)
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.headerLabel.preferredMaxLayoutWidth = self.titleLabel.frame.size.width
    self.titleLabel.preferredMaxLayoutWidth = self.titleLabel.frame.size.width
    super.layoutSubviews()
  }
}

// MARK: - Styles

private func headerLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_subhead().bolded
  label.textColor = UIColor.ksr_black
  label.numberOfLines = 0
}

private func labelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_subhead().bolded
  label.textColor = label.text == Strings.Bonus_support() ? UIColor.ksr_black : UIColor.ksr_support_400
  label.numberOfLines = 0
}

private func rootStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  let alignment: UIStackView.Alignment = (isAccessibilityCategory ? .center : .bottom)
  let axis: NSLayoutConstraint.Axis = (isAccessibilityCategory ? .vertical : .horizontal)
  let distribution: UIStackView.Distribution = (isAccessibilityCategory ? .equalSpacing : .fillProportionally)
  let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

  return { (stackView: UIStackView) in
    stackView.insetsLayoutMarginsFromSafeArea = false
    stackView.alignment = alignment
    stackView.axis = axis
    stackView.distribution = distribution
    stackView.spacing = spacing
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(
      topBottom: Styles.grid(3),
      leftRight: CheckoutConstants.PledgeView.Inset.leftRight
    )

    return stackView
  }
}

private func labelStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = NSLayoutConstraint.Axis.vertical
  stackView.distribution = .fill
  stackView.alignment = .fill
  stackView.spacing = Styles.grid(1)
  stackView.isLayoutMarginsRelativeArrangement = true
}
