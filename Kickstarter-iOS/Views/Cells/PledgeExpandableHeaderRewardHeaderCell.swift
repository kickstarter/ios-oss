import Library
import Prelude
import UIKit

final class PledgeExpandableHeaderRewardHeaderCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var amountLabel: UILabel = UILabel(frame: .zero)

  private let viewModel: PledgeExpandableHeaderRewardCellViewModelType
    = PledgeExpandableHeaderRewardCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

    self.configureViews()
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
    
    _ = self.textLabel!
      |> titleLabelStyle

    _ = self.detailTextLabel!
      |> subtitleLabelStyle
    
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountAttributedText

    self.viewModel.outputs.labelText
      .observeForUI()
      .observeValues { [weak self] titleText in
        self?.detailTextLabel?.text = titleText
      }
  }

  // MARK: - Configuration

  func configureWith(value: PledgeExpandableHeaderRewardCellData) {
    self.viewModel.inputs.configure(with: value)
    self.contentView.layoutIfNeeded()
  }

  private func configureViews() {
    _ = (self.amountLabel, self.contentView)
     |> ksr_addSubviewToParent()
     |> ksr_constrainViewToTrailingMarginInParent()
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
