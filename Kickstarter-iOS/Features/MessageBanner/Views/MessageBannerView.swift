import Library
import SwiftUI

@available(iOS 15.0, *)
struct MessageBannerView: View {
  @ObservedObject var viewModel: MessageBannerViewViewModel
  @State var showBanner = true

  var body: some View {
    if showBanner {
      ZStack {
        RoundedRectangle(cornerRadius: 4)
          .foregroundColor(viewModel.bannerBackgroundColor)
        Label(viewModel.bannerMessage, image: viewModel.iconImageName)
          .font(Font(UIFont.ksr_subhead()))
          .foregroundColor(viewModel.messageTextColor)
          .lineLimit(3)
          .multilineTextAlignment(viewModel.messageTextAlignment)
          .padding()
      }
      .accessibilityElement()
      .accessibilityLabel(viewModel.bannerMessageAccessibilityLabel)
      .padding()
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
          showBanner = false
        }
      }
      .onTapGesture {
        showBanner = false
      }
    }
  }
}
