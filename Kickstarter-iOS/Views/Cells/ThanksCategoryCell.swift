import KsApi
import Library
import Prelude
import UIKit

internal protocol ThanksCategoryCellDelegate: AnyObject {
  func thanksSeeAllProjectsTapped(_ cell: ThanksCategoryCell, category: KsApi.Category)
}

internal final class ThanksCategoryCell: UITableViewCell, ValueCell {
  internal weak var delegate: ThanksCategoryCellDelegate?
  fileprivate let viewModel: ThanksCategoryCellViewModelType = ThanksCategoryCellViewModel()

  @IBOutlet fileprivate var seeAllProjectCategoryButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.seeAllProjectCategoryButton
      .addTarget(self, action: #selector(self.seeAllProjectCategoryTapped), for: .touchUpInside)
  }

  func configureWith(value category: KsApi.Category) {
    self.viewModel.inputs.configureWith(category: category)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.seeAllProjectCategoryButton
      |> greyButtonStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyToGoToDiscovery
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.thanksSeeAllProjectsTapped(_self, category: $0)
    }

    self.seeAllProjectCategoryButton.rac.title = self.viewModel.outputs.seeAllProjectCategoryTitle
  }

  @objc fileprivate func seeAllProjectCategoryTapped() {
    self.viewModel.inputs.allProjectCategoryButtonTapped()
  }
}
