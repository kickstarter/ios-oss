import Foundation
import ReactiveSwift

public struct RewardTrackingDetailsViewData {
  public let trackingNumber: String
  public let trackingURL: URL

  public init(trackingNumber: String, trackingURL: URL) {
    self.trackingNumber = trackingNumber
    self.trackingURL = trackingURL
  }
}

public protocol RewardTrackingDetailsViewModelInputs {
  func configure(with data: RewardTrackingDetailsViewData)
  func trackingButtonTapped()
}

public protocol RewardTrackingDetailsViewModelOutputs {
  var rewardTrackingStatus: Signal<String, Never> { get }
  var rewardTrackingNumber: Signal<String, Never> { get }
  var trackShipping: Signal<URL, Never> { get }
}

public protocol RewardTrackingDetailsViewModelType {
  var inputs: RewardTrackingDetailsViewModelInputs { get }
  var outputs: RewardTrackingDetailsViewModelOutputs { get }
}

public final class RewardTrackingDetailsViewModel: RewardTrackingDetailsViewModelType,
  RewardTrackingDetailsViewModelInputs,
  RewardTrackingDetailsViewModelOutputs {
  public init() {
    let configData = self.configDataSignal

    self.rewardTrackingNumber = configData.map {
      Strings.Tracking_number(number: $0.trackingNumber)
    }

    self.rewardTrackingStatus = configData
      .ignoreValues().map {
        Strings.Your_reward_has_shipped()
      }

    self.trackShipping = configData
      .takeWhen(self.trackingButtonTappedSignal)
      .map { $0.trackingURL }
  }

  private let (configDataSignal, configDataObserver) = Signal<RewardTrackingDetailsViewData, Never>.pipe()
  public func configure(with data: RewardTrackingDetailsViewData) {
    self.configDataObserver.send(value: data)
  }

  private let (trackingButtonTappedSignal, trackingButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func trackingButtonTapped() {
    self.trackingButtonTappedObserver.send(value: ())
  }

  public var rewardTrackingStatus: Signal<String, Never>
  public var rewardTrackingNumber: Signal<String, Never>
  public var trackShipping: Signal<URL, Never>

  public var inputs: RewardTrackingDetailsViewModelInputs { return self }
  public var outputs: RewardTrackingDetailsViewModelOutputs { return self }
}
