import Library
import Prelude
import UIKit

final class PledgeExpandableHeaderRewardHeaderCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var amountLabel: UILabel = UILabel(frame: .zero)
  private lazy var leftColumnStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var rootStackView: UIStackView = UIStackView(frame: .zero)
  private lazy var subtitleLabel: UILabel = UILabel(frame: .zero)
  private lazy var titleLabel: UILabel = UILabel(frame: .zero)

  private let viewModel: PledgeExpandableHeaderRewardCellViewModelType
    = PledgeExpandableHeaderRewardCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectionStyle .~ .none
      |> \.separatorInset .~ .init(leftRight: CheckoutConstants.PledgeView.Inset.leftRight)

    _ = self.amountLabel
      |> \.adjustsFontForContentSizeCategory .~ true
      |> UIView.lens.contentCompressionResistancePriority(for: .vertical) .~ UILayoutPriority.required
    

    _ = self.rootStackView
      |> rootStackViewStyle(self.traitCollection.preferredContentSizeCategory > .accessibilityLarge)

    _ = self.titleLabel
      |> titleLabelStyle
      |> UILabel.lens.contentCompressionResistancePriority(for: .vertical) .~ UILayoutPriority.required

    _ = self.subtitleLabel
      |> subtitleLabelStyle
      |> UILabel.lens.contentCompressionResistancePriority(for: .vertical) .~ UILayoutPriority.required

    _ = self.leftColumnStackView
      |> verticalStackViewStyle
      |> UIStackView.lens.contentCompressionResistancePriority(for: .vertical) .~ UILayoutPriority.required
      |> \.spacing .~ Styles.grid(1)
      
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountAttributedText

    self.viewModel.outputs.labelText
      .observeForUI()
      .observeValues { [weak self] titleText in
        self?.subtitleLabel.text = titleText
        self?.subtitleLabel.setNeedsLayout()
      }
  }

  // MARK: - Configuration
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.leftColumnStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
    ])
  }

  func configureWith(value: PledgeExpandableHeaderRewardCellData) {
    self.viewModel.inputs.configure(with: value)
    
    self.contentView.layoutIfNeeded()
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.subtitleLabel], self.leftColumnStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.leftColumnStackView, UIView(), self.amountLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  
  }
}

// MARK: - Styles

private let subtitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption1()
    |> \.textColor .~ UIColor.ksr_text_navy_600
    |> \.numberOfLines .~ 0
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.textColor .~ .ksr_text_black
    |> \.numberOfLines .~ 0
    |> \.text .~ Strings.Your_reward()
}

private func rootStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  let alignment: UIStackView.Alignment = (isAccessibilityCategory ? .leading : .top)
  let axis: NSLayoutConstraint.Axis = (isAccessibilityCategory ? .vertical : .horizontal)
  let distribution: UIStackView.Distribution = (isAccessibilityCategory ? .equalSpacing : .fill)
  let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

  return { (stackView: UIStackView) in
    stackView
      |> \.alignment .~ alignment
      |> \.axis .~ axis
      |> \.distribution .~ distribution
      |> \.spacing .~ spacing
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ .init(
        topBottom: Styles.grid(3),
        leftRight: CheckoutConstants.PledgeView.Inset.leftRight
      )
  }
}
