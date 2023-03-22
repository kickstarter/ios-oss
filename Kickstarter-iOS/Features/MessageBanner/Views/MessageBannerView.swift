import Library
import SwiftUI

@available(iOS 15.0, *)
struct MessageBannerView: View {
  @Binding var viewModel: MessageBannerViewViewModel?

  var body: some View {
    if let vm = viewModel {
      ZStack {
        RoundedRectangle(cornerRadius: 4)
          .foregroundColor(vm.bannerBackgroundColor)
        Label(vm.bannerMessage, image: vm.iconImageName)
          .font(Font(UIFont.ksr_subhead()))
          .foregroundColor(vm.messageTextColor)
          .lineLimit(3)
          .multilineTextAlignment(vm.messageTextAlignment)
          .padding()
      }
      .accessibilityElement()
      .accessibilityLabel(vm.bannerMessageAccessibilityLabel)
      .padding()
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
          viewModel = nil
        }
      }
      .onTapGesture {
        viewModel = nil
      }
    }
  }
}
