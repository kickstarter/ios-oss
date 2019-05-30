import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions

public protocol DiscoveryProjectCategoryViewModelInputs {
  func configureWith(name: String, imageNameString: String)
}

public protocol DiscoveryProjectCategoryViewModelOutputs {
  var categoryNameText: Signal<String, Never> { get }
  var categoryImage: Signal<UIImage?, Never> { get }
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

  public var categoryNameText: Signal<String, Never>
  public var categoryImage: Signal<UIImage?, Never>

  private let categoryNameTextProperty = MutableProperty<String?>(nil)
  private let imageStringProperty = MutableProperty<String?>(nil)

  public func configureWith(name: String, imageNameString: String) {
    categoryNameTextProperty.value = name
    imageStringProperty.value = imageNameString
  }
}
