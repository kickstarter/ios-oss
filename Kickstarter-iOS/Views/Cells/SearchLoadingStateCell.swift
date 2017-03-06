import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class SearchLoadingStateCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView!

  internal func configureWith(value: Void) {
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> SearchLoadingStateCell.lens.backgroundColor .~ .clear
      |> SearchLoadingStateCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4), left: Styles.grid(24), bottom: Styles.grid(2), right: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
    }

    _ = self.loadingIndicatorView
      |> UIActivityIndicatorView.lens.animating .~ true
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.color .~ .ksr_navy_900
  }
}
