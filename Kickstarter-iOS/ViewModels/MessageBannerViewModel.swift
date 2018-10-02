import Foundation
import Prelude
import ReactiveSwift
import Result

protocol MessageBannerViewModelOutputs {
  var bannerBackgroundColor: Signal<UIColor, NoError> { get }
  var bannerMessage: Signal<String, NoError> { get }
  var messageBannerIsHidden: Signal<Bool, NoError> { get }
}

protocol MessageBannerViewModelInputs {
  func setBannerType(type: MessageBannerType)
  func setBannerMessage(message: String)
  func setHidden(isHidden: Bool)
}

protocol MessageBannerViewModelType {
  var inputs: MessageBannerViewModelInputs { get }
  var outputs: MessageBannerViewModelOutputs { get }
}


struct MessageBannerViewModel: MessageBannerViewModelType, MessageBannerViewModelInputs, MessageBannerViewModelOutputs {
  public init() {
    self.bannerBackgroundColor = self.bannerBackgroundColorProperty.signal
      .skipNil()
    self.bannerMessage = self.bannerMessageProperty.signal
      .skipNil()
    self.messageBannerIsHidden = self.isHiddenProperty.signal
  }

  private var bannerBackgroundColorProperty = MutableProperty<UIColor?>(nil)
  func setBannerType(type: MessageBannerType) {
    self.bannerBackgroundColorProperty.value = type.backgroundColor
  }

  private var bannerMessageProperty = MutableProperty<String?>(nil)
  func setBannerMessage(message: String) {
    self.bannerMessageProperty.value = message
  }


  private var isHiddenProperty = MutableProperty<Bool>(true)
  func setHidden(isHidden: Bool) {
    self.isHiddenProperty.value = isHidden
  }

  public let bannerBackgroundColor: Signal<UIColor, NoError>
  public let bannerMessage: Signal<String, NoError>
  public let messageBannerIsHidden: Signal<Bool, NoError>

  var inputs: MessageBannerViewModelInputs {
    return self
  }

  var outputs: MessageBannerViewModelOutputs {
    return self
  }
}
