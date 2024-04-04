import Library
import SwiftUI

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
          .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
      }
      .accessibilityElement()
      .accessibilityLabel(vm.bannerMessageAccessibilityLabel)
      .padding()
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
          self.viewModel = nil
        }
      }
      .onTapGesture {
        self.viewModel = nil
      }
    }
  }
}
