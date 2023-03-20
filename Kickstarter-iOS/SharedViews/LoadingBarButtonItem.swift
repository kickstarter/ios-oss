import Library
import SwiftUI

struct LoadingBarButtonItem: View {
  @State var titleText: String
  @State var saveEnabled: Bool
  @State private var showLoading = false

  var body: some View {
    let buttonColor = saveEnabled ? Color(.ksr_create_700) : Color(.ksr_create_300)

    HStack {
      if !showLoading {
        Button(titleText) {
          print("Saved tapped")
        }
        .font(Font(UIFont.systemFont(ofSize: 17)))
        .foregroundColor(buttonColor)
        .disabled(!saveEnabled)
      } else {
        ProgressView()
          .foregroundColor(Color(.ksr_support_700))
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(titleText)
  }
}
