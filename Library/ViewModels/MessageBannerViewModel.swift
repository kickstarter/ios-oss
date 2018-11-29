import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol MessageBannerViewModelInputs {
  func setBannerType(type: MessageBannerType)
  func setBannerMessage(message: String)
  func showBannerView(shouldShow: Bool)
  func bannerViewAnimationFinished(isHidden: Bool)
}

public protocol MessageBannerViewModelOutputs {
  var bannerBackgroundColor: Signal<UIColor, NoError> { get }
  var bannerMessage: Signal<String, NoError> { get }
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
    self.bannerBackgroundColor = self.bannerTypeProperty.signal
      .skipNil()
      .map { $0.backgroundColor }

    self.iconTintColor = self.bannerTypeProperty.signal
      .skipNil()
      .map { $0.iconImageTintColor }
      .skipNil()

    self.iconImageName = self.bannerTypeProperty.signal
      .skipNil()
      .map { $0.iconImageName }
      .skipNil()

    self.iconIsHidden = self.bannerTypeProperty.signal
      .skipNil()
      .map { $0.shouldShowIconImage }
      .negate()

    self.messageTextColor = self.bannerTypeProperty.signal
      .skipNil()
      .map { $0.textColor }

    self.messageTextAlignment = self.bannerTypeProperty.signal
      .skipNil()
      .map { $0.textAlignment }

    self.bannerMessage = self.bannerMessageProperty.signal
      .skipNil()

    let bannerViewShouldHide = self.showBannerViewProperty.signal
      .negate()

    let postAnimationBannerViewShouldHide = self.bannerViewIsHiddenProperty.signal
      .filter { isFalse($0) }
      .debounce(4, on: QueueScheduler.main)
      .negate()

    self.messageBannerViewIsHidden = Signal.merge(bannerViewShouldHide, postAnimationBannerViewShouldHide)
      .skipRepeats()
  }

  private var bannerTypeProperty = MutableProperty<MessageBannerType?>(nil)
  public func setBannerType(type: MessageBannerType) {
    self.bannerTypeProperty.value = type
  }

  private var bannerMessageProperty = MutableProperty<String?>(nil)
  public func setBannerMessage(message: String) {
    self.bannerMessageProperty.value = message
  }

  private var showBannerViewProperty = MutableProperty(false)
  public func showBannerView(shouldShow: Bool) {
    self.showBannerViewProperty.value = shouldShow
  }

  private var bannerViewIsHiddenProperty = MutableProperty(true)
  public func bannerViewAnimationFinished(isHidden: Bool) {
    self.bannerViewIsHiddenProperty.value = isHidden
  }

  public let bannerBackgroundColor: Signal<UIColor, NoError>
  public let bannerMessage: Signal<String, NoError>
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
