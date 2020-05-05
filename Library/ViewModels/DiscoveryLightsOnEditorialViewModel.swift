import Foundation
import KsApi
import ReactiveSwift

public struct DiscoveryLightsOnEditorialCellValue: Equatable {
  public let title: String
  public let subtitle: String
  public let imageName: String
}

public protocol DiscoveryLightsOnEditorialViewModelInputs {
  func configureWith(_ value: DiscoveryLightsOnEditorialCellValue)
}

public protocol DiscoveryLightsOnEditorialViewModelOutputs {
  var imageName: Signal<String, Never> { get }
  var subtitleText: Signal<String, Never> { get }
  var titleText: Signal<String, Never> { get }
}

public protocol DiscoveryLightsOnEditorialViewModelType {
  var inputs: DiscoveryLightsOnEditorialViewModelInputs { get }
  var outputs: DiscoveryLightsOnEditorialViewModelOutputs { get }
}

public final class DiscoveryLightsOnEditorialViewModel: DiscoveryLightsOnEditorialViewModelType,
  DiscoveryLightsOnEditorialViewModelInputs, DiscoveryLightsOnEditorialViewModelOutputs {
  public init() {
    let configureWithValue = self.configureWithValueProperty.signal.skipNil()

    self.imageName = configureWithValue.map(\.imageName)
    self.titleText = configureWithValue.map(\.title)
    self.subtitleText = configureWithValue.map(\.subtitle)
  }

  private let configureWithValueProperty = MutableProperty<DiscoveryLightsOnEditorialCellValue?>(nil)
  public func configureWith(_ value: DiscoveryLightsOnEditorialCellValue) {
    self.configureWithValueProperty.value = value
  }

  public let imageName: Signal<String, Never>
  public let subtitleText: Signal<String, Never>
  public let titleText: Signal<String, Never>

  public var inputs: DiscoveryLightsOnEditorialViewModelInputs { return self }
  public var outputs: DiscoveryLightsOnEditorialViewModelOutputs { return self }
}
