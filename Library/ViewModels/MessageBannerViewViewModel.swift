import Combine
import Foundation
import SwiftUI

public final class MessageBannerViewViewModel: ObservableObject {
  @Published public var bannerBackgroundColor: Color
  @Published public var bannerMessage: String
  @Published public var bannerMessageAccessibilityLabel: String
  @Published public var iconImageName: String
  @Published public var iconIsHidden: Bool
  @Published public var iconTintColor: Color
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
    self.messageTextAlignment = configuration.type == .info ? .center : .leading
    self.messageTextColor = Color(configuration.type.textColor)
  }
}
