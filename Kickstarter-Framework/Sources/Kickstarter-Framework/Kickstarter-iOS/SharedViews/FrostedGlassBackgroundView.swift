import KDS
import SwiftUI

/// Custom frosted glass background view.
struct FrostedGlassBackgroundView: View {
  private enum Constants {
    static let overlayOpacity: Double = 0.6
  }

  var body: some View {
    ZStack {
      VideoFeedBlurView()

      Color(Colors.Background.Accent.Gray.frosted.uiColor())

      LinearGradient(
        stops: [
          .init(color: Color.white.opacity(0.25), location: 0.0),
          .init(color: Color.white.opacity(0.10), location: 0.4),
          .init(color: Color.clear, location: 0.65),
          .init(color: Color.black.opacity(0.10), location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
      )
    }
    .opacity(Constants.overlayOpacity)
  }
}

struct VideoFeedBlurView: UIViewRepresentable {
  var style: UIBlurEffect.Style = .systemThickMaterialDark

  func makeUIView(context _: Context) -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: self.style))
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    return view
  }

  func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
    uiView.effect = UIBlurEffect(style: self.style)
  }
}
