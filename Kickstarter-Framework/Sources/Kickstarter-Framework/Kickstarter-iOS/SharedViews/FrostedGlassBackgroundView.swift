import SwiftUI

/// Custom frosted glass background view.
public struct FrostedGlassBackgroundView: UIViewRepresentable {
  private enum Constants {
    static let red: CGFloat = 32 / 255
    static let green: CGFloat = 32 / 255
    static let blue: CGFloat = 32 / 255
    static let alpha: CGFloat = 0.60
  }

  public func makeUIView(context _: Context) -> UIView {
    let view = UIView()

    view.backgroundColor = UIColor(
      red: Constants.red,
      green: Constants.green,
      blue: Constants.blue,
      alpha: Constants.alpha
    )

    return view
  }

  public func updateUIView(_: UIView, context _: Context) {}
}
