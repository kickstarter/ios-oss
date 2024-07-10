import Library
import SwiftUI

struct MessageBannerView: View {
  @Binding var viewModel: MessageBannerViewViewModel?
  @SwiftUI.Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

  var body: some View {
    if let vm = viewModel {
      HStack(alignment: .center, spacing: 12) {
        Image(vm.iconImageName, bundle: Bundle.framework)
        Text(vm.bannerMessage)
          .font(Font(UIFont.ksr_subhead()))
          .multilineTextAlignment(vm.messageTextAlignment)
          .frame(
            maxWidth: .infinity,
            minHeight: 40,
            alignment: self.alignmentFromTextAlignment(vm.messageTextAlignment)
          )
      }
      .foregroundColor(vm.messageTextColor)
      .padding(EdgeInsets(top: 16, leading: 9, bottom: 16, trailing: 9))
      .background {
        RoundedRectangle(cornerRadius: 6)
          .foregroundColor(vm.bannerBackgroundColor)
      }
      .accessibilityElement()
      .accessibilityLabel(vm.bannerMessageAccessibilityLabel)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + (self.voiceOverEnabled ? 8 : 4)) {
          self.viewModel = nil
        }
      }
      .onTapGesture {
        self.viewModel = nil
      }
    }
  }

  // MARK: - Helpers

  private func alignmentFromTextAlignment(_ textAligment: TextAlignment) -> Alignment {
    switch textAligment {
    case .center: return .center
    case .leading: return .leading
    case .trailing: return .trailing
    }
  }
}

#Preview {
  @State var viewModel: MessageBannerViewViewModel? = MessageBannerViewViewModel((.success, "Short string"))
  return MessageBannerView(viewModel: $viewModel)
}
