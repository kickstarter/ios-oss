import Foundation
import ReactiveSwift
import UIKit

public enum DiscoveryProjectTagPillCellType: Equatable {
  case green
  case grey

  var backgroundColor: UIColor {
    switch self {
    case .green: return UIColor.ksr_green_500.withAlphaComponent(0.07)
    case .grey: return .ksr_grey_300
    }
  }

  var textColor: UIColor {
    switch self {
    case .green: return .ksr_green_500
    case .grey: return .ksr_dark_grey_500
    }
  }

  var imageTintColor: UIColor {
    switch self {
    case .green: return .ksr_green_500
    case .grey: return .ksr_dark_grey_500
    }
  }
}

public struct DiscoveryProjectTagPillCellValue: Equatable {
  public let type: DiscoveryProjectTagPillCellType
  public let tagIconImageName: String
  public let tagLabelText: String
}

public protocol DiscoveryProjectTagPillViewModelInputs {
  func configure(with value: DiscoveryProjectTagPillCellValue)
}

public protocol DiscoveryProjectTagPillViewModelOutputs {
  var backgroundColor: Signal<UIColor, Never> { get }
  var tagIconImageName: Signal<String, Never> { get }
  var tagIconImageTintColor: Signal<UIColor, Never> { get }
  var tagLabelText: Signal<String, Never> { get }
  var tagLabelTextColor: Signal<UIColor, Never> { get }
}

public protocol DiscoveryProjectTagPillViewModelType {
  var inputs: DiscoveryProjectTagPillViewModelInputs { get }
  var outputs: DiscoveryProjectTagPillViewModelOutputs { get }
}

public final class DiscoveryProjectTagPillViewModel: DiscoveryProjectTagPillViewModelType,
  DiscoveryProjectTagPillViewModelInputs, DiscoveryProjectTagPillViewModelOutputs {
  public init() {
    let configureWithValue = self.configureWithValueProperty.signal.skipNil()

    self.backgroundColor = configureWithValue.map { $0.type }.map(\.backgroundColor)
    self.tagLabelTextColor = configureWithValue.map { $0.type }.map(\.textColor)
    self.tagLabelText = configureWithValue.map { $0.tagLabelText }
    self.tagIconImageName = configureWithValue.map { $0.tagIconImageName }
    self.tagIconImageTintColor = configureWithValue.map { $0.type }.map(\.imageTintColor)
  }

  private let configureWithValueProperty = MutableProperty<DiscoveryProjectTagPillCellValue?>(nil)
  public func configure(with value: DiscoveryProjectTagPillCellValue) {
    self.configureWithValueProperty.value = value
  }

  public let backgroundColor: Signal<UIColor, Never>
  public let tagIconImageName: Signal<String, Never>
  public let tagIconImageTintColor: Signal<UIColor, Never>
  public let tagLabelText: Signal<String, Never>
  public let tagLabelTextColor: Signal<UIColor, Never>

  public var inputs: DiscoveryProjectTagPillViewModelInputs { return self }
  public var outputs: DiscoveryProjectTagPillViewModelOutputs { return self }
}
