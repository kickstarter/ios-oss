import Lottie
import SwiftUI

public struct VideoFeedCopyLinkConfirmationView: UIViewRepresentable {
  let animationName: String

  public func makeUIView(context _: Context) -> LottieAnimationView {
    let animation = LottieAnimation.named(self.animationName, bundle: .library)

    let view = LottieAnimationView(animation: animation)
    view.contentMode = .scaleAspectFit
    view.loopMode = .playOnce
    view.play()

    return view
  }

  public func updateUIView(_: LottieAnimationView, context _: Context) {}
}
