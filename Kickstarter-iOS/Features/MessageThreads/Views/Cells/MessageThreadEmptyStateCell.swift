import KsApi
import Library
import Prelude
import UIKit

internal final class MessageThreadEmptyStateCell: UITableViewCell, ValueCell {
  @IBOutlet private var titleLabel: UILabel!

  internal override func bindStyles() { super.bindStyles() }

  internal func configureWith(value _: Void) {}
}
