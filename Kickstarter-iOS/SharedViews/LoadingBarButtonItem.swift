import Library
import SwiftUI

struct LoadingBarButtonItem: View {
  @Binding var saveEnabled: Bool
  @Binding var saveTriggered: Bool
  @Binding var showLoading: Bool
  @State var titleText: String

  var body: some View {
    let buttonColor = $saveEnabled.wrappedValue ? Color(.ksr_create_700) : Color(.ksr_create_300)

    HStack {
      if !showLoading {
        Button(titleText) {
          showLoading = true
          saveTriggered = true
        }
        .font(Font(UIFont.systemFont(ofSize: 17)))
        .foregroundColor(buttonColor)
        .disabled(!$saveEnabled.wrappedValue)
      } else {
        ProgressView()
          .foregroundColor(Color(.ksr_support_700))
          .onDisappear {
            saveTriggered = false
          }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(titleText)
  }
}
