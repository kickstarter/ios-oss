import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ViewMoreRepliesCellViewModelInputs {
  func seeAllProjectsButtonTapped()
  func configureWith(category: KsApi.Category)
}

public protocol ViewMoreRepliesCellViewModelOutputs {
  var notifyDelegateToGoToDiscovery: Signal<KsApi.Category, Never> { get }
  var seeAllProjectCategoryTitle: Signal<String, Never> { get }
}

public protocol ViewMoreRepliesCellViewModelType {
  var inputs: ViewMoreRepliesCellViewModelInputs { get }
  var outputs: ViewMoreRepliesCellViewModelOutputs { get }
}

public final class ViewMoreRepliesCellViewModel: ViewMoreRepliesCellViewModelType,
  ViewMoreRepliesCellViewModelInputs, ViewMoreRepliesCellViewModelOutputs {
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

  public var inputs: ViewMoreRepliesCellViewModelInputs { return self }
  public var outputs: ViewMoreRepliesCellViewModelOutputs { return self }
}
