import Library
import SwiftUI

struct LoadingBarButtonItem: View {
  @Binding var saveEnabled: Bool
  @Binding var showLoading: Bool
  let titleText: String
  let action: () -> Void

  var body: some View {
    let buttonColor = $saveEnabled.wrappedValue ? Color(.ksr_create_700) : Color(.ksr_create_300)

    HStack {
      if !showLoading {
        Button(titleText) {
          showLoading = true
          action()
        }
        .font(Font(UIFont.systemFont(ofSize: 17)))
        .foregroundColor(buttonColor)
        .disabled(!$saveEnabled.wrappedValue)
      } else {
        ProgressView()
          .foregroundColor(Color(.ksr_support_700))
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(titleText)
  }
}
