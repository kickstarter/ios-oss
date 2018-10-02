import Foundation
import Prelude
import ReactiveSwift
import Result

protocol MessageBannerViewModelOutputs {
  var bannerBackgroundColor: Signal<UIColor, NoError> { get }
  var bannerMessage: Signal<String, NoError> { get }
  var messageBannerViewShouldShow: Signal<Void, NoError> { get }
}

protocol MessageBannerViewModelInputs {
  func setBannerType(type: MessageBannerType)
  func setBannerMessage(message: String)
  func showBannerView()
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
    self.messageBannerViewShouldShow = self.showBannerViewProperty.signal
  }

  private var bannerBackgroundColorProperty = MutableProperty<UIColor?>(nil)
  func setBannerType(type: MessageBannerType) {
    self.bannerBackgroundColorProperty.value = type.backgroundColor
  }

  private var bannerMessageProperty = MutableProperty<String?>(nil)
  func setBannerMessage(message: String) {
    self.bannerMessageProperty.value = message
  }

  private var showBannerViewProperty = MutableProperty(())
  func showBannerView() {
    self.showBannerViewProperty.value = ()
  }

  public let bannerBackgroundColor: Signal<UIColor, NoError>
  public let bannerMessage: Signal<String, NoError>
  public let messageBannerViewShouldShow: Signal<Void, NoError>

  var inputs: MessageBannerViewModelInputs {
    return self
  }

  var outputs: MessageBannerViewModelOutputs {
    return self
  }
}
