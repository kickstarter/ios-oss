import Foundation
import KDS
import Library
import SwiftUI
import UIKit

/// All destinations in the VideoFeed share sheet.
enum VideoFeedShareDestination: String, CaseIterable, Identifiable {
  case copyLink
  case instagramFeed
  case x
  case instagramStories
  case facebookStories
  case whatsApp
  case facebookFeed
  case messages
  case email
  case more

  var id: String { self.rawValue }

  var usesDarkTint: Bool {
    switch self {
    case .copyLink, .x, .messages, .email, .more: return true
    default: return false
    }
  }

  // TODO: Add Translations
  var label: String {
    switch self {
    case .copyLink: return "Copy link"
    case .instagramFeed: return "Feed"
    case .x: return "X"
    case .instagramStories: return "Stories"
    case .facebookStories: return "Stories"
    case .whatsApp: return "Whatsapp"
    case .facebookFeed: return "Feed"
    case .messages: return Strings.Messages()
    case .email: return Strings.Email()
    case .more: return Strings.project_checkout_share_buttons_more()
    }
  }

  var iconAssetName: String {
    switch self {
    case .copyLink: return "share-icon-copy-link"
    case .instagramFeed: return "share-icon-instagram"
    case .x: return "share-icon-x"
    case .instagramStories: return "share-icon-instagram"
    case .facebookStories: return "share-icon-facebook"
    case .whatsApp: return "share-icon-whatsapp"
    case .facebookFeed: return "share-icon-facebook"
    case .messages: return "share-icon-messages"
    case .email: return "share-icon-email"
    case .more: return "video-feed-ellipsis-icon"
    }
  }

  /// Override for icons whose assets have extra padding.
  var iconSize: CGFloat {
    switch self {
    case .instagramFeed, .instagramStories: return 44
    default: return 28
    }
  }

  // MARK: - Availability

  /// URL schemes used to check whether the app is installed.
  /// Empty array means the destination is always available.
  private var requiredURLSchemes: [String] {
    switch self {
    case .copyLink, .messages, .email, .more:
      return []
    case .instagramFeed, .instagramStories:
      return ["instagram://"]
    case .x:
      // X rebranded from Twitter; newer builds register x-twitter://, older ones twitter://.
      return ["x-twitter://", "twitter://"]
    case .facebookFeed, .facebookStories:
      return ["fb://"]
    case .whatsApp:
      return ["whatsapp://"]
    }
  }

  /// Returns only the destinations that are available on the current device,
  static func available() -> [VideoFeedShareDestination] {
    allCases.filter { $0.isAvailable }
  }

  var isAvailable: Bool {
    let schemes = self.requiredURLSchemes

    guard !schemes.isEmpty else { return true }

    return schemes.compactMap {
      URL(string: $0)
    }.contains { UIApplication.shared.canOpenURL($0) }
  }

  static func projectURL(for item: VideoFeedItem) -> URL? {
    AppEnvironment.current.apiService.serverConfig.webBaseUrl
      .appendingPathComponent("projects/\(item.slug)")
  }

  func perform(item: VideoFeedItem) {
    let encoded = Self.encodedProjectURL(for: item)

    switch self {
    case .copyLink:
      UIPasteboard.general.string = Self.projectURL(for: item)?.absoluteString
    case .instagramFeed:
      Self.open("instagram://")
    case .instagramStories:
      Self.open("instagram-stories://share")
    case .facebookStories:
      Self.open("facebook-stories://share")
    case .x:
      guard let encoded else { return }
      Self.open("x-twitter://post?message=\(encoded)")
    case .facebookFeed:
      guard let encoded else { return }

      Self.open("https://www.facebook.com/sharer/sharer.php?u=\(encoded)")
    case .whatsApp:
      guard let encoded else { return }

      Self.open("whatsapp://send?text=\(encoded)")
    case .messages:
      guard let encoded else { return }

      Self.open("sms:?body=\(encoded)")
    case .email:
      guard let encoded else { return }

      Self.open("mailto:?body=\(encoded)")
    case .more:
      break
    }
  }

  private static func open(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }

    UIApplication.shared.open(url)
  }

  private static func encodedProjectURL(for item: VideoFeedItem) -> String? {
    self.projectURL(for: item)?.absoluteString
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
  }
}
