import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ThanksCategoryCellViewModelInputs {
  func allProjectCategoryButtonTapped()
  func configureWith(category: KsApi.Category)
}

public protocol ThanksCategoryCellViewModelOutputs {
  var notifyToGoToDiscovery: Signal<KsApi.Category, Never> { get }
  var seeAllProjectCategoryTitle: Signal<String, Never> { get }
}

public protocol ThanksCategoryCellViewModelType {
  var inputs: ThanksCategoryCellViewModelInputs { get }
  var outputs:ThanksCategoryCellViewModelOutputs { get }
}

public final class ThanksCategoryCellViewModel: ThanksCategoryCellViewModelType,
ThanksCategoryCellViewModelInputs, ThanksCategoryCellViewModelOutputs {
  public init() {
    let projectCategory = categoryProperty.signal.skipNil()

    self.seeAllProjectCategoryTitle = projectCategory.map {
      Strings.See_all_category_name_projects(category_name: $0.name)
    }

    self.notifyToGoToDiscovery = projectCategory
      .takeWhen(allProjectCategoryButtonTappedProperty.signal)
  }

  fileprivate let categoryProperty = MutableProperty<KsApi.Category?>(nil)
  public func configureWith(category: KsApi.Category) {
    self.categoryProperty.value = category
  }

  fileprivate let allProjectCategoryButtonTappedProperty = MutableProperty(())
  public func allProjectCategoryButtonTapped() {
    self.allProjectCategoryButtonTappedProperty.value = ()
  }

  public let seeAllProjectCategoryTitle: Signal<String, Never>
  public let notifyToGoToDiscovery: Signal<KsApi.Category, Never>

  public var inputs: ThanksCategoryCellViewModelInputs { return self }
  public var outputs: ThanksCategoryCellViewModelOutputs { return self }
}
