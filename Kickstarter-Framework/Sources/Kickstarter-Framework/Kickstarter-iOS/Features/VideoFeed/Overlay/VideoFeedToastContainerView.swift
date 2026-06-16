import SwiftUI

/// Manages error/confirmation toasts in a `VideoFeedCell`.
/// Hosted in a `UIHostingController`.
struct VideoFeedToastContainerView: View {
  private enum Constants {
    static let spacing: CGFloat = 8
    static let autoDismissDelay: Double = 3.0
  }

  var videoErrorMessage: String?
  var saveErrorMessage: String?
  var onSaveErrorDismissed: (() -> Void)?

  var hasError: Bool {
    self.videoErrorMessage != nil || self.saveErrorMessage != nil
  }

  var body: some View {
    VStack(spacing: Constants.spacing) {
      if let message = self.saveErrorMessage {
        VideoFeedToastView(message: message)
          .transition(.move(edge: .top).combined(with: .opacity))
      }

      if let message = self.videoErrorMessage {
        VideoFeedToastView(message: message)
          .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .animation(.spring(duration: 0.35, bounce: 0.2), value: self.saveErrorMessage)
    .animation(.spring(duration: 0.35, bounce: 0.2), value: self.videoErrorMessage)
    .onChange(of: self.saveErrorMessage) { _, newValue in
      guard newValue != nil else { return }

      DispatchQueue.main.asyncAfter(deadline: .now() + Constants.autoDismissDelay) {
        withAnimation {
          self.onSaveErrorDismissed?()
        }
      }
    }
  }
}
