import Library
import SwiftUI

// TODO(MBL-1039) - Refactor this so that saveTriggered takes a closure, not a binding
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
