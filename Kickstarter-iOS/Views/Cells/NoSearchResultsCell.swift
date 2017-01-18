import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class NoSearchResultsCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: NoSearchResultsCellViewModelType = NoSearchResultsCellViewModel()

  @IBOutlet fileprivate weak var noResultsLabel: UILabel!
  @IBOutlet fileprivate weak var searchTermNotFoundLabel: UILabel!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!

  internal func configureWith(value param: DiscoveryParams) {
    self.viewModel.inputs.configureWith(param: param)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> NoSearchResultsCell.lens.backgroundColor .~ .clear
      |> NoSearchResultsCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4), left: Styles.grid(24), bottom: Styles.grid(2), right: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
    }

    _ = self.noResultsLabel
      |> UILabel.lens.text %~ { _ in "No Results" }
      |> UILabel.lens.font .~ .ksr_body(size: 15)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.searchTermNotFoundLabel
      |> UILabel.lens.font .~ .ksr_body(size: 15)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.rootStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(4), leftRight: Styles.grid(4))
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.searchTermNotFoundLabel.rac.text = self.viewModel.outputs.searchTermNotFound
  }
}
