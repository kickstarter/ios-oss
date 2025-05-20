import KsApi
import Library
import Prelude
import UIKit

@IBDesignable internal final class DiscoveryProjectCategoryView: UIView, NibLoading {
  private let viewModel: DiscoveryProjectCategoryViewModelType = DiscoveryProjectCategoryViewModel()

  @IBOutlet private var blurView: UIImageView!
  @IBOutlet private var categoryStackView: UIStackView!
  @IBOutlet private var categoryViewImageView: UIImageView!
  @IBOutlet private var categoryViewLabel: UILabel!

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  internal func configureWith(name: String, imageNameString: String) {
    self.viewModel.inputs.configureWith(name: name, imageNameString: imageNameString)
  }

  override func bindStyles() {
    super.bindStyles()

    // There used to be a blur view behind the category icons -
    // but now it's white-on-white, so no longer visible.
    // Setting this constraint maintains the same height as the old image,
    // but without having side effects in dark mode.
    self.blurView.heightAnchor.constraint(equalToConstant: 28.0).isActive = true

    _ = self.categoryViewLabel
      |> postcardCategoryLabelStyle

    _ = self.categoryViewImageView
      |> \.tintColor .~ LegacyColors.ksr_support_300.uiColor()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.categoryViewLabel.rac.text = self.viewModel.outputs.categoryNameText

    self.viewModel.outputs.categoryImageName.signal
      .observeForUI()
      .observeValues { [weak self] imageName in
        guard let strongSelf = self else { return }
        _ = strongSelf.categoryViewImageView
          |> UIImageView.lens.image .~ image(named: imageName)
      }
  }
}
