import KDS
import SwiftUI
import WebKit

struct OEmbedBlock: View {
  var oembed: RichTextElement.OEmbed
  @Environment(\.richTextStyle) var style: any RichTextStyle

  // Just for testing, please do not use directly
  internal var onWebViewCreated: ((WKWebView) -> Void)?

  var iframeURL: URL? {
    guard let urlString = oembed.iframeUrl, !urlString.isEmpty else {
      return nil
    }

    guard var components = URLComponents(string: urlString) else {
      return nil
    }

    // Append playsinline=1 for inline video playback on iOS, matching legacy behavior.
    var queryItems = components.queryItems ?? []
    if !queryItems.contains(where: { $0.name == "playsinline" }) {
      queryItems.append(URLQueryItem(name: "playsinline", value: "1"))
    }
    components.queryItems = queryItems

    return components.url
  }

  private var aspectRatio: CGFloat? {
    guard self.oembed.width > 0, self.oembed.height > 0 else {
      return nil
    }
    return CGFloat(self.oembed.width) / CGFloat(self.oembed.height)
  }

  var body: some View {
    if let iframeURL {
      OEmbedWebView(url: iframeURL, onWebViewCreated: self.onWebViewCreated)
        .aspectRatio(self.aspectRatio ?? 16.0 / 9.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: self.style.mediaCornerRadius))
        .accessibilityElement()
        .accessibilityLabel(self.oembed.title)
        .accessibilityAddTraits(.isLink)
    }
  }
}

// MARK: - OEmbedWebView

private struct OEmbedWebView: UIViewRepresentable {
  let url: URL
  var onWebViewCreated: ((WKWebView) -> Void)?

  /// Referrer sent with embed requests so providers can validate the source domain.
  static let referrer = "https://www.kickstarter.com"

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  func makeUIView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.allowsInlineMediaPlayback = true
    configuration.suppressesIncrementalRendering = true
    configuration.mediaTypesRequiringUserActionForPlayback = .all
    configuration.applicationNameForUserAgent = "Kickstarter-iOS"

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.scrollView.isScrollEnabled = false
    webView.uiDelegate = context.coordinator

    self.onWebViewCreated?(webView)

    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {
    // Only reload when the URL actually changes, since SwiftUI can call
    // updateUIView on every state change.
    guard context.coordinator.loadedURL != self.url else { return }
    context.coordinator.loadedURL = self.url

    var request = URLRequest(url: self.url)
    request.setValue(Self.referrer, forHTTPHeaderField: "Referer")
    webView.load(request)
  }
}

// MARK: - Coordinator

extension OEmbedWebView {
  /// Coordinator that acts as WKUIDelegate to handle links targeting new windows
  /// by opening them in the system browser instead of silently dropping them.
  final class Coordinator: NSObject, WKUIDelegate {
    var loadedURL: URL?

    func webView(
      _: WKWebView,
      createWebViewWith _: WKWebViewConfiguration,
      for navigationAction: WKNavigationAction,
      windowFeatures _: WKWindowFeatures
    ) -> WKWebView? {
      let targetsNewWindow = navigationAction.targetFrame == nil
        || navigationAction.targetFrame?.isMainFrame == false

      if targetsNewWindow, let url = navigationAction.request.url {
        UIApplication.shared.open(url)
      }

      return nil
    }
  }
}
