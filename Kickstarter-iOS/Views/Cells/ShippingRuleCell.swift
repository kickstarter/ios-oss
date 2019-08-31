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
    self.rac.accessoryType = self.viewModel.outputs.accessoryType
  }

  // MARK: - Configuration

  func configureWith(value: ShippingRuleData) {
    self.viewModel.inputs.configureWith(value)
  }
}
