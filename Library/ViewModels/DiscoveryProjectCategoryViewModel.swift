import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

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
    self.categoryNameText = self.categoryNameTextProperty.signal.skipNil().map { $0 }
    self.categoryImage = self.imageStringProperty.signal.skipNil().map { UIImage(named: $0) }
  }

  public var categoryNameText: Signal<String, Never>
  public var categoryImage: Signal<UIImage?, Never>

  private let categoryNameTextProperty = MutableProperty<String?>(nil)
  private let imageStringProperty = MutableProperty<String?>(nil)

  public func configureWith(name: String, imageNameString: String) {
    self.categoryNameTextProperty.value = name
    self.imageStringProperty.value = imageNameString
  }
}
