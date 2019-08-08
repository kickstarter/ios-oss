import Library
import Prelude
import Prelude_UIKit
import UIKit

final class ShippingRuleCell: UITableViewCell, ValueCell {
  // MARK: - Configuration

  func configureWith(value: String) {
    _ = self.textLabel
      ?|> \.text .~ value
  }
}
