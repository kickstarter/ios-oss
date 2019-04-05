import Library
import UIKit

final class PledgeRowCell: UITableViewCell, ValueCell {
  func configureWith(value: String) {
    self.textLabel?.text = value
  }
}
