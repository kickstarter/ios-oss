//
//  DiscoveryProjectCategoryView.swift
//  Kickstarter-iOS
//
//  Created by Isabel Barrera on 4/30/18.
//  Copyright © 2018 Kickstarter. All rights reserved.
//

import KsApi
import Library
import Prelude
import UIKit

@IBDesignable internal final class DiscoveryProjectCategoryView: UIView, NibLoading {
  private let viewModel: DiscoveryProjectCategoryViewModelType = DiscoveryProjectCategoryViewModel()

  @IBOutlet private weak var blurView: UIImageView!
  @IBOutlet private weak var categoryStackView: UIStackView!
  @IBOutlet private weak var categoryViewImageView: UIImageView!
  @IBOutlet private weak var categoryViewLabel: UILabel!

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  internal func configureWith(name: String, imageNameString: String) {
    viewModel.inputs.updateImageString(imageString: imageNameString)
    viewModel.inputs.updateCategoryName(name: name)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = blurView
      |> UIImageView.lens.image .~ UIImage(named: "white--gradient--layer")

    _ = categoryViewLabel
      |> postcardCategoryLabelStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    categoryViewLabel.rac.text = viewModel.outputs.categoryNameText

    viewModel.outputs.categoryImage.signal
      .observeForUI()
      .observeValues { [weak self] (image) in
        guard let strongSelf = self else { return }
      _ = strongSelf.categoryViewImageView
        |> UIImageView.lens.image .~ image
    }
  }
}
