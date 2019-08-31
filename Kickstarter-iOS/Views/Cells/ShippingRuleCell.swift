import Library
import UIKit

final class ShippingRuleCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel: ShippingRuleCellViewModelType = ShippingRuleCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.textLabel?.rac.text = self.viewModel.outputs.textLabelText

    self.viewModel.outputs.isSelected
      .observeForUI()
      .observeValues { [weak self] isSelected in
        self?.accessoryType = isSelected ? .checkmark : .none
      }
  }

  // MARK: - Configuration

  func configureWith(value: ShippingRuleData) {
    self.viewModel.inputs.configureWith(value)
  }
}
