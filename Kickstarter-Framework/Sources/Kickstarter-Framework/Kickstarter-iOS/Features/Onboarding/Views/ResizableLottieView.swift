import Library
import Lottie
import SwiftUI

struct ResizableLottieView: UIViewRepresentable {
  var onboardingItem: OnboardingItem
  var isVisible: Bool

  func makeUIView(context _: Context) -> LottieAnimationView {
    let animationView = self.onboardingItem.lottieView
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .loop
    return animationView
  }

  func updateUIView(_ uiView: LottieAnimationView, context _: Context) {
    if self.isVisible && !uiView.isAnimationPlaying {
      uiView.play()
    } else if !self.isVisible {
      uiView.stop()
    }
  }
}
