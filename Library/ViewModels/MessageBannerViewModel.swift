import Prelude
import ReactiveSwift
import UIKit

public typealias MessageBannerConfiguration = (type: MessageBannerType, message: String)

public protocol MessageBannerViewModelInputs {
  func bannerViewAnimationFinished(isHidden: Bool)
  func bannerViewWillShow(_ show: Bool)
  func update(with configuration: MessageBannerConfiguration)
}

public protocol MessageBannerViewModelOutputs {
  var bannerBackgroundColor: Signal<UIColor, Never> { get }
  var bannerMessage: Signal<String, Never> { get }
  var bannerMessageAccessibilityLabel: Signal<String, Never> { get }
  var iconImageName: Signal<String, Never> { get }
  var iconIsHidden: Signal<Bool, Never> { get }
  var iconTintColor: Signal<UIColor, Never> { get }
  var messageBannerViewIsHidden: Signal<Bool, Never> { get }
  var messageTextAlignment: Signal<NSTextAlignment, Never> { get }
  var messageTextColor: Signal<UIColor, Never> { get }
}

public protocol MessageBannerViewModelType {
  var inputs: MessageBannerViewModelInputs { get }
  var outputs: MessageBannerViewModelOutputs { get }
}

public class MessageBannerViewModel: MessageBannerViewModelType,
  MessageBannerViewModelInputs, MessageBannerViewModelOutputs {
  public init() {
    let bannerType = self.messageBannerConfiguration.signal
      .skipNil()
      .map(first)

    self.bannerBackgroundColor = bannerType
      .map { $0.backgroundColor }

    self.iconTintColor = bannerType
      .map { $0.iconImageTintColor }
      .skipNil()

    self.iconImageName = bannerType
      .map { $0.iconImageName }
      .skipNil()

    self.iconIsHidden = bannerType
      .map { $0.shouldShowIconImage }
      .negate()

    self.messageTextColor = bannerType.map { $0.textColor }
    self.messageTextAlignment = bannerType.map { $0.textAlignment }

    self.bannerMessage = self.messageBannerConfiguration.signal.skipNil().map(second)
    self.bannerMessageAccessibilityLabel = self.bannerMessage
      .map { "\($0) \(Strings.Message_banner_accessibility_Double_tap_to_dismiss())" }

    let bannerViewShouldHide = self.showBannerViewProperty.signal.negate()

    let dismissBanner = self.bannerViewIsHiddenProperty.signal
      .filter(isFalse)

    // Dismisses the banner after 4 seconds when VoiceOver is OFF
    // This should give the user enough time to read the banner
    let dismissBannerVoiceOverOff = dismissBanner
      .filter { _ in !AppEnvironment.current.isVoiceOverRunning() }
      .debounce(4, on: QueueScheduler.main)
      .negate()

    // Dismisses the banner after 10 seconds when VoiceOver is ON
    // This should give the VoiceOver reader enough time to read the banner
    let dismissBannerVoiceOverOn = dismissBanner
      .filter { _ in AppEnvironment.current.isVoiceOverRunning() }
      .debounce(10, on: QueueScheduler.main)
      .negate()

    let postAnimationBannerViewShouldHide = Signal.merge(
      dismissBannerVoiceOverOff,
      dismissBannerVoiceOverOn
    )

    let bannerShouldHide = Signal.merge(bannerViewShouldHide, postAnimationBannerViewShouldHide)

    self.messageBannerViewIsHidden = bannerShouldHide.skipRepeats()
  }

  private var showBannerViewProperty = MutableProperty(false)
  public func bannerViewWillShow(_ show: Bool) {
    self.showBannerViewProperty.value = show
  }

  private var bannerViewIsHiddenProperty = MutableProperty(true)
  public func bannerViewAnimationFinished(isHidden: Bool) {
    self.bannerViewIsHiddenProperty.value = isHidden
  }

  private var messageBannerConfiguration = MutableProperty<MessageBannerConfiguration?>(nil)
  public func update(with configuration: MessageBannerConfiguration) {
    self.messageBannerConfiguration.value = configuration
  }

  public let bannerBackgroundColor: Signal<UIColor, Never>
  public let bannerMessage: Signal<String, Never>
  public let bannerMessageAccessibilityLabel: Signal<String, Never>
  public let iconImageName: Signal<String, Never>
  public let iconIsHidden: Signal<Bool, Never>
  public let iconTintColor: Signal<UIColor, Never>
  public let messageBannerViewIsHidden: Signal<Bool, Never>
  public let messageTextAlignment: Signal<NSTextAlignment, Never>
  public let messageTextColor: Signal<UIColor, Never>

  public var inputs: MessageBannerViewModelInputs {
    return self
  }

  public var outputs: MessageBannerViewModelOutputs {
    return self
  }
}
