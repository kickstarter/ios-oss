import Library
import SwiftUI

struct MessageBannerView: View {
  @Binding var viewModel: MessageBannerViewViewModel?
  @SwiftUI.Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

  private enum Constants {
    public static let defaultSpacing = Styles.grid(2)
    public static let verticalPadding = Styles.grid(3)
    public static let minTextHeight = 40.0
    public static let dismissTime = 4.0
    public static let dismissTimeVoiceoverOn = 10.0
  }

  var body: some View {
    if let vm = viewModel {
      HStack(alignment: .center, spacing: Constants.defaultSpacing) {
        if vm.iconImageName.count > 0 {
          Image(vm.iconImageName, bundle: Bundle.framework)
        }
        Text(vm.bannerMessage)
          .font(Font(UIFont.ksr_subhead()))
          .multilineTextAlignment(vm.messageTextAlignment)
          .frame(
            maxWidth: .infinity,
            minHeight: Constants.minTextHeight,
            alignment: self.alignmentFromTextAlignment(vm.messageTextAlignment)
          )
      }
      .foregroundColor(vm.messageTextColor)
      .padding(EdgeInsets(
        top: Constants.verticalPadding,
        leading: Constants.defaultSpacing,
        bottom: Constants.verticalPadding,
        trailing: Constants.defaultSpacing
      ))
      .background {
        RoundedRectangle(cornerRadius: Styles.cornerRadius)
          .foregroundColor(vm.bannerBackgroundColor)
      }
      .accessibilityElement()
      .accessibilityLabel(vm.bannerMessageAccessibilityLabel)
      .onAppear {
        let dismissTime =
          self.voiceOverEnabled ? Constants.dismissTimeVoiceoverOn : Constants.dismissTime
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissTime) {
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
