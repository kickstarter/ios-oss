import Library
import Lottie
import SwiftUI

private enum Constants {
  static let animationDuration: Double = 0.35
  static let closeIconPadding: CGFloat = 8
  static let ctaBottomPadding: CGFloat = 60
  static let horizontalPadding: CGFloat = 20
  static let lottieViewTopPadding: CGFloat = 16
  static let progressViewHeight: CGFloat = 8
  static let rootStackViewCornerRadius: CGFloat = 20
  static let rootStackViewTopPadding: CGFloat = 20
  static let titleSubtitleSpacing: CGFloat = 12
  static let verticalPadding: CGFloat = 20
  static let verticalSpacing: CGFloat = 24
}

public struct OnboardingView: View {
  @ObservedObject var viewModel: OnboardingViewModel
  @State private var currentIndex: Int = 0
  @Namespace private var animation

  private var progress: Double {
    Double(self.currentIndex + 1) / Double(self.viewModel.onboardingItems.count)
  }

  public init(viewModel: OnboardingViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    GeometryReader { geo in
      let width = geo.size.width

      ZStack {
        OnboardingStyles.backgroundColor.ignoresSafeArea()

        Image(OnboardingStyles.backgroundImage)
          .resizable()
          .scaledToFit()
          .ignoresSafeArea()

        VStack {
          self.ProgressBarView()

          ZStack {
            ForEach(Array(self.viewModel.onboardingItems.enumerated()), id: \.element.id) { index, item in
              if index == self.currentIndex {
                OnboardingItemView(
                  item: item,
                  progress: self.progress,
                  onPrimaryTap: { self.handlePrimaryTap(for: item) },
                  onSecondaryTap: { self.goToNextItem() },
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
      .onReceive(self.viewModel.triggerAppTrackingTransparencyPopup) {
        self.presentAppTrackingPopup()
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
        .frame(height: Constants.progressViewHeight)
        .clipShape(RoundedRectangle(cornerRadius: Constants.rootStackViewCornerRadius))

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

  private func handlePrimaryTap(for item: OnboardingItem) {
    switch item.type {
    case .welcome, .saveProjects:
      self.goToNextItem()
    case .enableNotifications:
      self.viewModel.getNotifiedTapped()
    case .allowTracking:
      self.viewModel.allowTrackingTapped()
    case .loginSignUp:
      self.viewModel.goToLoginSignupTapped()
    }
  }

  private func goToNextItem() {
    guard self.currentIndex < self.viewModel.onboardingItems.count - 1 else { return }

    self.currentIndex += 1
  }

  private func presentAppTrackingPopup() {
    AppEnvironment.current.appTrackingTransparency.requestAndSetAuthorizationStatus {
      self.goToNextItem()
    }
  }
}
