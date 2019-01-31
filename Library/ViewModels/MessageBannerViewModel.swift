import Foundation
import Prelude
import ReactiveSwift
import Result

public typealias MessageBannerConfiguration = (type: MessageBannerType, message: String)

public protocol MessageBannerViewModelInputs {
  func bannerViewAnimationFinished(isHidden: Bool)
  func bannerViewWillShow(_ show: Bool)
  func update(with configuration: MessageBannerConfiguration)
}

public protocol MessageBannerViewModelOutputs {
  var bannerBackgroundColor: Signal<UIColor, NoError> { get }
  var bannerMessage: Signal<String, NoError> { get }
  var bannerMessageAccessibilityLabel: Signal<String, NoError> { get }
  var iconImageName: Signal<String, NoError> { get }
  var iconIsHidden: Signal<Bool, NoError> { get }
  var iconTintColor: Signal<UIColor, NoError> { get }
  var messageBannerViewIsHidden: Signal<Bool, NoError> { get }
  var messageTextAlignment: Signal<NSTextAlignment, NoError> { get }
  var messageTextColor: Signal<UIColor, NoError> { get }
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
      // todo: Needs to be localized - Strings.banner_tap_to_dismiss
      .map { "\($0) Double tap to dismiss" }

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

  public let bannerBackgroundColor: Signal<UIColor, NoError>
  public let bannerMessage: Signal<String, NoError>
  public let bannerMessageAccessibilityLabel: Signal<String, NoError>
  public let iconImageName: Signal<String, NoError>
  public let iconIsHidden: Signal<Bool, NoError>
  public let iconTintColor: Signal<UIColor, NoError>
  public let messageBannerViewIsHidden: Signal<Bool, NoError>
  public let messageTextAlignment: Signal<NSTextAlignment, NoError>
  public let messageTextColor: Signal<UIColor, NoError>

  public var inputs: MessageBannerViewModelInputs {
    return self
  }

  public var outputs: MessageBannerViewModelOutputs {
    return self
  }
}
