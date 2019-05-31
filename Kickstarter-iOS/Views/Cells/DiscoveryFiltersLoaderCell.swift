import Library
import Prelude
import Prelude_UIKit
import UIKit

internal final class DiscoveryFiltersLoaderCell: UITableViewCell, ValueCell {
  @IBOutlet private var activityIndicator: UIActivityIndicatorView!

  internal func configureWith(value _: Void) {}

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.activityIndicator
      |> baseActivityIndicatorStyle
      |> UIActivityIndicatorView.lens.animating .~ true
  }
}
