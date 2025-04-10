import Foundation
import ReactiveSwift

public struct RewardTrackingDetailsViewData {
  public let trackingNumber: String
  public let trackingURL: URL
  public let shippingDate: TimeInterval

  public init(trackingNumber: String, trackingURL: URL, shippingDate: TimeInterval) {
    self.trackingNumber = trackingNumber
    self.trackingURL = trackingURL
    self.shippingDate = shippingDate
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
  var shippingDays: Signal<String, Never> { get }
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

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.rewardTrackingNumber = configData.map {
      "Tracking #: \($0.trackingNumber)"
    }

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.rewardTrackingStatus = configData
      .ignoreValues().map {
        "Your reward has been shipped."
      }

    self.trackShipping = configData
      .takeWhen(self.trackingButtonTappedSignal)
      .map { $0.trackingURL }

    self.shippingDays = configData.map {
      Format.relative(secondsInUTC: $0.shippingDate)
    }
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
  public var shippingDays: Signal<String, Never>

  public var inputs: RewardTrackingDetailsViewModelInputs { return self }
  public var outputs: RewardTrackingDetailsViewModelOutputs { return self }
}
