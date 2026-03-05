import KDS
import Library
import SwiftUI

struct LoadingBarButtonItem: View {
  @Binding var saveEnabled: Bool
  @Binding var showLoading: Bool
  let titleText: String
  let action: () -> Void

  var body: some View {
    HStack {
      if !self.showLoading {
        self.styledButton
      } else {
        ProgressView()
          .foregroundColor(LegacyColors.ksr_support_700.swiftUIColor())
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(self.titleText)
  }

  @ViewBuilder
  private var styledButton: some View {
    let buttonColor = self.$saveEnabled.wrappedValue ? LegacyColors.ksr_create_700
      .swiftUIColor() : LegacyColors.ksr_create_300.swiftUIColor()

    let button = Button(self.titleText) {
      self.showLoading = true
      self.action()
    }
    .font(Font(UIFont.ksr_body()))
    .disabled(!self.$saveEnabled.wrappedValue)
    if #available(iOS 26, *) {
      button.glassEffect()
    } else {
      button.foregroundStyle(buttonColor)
    }
  }
}
