import Library
import Lottie
import SwiftUI

private enum Constants {
  static let animationDuration: Double = 0.35
  static let closeIconPadding: CGFloat = 8
  static let ctaBottomPadding: CGFloat = 60
  static let verticalPadding: CGFloat = 20
  static let horizontalPadding: CGFloat = 20
  static let lottieViewTopPadding: CGFloat = 16
  static let rootStackViewTopPadding: CGFloat = 20
  static let titleSubtitleSpacing: CGFloat = 12
  static let verticalSpacing: CGFloat = 24
}

struct OnboardingView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  @State private var currentIndex: Int = 0
  @Namespace private var animation

  private var progress: Double {
    Double(self.currentIndex + 1) / Double(self.viewModel.onboardingItems.count)
  }

  var body: some View {
    GeometryReader { geo in
      let width = geo.size.width

      ZStack {
        OnboardingStyles.backgroundColor.ignoresSafeArea()

        VStack {
          self.ProgressBarView()

          ZStack {
            ForEach(Array(self.viewModel.onboardingItems.enumerated()), id: \.element.id) { index, item in
              if index == self.currentIndex {
                OnboardingItemView(
                  item: item,
                  progress: self.progress,
                  onPrimaryTap: { self.handlePrimaryTap(for: item, viewWidth: width) },
                  onSecondaryTap: { self.handleNext(viewWidth: width) },
                  onLoginSignup: { self.viewModel.goToLoginSignupTapped() }
                )
                .transition(.asymmetric(
                  insertion: .move(edge: .trailing).combined(with: .opacity),
                  removal: .move(edge: .leading).combined(with: .opacity)
                ))
              }
            }
          }
          .animation(.easeInOut(duration: Constants.animationDuration), value: self.currentIndex)
        }
        .padding(.top)
      }
    }
  }

  // MARK: - ViewBuilders

  private func ProgressBarView() -> some View {
    HStack {
      ProgressView(value: self.progress)
        .background(.white)
        .progressViewStyle(LinearProgressViewStyle(tint: OnboardingStyles.progressBarTintColor))
        .scaleEffect(x: 1, y: 2)
        .animation(.easeInOut(duration: Constants.animationDuration), value: self.progress)
        .frame(height: 8)
        .clipShape(RoundedRectangle(cornerRadius: 20))

      Button(action: {
        withAnimation {
          self.currentIndex = 0
        }
      }) {
        Image(OnboardingStyles.closeImage)
          .font(Font(OnboardingStyles.subtitle))
          .foregroundColor(.black)
          .padding(Constants.closeIconPadding)
          .clipShape(Circle())
      }
    }
    .padding(.top, Constants.verticalPadding)
    .padding(.horizontal, Constants.horizontalPadding)
  }

  // MARK: - Helpers

  private func handlePrimaryTap(for item: OnboardingItem, viewWidth: CGFloat) {
    switch item.type {
    case .welcome, .saveProjects, .enableNotifications, .allowTracking:
      self.handleNext(viewWidth: viewWidth)
    case .loginSignUp:
      self.viewModel.goToLoginSignupTapped()
    }
  }

  private func handleNext(viewWidth _: CGFloat) {
    guard self.currentIndex < self.viewModel.onboardingItems.count - 1 else { return }

    self.currentIndex += 1
    self.playAnimation()
  }

  private func playAnimation() {
    self.viewModel.onboardingItems[self.currentIndex].lottieView.play()
  }
}
