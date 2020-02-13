import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ThanksCategoryCellViewModelInputs {
  func seeAllProjectsButtonTapped()
  func configureWith(category: KsApi.Category)
}

public protocol ThanksCategoryCellViewModelOutputs {
  var notifyDelegateToGoToDiscovery: Signal<KsApi.Category, Never> { get }
  var seeAllProjectCategoryTitle: Signal<String, Never> { get }
}

public protocol ThanksCategoryCellViewModelType {
  var inputs: ThanksCategoryCellViewModelInputs { get }
  var outputs: ThanksCategoryCellViewModelOutputs { get }
}

public final class ThanksCategoryCellViewModel: ThanksCategoryCellViewModelType,
  ThanksCategoryCellViewModelInputs, ThanksCategoryCellViewModelOutputs {
  public init() {
    let projectCategory = self.categoryProperty.signal.skipNil()

    self.seeAllProjectCategoryTitle = projectCategory.map {
      Strings.See_all_category_name_projects(category_name: $0.name)
    }

    self.notifyDelegateToGoToDiscovery = projectCategory
      .takeWhen(self.seeAllProjectsButtonTappedProperty.signal)
  }

  fileprivate let categoryProperty = MutableProperty<KsApi.Category?>(nil)
  public func configureWith(category: KsApi.Category) {
    self.categoryProperty.value = category
  }

  fileprivate let seeAllProjectsButtonTappedProperty = MutableProperty(())
  public func seeAllProjectsButtonTapped() {
    self.seeAllProjectsButtonTappedProperty.value = ()
  }

  public let seeAllProjectCategoryTitle: Signal<String, Never>
  public let notifyDelegateToGoToDiscovery: Signal<KsApi.Category, Never>

  public var inputs: ThanksCategoryCellViewModelInputs { return self }
  public var outputs: ThanksCategoryCellViewModelOutputs { return self }
}
