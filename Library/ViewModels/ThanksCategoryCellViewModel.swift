import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ThanksCategoryCellViewModelInputs {
  func configureWith(category: KsApi.Category)
  func allprojectsButtonTapped()
}

public protocol ThanksCategoryCellViewModelOutputs {
  var category: Signal<KsApi.Category, Never> { get }
  var seeAllProjectsTitle: Signal<String, Never> { get }
  var notifyToGoToDiscovery: Signal<KsApi.Category, Never> { get }
}

public protocol ThanksCategoryCellViewModelType {
  var inputs: ThanksCategoryCellViewModelInputs { get }
  var outputs:ThanksCategoryCellViewModelOutputs { get }
}

public final class ThanksCategoryCellViewModel: ThanksCategoryCellViewModelType,
ThanksCategoryCellViewModelInputs, ThanksCategoryCellViewModelOutputs {
  public init() {
    let category = categoryProperty.signal.skipNil()

    self.category = category
    self.seeAllProjectsTitle = category.map { Strings.See_all_category_name_projects(category_name: $0.name) }
    self.notifyToGoToDiscovery = category
      .takeWhen(allprojectsButtonTappedProperty.signal)
  }

  fileprivate let categoryProperty = MutableProperty<KsApi.Category?>(nil)
  public func configureWith(category: KsApi.Category) {
    self.categoryProperty.value = category
  }

  fileprivate let allprojectsButtonTappedProperty = MutableProperty(())
  public func allprojectsButtonTapped() {
    self.allprojectsButtonTappedProperty.value = ()
  }

  public let category: Signal<KsApi.Category, Never>
  public let seeAllProjectsTitle: Signal<String, Never>
  public var notifyToGoToDiscovery: Signal<KsApi.Category, Never>

  public var inputs: ThanksCategoryCellViewModelInputs { return self }
  public var outputs: ThanksCategoryCellViewModelOutputs { return self }
}
