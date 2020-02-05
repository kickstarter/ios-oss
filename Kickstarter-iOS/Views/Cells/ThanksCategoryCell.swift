import KsApi
import Library
import Prelude
import UIKit

internal protocol ThanksCategoryCellDelegate: AnyObject {
  func thanksSeeAllProjectsTapped(_ thanksCategoryCell: ThanksCategoryCell, category: KsApi.Category)
}

internal final class ThanksCategoryCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ThanksCategoryCellViewModelType = ThanksCategoryCellViewModel()

  internal weak var delegate: ThanksCategoryCellDelegate?

  @IBOutlet fileprivate var seeAllProjectsButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()

    self.seeAllProjectsButton.addTarget(self, action: #selector(self.seeAllProjectsTapped), for: .touchUpInside)
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

    self.viewModel.outputs.notifyToGoToDiscovery
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.thanksSeeAllProjectsTapped(_self, category: $0)
    }

    self.seeAllProjectsButton.rac.title = self.viewModel.outputs.seeAllProjectsTitle
  }

  @objc fileprivate func seeAllProjectsTapped() {
    self.viewModel.inputs.allprojectsButtonTapped()
  }
}
