import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class SearchLegacyEmptyStateCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SearchLegacyEmptyStateCellViewModelType = SearchLegacyEmptyStateCellViewModel()

  @IBOutlet fileprivate var noResultsLabel: UILabel!
  @IBOutlet fileprivate var searchTermNotFoundLabel: UILabel!
  @IBOutlet fileprivate var rootStackView: UIStackView!

  internal func configureWith(value param: DiscoveryParams) {
    self.viewModel.inputs.configureWith(param: param)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> SearchLegacyEmptyStateCell.lens.backgroundColor .~ .clear
      |> SearchLegacyEmptyStateCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4), left: Styles.grid(24), bottom: Styles.grid(2), right: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
      }

    _ = self.noResultsLabel
      |> UILabel.lens.text %~ { _ in Strings.No_Results() }
      |> UILabel.lens.font .~ .ksr_body(size: 15)
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()

    _ = self.searchTermNotFoundLabel
      |> UILabel.lens.font .~ .ksr_body(size: 15)
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.rootStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(4), leftRight: Styles.grid(4))
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.searchTermNotFoundLabel.rac.text = self.viewModel.outputs.searchTermNotFoundLabelText
  }
}
