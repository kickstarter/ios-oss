import Foundation
import Prelude
import ReactiveSwift
import Result

protocol MessageBannerViewModelInputs {
  func setBannerType(type: MessageBannerType)
  func setBannerMessage(message: String)
  func showBannerView(shouldShow: Bool)
  func bannerViewAnimationFinished(isHidden: Bool)
}

protocol MessageBannerViewModelOutputs {
  var bannerBackgroundColor: Signal<UIColor, NoError> { get }
  var bannerMessage: Signal<String, NoError> { get }
  var iconIsHidden: Signal<Bool, NoError> { get }
  var iconImage: Signal<UIImage, NoError> { get }
  var messageBannerViewIsHidden: Signal<Bool, NoError> { get }
  var messageTextAlignment: Signal<NSTextAlignment, NoError> { get }
  var messageTextColor: Signal<UIColor, NoError> { get }
}

protocol MessageBannerViewModelType {
  var inputs: MessageBannerViewModelInputs { get }
  var outputs: MessageBannerViewModelOutputs { get }
}

struct MessageBannerViewModel: MessageBannerViewModelType,
MessageBannerViewModelInputs, MessageBannerViewModelOutputs {
  public init() {
    self.bannerBackgroundColor = self.bannerTypeProperty.signal
      .skipNil()
      .map { $0.backgroundColor }

    self.iconImage = self.bannerTypeProperty.signal
      .skipNil()
      .map { $0.iconImage }
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
  func setBannerType(type: MessageBannerType) {
    self.bannerTypeProperty.value = type
  }

  private var bannerMessageProperty = MutableProperty<String?>(nil)
  func setBannerMessage(message: String) {
    self.bannerMessageProperty.value = message
  }

  private var showBannerViewProperty = MutableProperty(false)
  func showBannerView(shouldShow: Bool) {
    self.showBannerViewProperty.value = shouldShow
  }

  private var bannerViewIsHiddenProperty = MutableProperty(true)
  func bannerViewAnimationFinished(isHidden: Bool) {
    self.bannerViewIsHiddenProperty.value = isHidden
  }

  public let bannerBackgroundColor: Signal<UIColor, NoError>
  public let bannerMessage: Signal<String, NoError>
  public let iconImage: Signal<UIImage, NoError>
  public let iconIsHidden: Signal<Bool, NoError>
  public let messageBannerViewIsHidden: Signal<Bool, NoError>
  public let messageTextAlignment: Signal<NSTextAlignment, NoError>
  public let messageTextColor: Signal<UIColor, NoError>

  var inputs: MessageBannerViewModelInputs {
    return self
  }

  var outputs: MessageBannerViewModelOutputs {
    return self
  }
}
