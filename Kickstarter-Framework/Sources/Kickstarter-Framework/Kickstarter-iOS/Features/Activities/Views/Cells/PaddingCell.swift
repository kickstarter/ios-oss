import Library
import UIKit

internal final class PaddingCell: StaticTableViewCell {
  override func awakeFromNib() {
    super.awakeFromNib()
    self.accessibilityElementsHidden = true
  }
}
