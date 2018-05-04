//
//  DiscoveryProjectCategoryViewModel.swift
//  Kickstarter-iOS
//
//  Created by Isabel Barrera on 4/30/18.
//  Copyright © 2018 Kickstarter. All rights reserved.
//

import KsApi
import Result
import Prelude
import ReactiveSwift
import ReactiveExtensions

public protocol DiscoveryProjectCategoryViewModelInputs {
  func updateImageString(imageString: String)
  func updateCategoryName(name: String)
}

public protocol DiscoveryProjectCategoryViewModelOutputs {
  var categoryNameText: Signal<String, NoError> { get }
  var categoryImage: Signal<UIImage?, NoError> { get }
}

public protocol DiscoveryProjectCategoryViewModelType {
  var inputs: DiscoveryProjectCategoryViewModelInputs { get }
  var outputs: DiscoveryProjectCategoryViewModelOutputs { get }
}

public final class DiscoveryProjectCategoryViewModel: DiscoveryProjectCategoryViewModelType,
DiscoveryProjectCategoryViewModelInputs,
DiscoveryProjectCategoryViewModelOutputs {
  public var inputs: DiscoveryProjectCategoryViewModelInputs { return self }
  public var outputs: DiscoveryProjectCategoryViewModelOutputs { return self }

  public init() {
    self.categoryNameText = categoryNameTextProperty.signal.skipNil().map { $0 }
    self.categoryImage = imageStringProperty.signal.skipNil().map { UIImage(named: $0) }
  }

  public var categoryNameText: Signal<String, NoError>
  public var categoryImage: Signal<UIImage?, NoError>

  private let categoryNameTextProperty = MutableProperty<String?>(nil)
  public func updateCategoryName(name: String) {
    categoryNameTextProperty.value = name
  }

  private let imageStringProperty = MutableProperty<String?>(nil)
  public func updateImageString(imageString: String) {
    imageStringProperty.value = imageString
  }
}
