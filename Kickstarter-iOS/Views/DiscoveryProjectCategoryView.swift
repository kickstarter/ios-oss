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
  
  @IBOutlet weak var categoryStackView: UIStackView!
  @IBOutlet weak var categoryViewImageView: UIImageView!
  @IBOutlet weak var categoryViewLabel: UILabel!
  
  private let categoryBlurLayer = CALayer()
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  internal func configureWith(name: String, imageNameString: String) {
    viewModel.inputs.updateImageString(imageString: imageNameString)
    viewModel.inputs.updateCategoryName(name: name)
  }
  
  override func bindStyles() {
    super.bindStyles()
    
    _ = categoryViewLabel
      |> postcardCategoryLabelStyle
    
    _ = categoryBlurLayer
      |> CALayer.lens.borderWidth .~ 2
      |> CALayer.lens.masksToBounds .~ false
      |> CALayer.lens.shadowRadius .~ 3
      |> CALayer.lens.shadowOpacity .~ 0.98
      |> CALayer.lens.shadowOffset .~ CGSize(width: -5, height: 0)
      |> CALayer.lens.shadowColor .~ UIColor.gray.cgColor
    
    self.layer.addSublayer(categoryBlurLayer)
    
    categoryBlurLayer.frame = CGRect(x: self.frame.width, y: 0, width: 1.0, height: self.frame.height)
  }
  
  internal override func bindViewModel() {
    super.bindViewModel()
    
    categoryViewLabel.rac.text = viewModel.outputs.categoryNameText
    
    viewModel.outputs.categoryImage.signal
      .observeForUI()
      .observeValues { (image) in
      _ = self.categoryViewImageView
        |> UIImageView.lens.image .~ image
    }
  }
  
  internal override func layoutSubviews() {
    super.layoutSubviews()
    
//    DispatchQueue.main.async { [weak self] in
//      guard let strongSelf = self else { return }
//
//      let frame = strongSelf.frame
//      strongSelf.categoryBlurLayer.frame = CGRect(x: frame.width, y: 0, width: 1.0, height: frame.height)
//    }
  }
}
