import Library
import SwiftUI

struct LoadingBarButtonItem: View {
  @Binding var saveEnabled: Bool
  @Binding var showLoading: Bool
  let titleText: String
  let action: () -> Void

  var body: some View {
    let buttonColor = self.$saveEnabled.wrappedValue ? LegacyColors.ksr_create_700
      .swiftUIColor() : LegacyColors.ksr_create_300.swiftUIColor()

    HStack {
      if !self.showLoading {
        Button(self.titleText) {
          self.showLoading = true
          self.action()
        }
        .font(Font(UIFont.ksr_body()))
        .foregroundColor(buttonColor)
        .disabled(!self.$saveEnabled.wrappedValue)
      } else {
        ProgressView()
          .foregroundColor(LegacyColors.ksr_support_700.swiftUIColor())
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(self.titleText)
  }
}
