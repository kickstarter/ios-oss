//
//  CommentTableViewFooter.swift
//  Kickstarter-Framework-iOS
//
//  Created by Afees Lawal on 02/06/2021.
//  Copyright © 2021 Kickstarter. All rights reserved.
//

import KsApi
import Library
import Prelude
import UIKit

final class CommentTableViewFooter: UIView {
  // MARK: - Properties
  private(set) lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
    return indicator
  }()
  
  public var shouldAnimateLoadMoreIndicator: Bool = false {
    didSet {
      shouldAnimateLoadMoreIndicator
        ? self.activityIndicator.startAnimating()
        : self.activityIndicator.stopAnimating()
    }
  }
  
  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.bindViewModel()
    self.configureViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var intrinsicContentSize: CGSize {
    return .init(width: self.bounds.width, height: Styles.grid(7))
  }
  
  private func configureViews() {
    _ = self |> \.autoresizingMask .~ .flexibleHeight
    _ = self |> \.backgroundColor .~ .ksr_white
    
    _ = (self.activityIndicator, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToCenterInParent()
  }
}
