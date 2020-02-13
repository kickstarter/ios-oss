import KsApi
import Library
import Prelude
import UIKit

internal protocol ThanksCategoryCellDelegate: AnyObject {
  func thanksCategoryCell(_ cell: ThanksCategoryCell, didTapSeeAllProjectsWith category: KsApi.Category)
}

internal final class ThanksCategoryCell: UITableViewCell, ValueCell {
  internal weak var delegate: ThanksCategoryCellDelegate?
  fileprivate let viewModel: ThanksCategoryCellViewModelType = ThanksCategoryCellViewModel()

  @IBOutlet fileprivate var seeAllProjectsButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.seeAllProjectsButton
      .addTarget(self, action: #selector(self.seeAllProjectsButtonTapped), for: .touchUpInside)
  }

  func configureWith(value category: KsApi.Category) {
    self.viewModel.inputs.configureWith(category: category)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.seeAllProjectsButton
      |> greyButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateToGoToDiscovery
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.thanksCategoryCell(self, didTapSeeAllProjectsWith: $0)
      }

    self.seeAllProjectsButton.rac.title = self.viewModel.outputs.seeAllProjectCategoryTitle
  }

  @objc fileprivate func seeAllProjectsButtonTapped() {
    self.viewModel.inputs.seeAllProjectsButtonTapped()
  }
}
