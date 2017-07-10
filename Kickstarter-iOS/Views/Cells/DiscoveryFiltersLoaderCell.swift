import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DiscoveryFiltersLoaderCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

  internal func configureWith(value: Void) {}

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.activityIndicator
      |> UIActivityIndicatorView.lens.animating .~ true
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.color .~ .ksr_grey_900
  }
}
