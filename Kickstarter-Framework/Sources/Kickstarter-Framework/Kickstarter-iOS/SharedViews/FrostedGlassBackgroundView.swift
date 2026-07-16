import SwiftUI

/// Custom frosted glass background view.
struct FrostedGlassBackgroundView: View {
  var body: some View {
    ZStack {
      VideoFeedBlurView()

      Color.white.opacity(0.3)

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
      .opacity(0.45)
    }
    .opacity(0.8)
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
