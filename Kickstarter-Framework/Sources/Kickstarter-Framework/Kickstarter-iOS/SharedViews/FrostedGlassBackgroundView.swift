import SwiftUI

/// Custom frosted glass background view.
public struct FrostedGlassBackgroundView: UIViewRepresentable {
  private enum Constants {
    static let blurRadius: CGFloat = 6.05
    static let overlayRed: CGFloat = 132 / 255
    static let overlayGreen: CGFloat = 132 / 255
    static let overlayBlue: CGFloat = 132 / 255
    static let overlayAlpha: CGFloat = 0.24
  }

  public func makeUIView(context _: Context) -> UIVisualEffectView {
    let blur = UIBlurEffect(style: .systemUltraThinMaterial)
    let view = UIVisualEffectView(effect: blur)

    view.backgroundColor = UIColor(
      red: Constants.overlayRed,
      green: Constants.overlayGreen,
      blue: Constants.overlayBlue,
      alpha: Constants.overlayAlpha
    )
    return view
  }

  public func updateUIView(_: UIVisualEffectView, context _: Context) {}
}
