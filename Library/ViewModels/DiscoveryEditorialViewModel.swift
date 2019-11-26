import Foundation
import KsApi
import ReactiveSwift

public struct DiscoveryEditorialCellValue: Equatable {
  public let title: String
  public let subtitle: String
  public let imageName: String
  public let tagId: DiscoveryParams.TagID
}

public protocol DiscoveryEditorialViewModelInputs {
  func configureWith(_ value: DiscoveryEditorialCellValue)
  func editorialCellTapped()
}

public protocol DiscoveryEditorialViewModelOutputs {
  var imageName: Signal<String, Never> { get }
  var notifyDelegateViewTapped: Signal<DiscoveryParams.TagID, Never> { get }
  var subtitleText: Signal<String, Never> { get }
  var titleText: Signal<String, Never> { get }
}

public protocol DiscoveryEditorialViewModelType {
  var inputs: DiscoveryEditorialViewModelInputs { get }
  var outputs: DiscoveryEditorialViewModelOutputs { get }
}

public final class DiscoveryEditorialViewModel: DiscoveryEditorialViewModelType,
  DiscoveryEditorialViewModelInputs, DiscoveryEditorialViewModelOutputs {
  public init() {
    let configureWithValue = self.configureWithValueProperty.signal.skipNil()

    self.imageName = configureWithValue.map(\.imageName)
    self.titleText = configureWithValue.map(\.title)
    self.subtitleText = configureWithValue.map(\.subtitle)

    self.notifyDelegateViewTapped = configureWithValue
      .takeWhen(self.editorialCellTappedSignal)
      .map { $0.tagId }
  }

  private let configureWithValueProperty = MutableProperty<DiscoveryEditorialCellValue?>(nil)
  public func configureWith(_ value: DiscoveryEditorialCellValue) {
    self.configureWithValueProperty.value = value
  }

  private let (editorialCellTappedSignal, editorialCellTappedObserver) = Signal<Void, Never>.pipe()
  public func editorialCellTapped() {
    self.editorialCellTappedObserver.send(value: ())
  }

  public let imageName: Signal<String, Never>
  public let subtitleText: Signal<String, Never>
  public let titleText: Signal<String, Never>
  public let notifyDelegateViewTapped: Signal<DiscoveryParams.TagID, Never>

  public var inputs: DiscoveryEditorialViewModelInputs { return self }
  public var outputs: DiscoveryEditorialViewModelOutputs { return self }
}
