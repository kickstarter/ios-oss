import Combine
import Foundation
import SwiftUI

public class MessageBannerViewViewModel: ObservableObject {
  // let pubA = PassthroughSubject<Int, Never>()

  @Published public var bannerBackgroundColor: Color
  @Published public var bannerMessage: String
  @Published var bannerMessageAccessibilityLabel: String
  @Published public var iconImageName: String
  @Published public var iconIsHidden: Bool
  @Published public var iconTintColor: Color
  @Published var messageBannerViewIsHidden: Bool
  @Published public var messageTextAlignment: TextAlignment
  @Published public var messageTextColor: Color

  public init(_ configuration: MessageBannerConfiguration) {
    self.bannerBackgroundColor = Color(configuration.type.backgroundColor)
    self.bannerMessage = configuration.message
    self
      .bannerMessageAccessibilityLabel =
      "\(configuration.message) \(Strings.Message_banner_accessibility_Double_tap_to_dismiss())"
    self.iconImageName = configuration.type.iconImageName ?? ""
    self.iconIsHidden = configuration.type.shouldShowIconImage
    self.iconTintColor = Color(configuration.type.iconImageTintColor ?? .ksr_white)
    self
      .messageBannerViewIsHidden =
      true // FIXME: - Look at how VoiceOver is mapped in `MessageBannerViewModel`
    self.messageTextAlignment = configuration.type == .info ? .center : .leading
    self.messageTextColor = Color(configuration.type.textColor)
  }
}
