import Foundation
import KsApi
import ReactiveSwift

public struct DiscoveryLightsOnEditorialCellValue: Equatable {
  public let title: String
  public let subtitle: String
  public let imageName: String
  public let tagId: DiscoveryParams.TagID
}

public protocol DiscoveryLightsOnEditorialViewModelInputs {
  func configureWith(_ value: DiscoveryLightsOnEditorialCellValue)
  func lightsOnCellTapped()
}

public protocol DiscoveryLightsOnEditorialViewModelOutputs {
  var imageName: Signal<String, Never> { get }
  var notifyDelegateViewTapped: Signal<DiscoveryParams.TagID, Never> { get }
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

    self.notifyDelegateViewTapped = configureWithValue
      .takeWhen(self.lightsOnCellTappedProperty.signal)
      .map{ $0.tagId }
  }

  private let configureWithValueProperty = MutableProperty<DiscoveryLightsOnEditorialCellValue?>(nil)
  public func configureWith(_ value: DiscoveryLightsOnEditorialCellValue) {
    self.configureWithValueProperty.value = value
  }

  private let lightsOnCellTappedProperty = MutableProperty<Void>(())
  public func lightsOnCellTapped() {
    self.lightsOnCellTappedProperty.value = ()
  }

  public let imageName: Signal<String, Never>
  public let notifyDelegateViewTapped: Signal<DiscoveryParams.TagID, Never>
  public let subtitleText: Signal<String, Never>
  public let titleText: Signal<String, Never>

  public var inputs: DiscoveryLightsOnEditorialViewModelInputs { return self }
  public var outputs: DiscoveryLightsOnEditorialViewModelOutputs { return self }
}
