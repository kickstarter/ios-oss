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

    _ = self.blurView
      |> UIImageView.lens.image .~ UIImage(named: "white--gradient--layer")

    _ = self.categoryViewLabel
      |> postcardCategoryLabelStyle

    _ = self.categoryViewImageView
      |> \.tintColor .~ .ksr_dark_grey_400
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
