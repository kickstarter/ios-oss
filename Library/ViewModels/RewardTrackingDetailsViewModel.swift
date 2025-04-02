import ReactiveSwift
import UIKit

public struct RewardTrackingDetailsViewData {
  public let trackingNumber: String
  public let trackingURL: URL
  public let style: RewardTrackingDetailsViewStyle

  public init(
    trackingNumber: String,
    trackingURL: URL,
    style: RewardTrackingDetailsViewStyle = .backingDetails
  ) {
    self.trackingNumber = trackingNumber
    self.trackingURL = trackingURL
    self.style = style
  }
}

public enum RewardTrackingDetailsViewStyle {
  case activity
  case backingDetails

  var backgroundColor: UIColor {
    switch self {
    case .activity: return Colors.Background.surfacePrimary.adaptive()
    case .backingDetails: return .ksr_support_200
    }
  }

  var cornerRadius: CGFloat {
    switch self {
    case .activity: return 0.0
    case .backingDetails: return 8.0
    }
  }
}

public protocol RewardTrackingDetailsViewModelInputs {
  func configure(with data: RewardTrackingDetailsViewData)
  func trackingButtonTapped()
}

public protocol RewardTrackingDetailsViewModelOutputs {
  var backgroundColor: Signal<UIColor, Never> { get }
  var cornerRadius: Signal<CGFloat, Never> { get }
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

    self.backgroundColor = configData.map { $0.style.backgroundColor }

    self.cornerRadius = configData.map { $0.style.cornerRadius }

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.rewardTrackingNumber = configData.map {
      "Tracking #: \($0.trackingNumber)"
    }

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.rewardTrackingStatus = configData
      .ignoreValues().map {
        "Your reward has been shipped."
      }

    self.trackShipping = self.trackingButtonTappedSignal
      .combineLatest(with: configData)
      .map { $1.trackingURL }
  }

  private let (configDataSignal, configDataObserver) = Signal<RewardTrackingDetailsViewData, Never>.pipe()
  public func configure(with data: RewardTrackingDetailsViewData) {
    self.configDataObserver.send(value: data)
  }

  private let (trackingButtonTappedSignal, trackingButtonTappedObserver) = Signal<Void, Never>.pipe()
  public func trackingButtonTapped() {
    self.trackingButtonTappedObserver.send(value: ())
  }

  public var backgroundColor: Signal<UIColor, Never>
  public var cornerRadius: Signal<CGFloat, Never>
  public var rewardTrackingStatus: Signal<String, Never>
  public var rewardTrackingNumber: Signal<String, Never>
  public var trackShipping: Signal<URL, Never>

  public var inputs: RewardTrackingDetailsViewModelInputs { return self }
  public var outputs: RewardTrackingDetailsViewModelOutputs { return self }
}
