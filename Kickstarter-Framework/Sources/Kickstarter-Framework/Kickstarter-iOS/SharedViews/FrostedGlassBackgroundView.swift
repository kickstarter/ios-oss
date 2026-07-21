import KDS
import SwiftUI

/// Custom frosted glass background view.
struct FrostedGlassBackgroundView: View {
  var body: some View {
    VideoFeedBlurView()
  }
}

struct VideoFeedBlurView: UIViewRepresentable {
  private enum Constants {
    static let alpha: Double = 0.15
  }

  var style: UIBlurEffect.Style = .systemUltraThinMaterial

  func makeUIView(context _: Context) -> UIVisualEffectView {
    let blurEffect = UIBlurEffect(style: style)
    let view = UIVisualEffectView(effect: blurEffect)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let tintView = UIView()
    tintView.backgroundColor = UIColor.black.withAlphaComponent(Constants.alpha)
    tintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.contentView.addSubview(tintView)

    return view
  }

  func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
    uiView.effect = UIBlurEffect(style: self.style)
  }
}
