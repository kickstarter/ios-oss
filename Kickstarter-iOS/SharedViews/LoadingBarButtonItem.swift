import Library
import SwiftUI

struct LoadingBarButtonItem: View {
  @State var titleText: String
  @State var saveEnabled: Bool

  var body: some View {
    let buttonColor = saveEnabled ? Color(.ksr_create_700) : Color(.ksr_create_300)

    HStack {
      if saveEnabled {
        Button(titleText) {
          saveEnabled.toggle()
        }
        .font(Font(UIFont.systemFont(ofSize: 17)))
        .foregroundColor(buttonColor)
      } else {
        ProgressView()
          .foregroundColor(Color(.ksr_support_700))
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(titleText)
  }
}

struct LoadingBarButtonItem_Previews: PreviewProvider {
  static var previews: some View {
    LoadingBarButtonItem(titleText: Strings.Save(), saveEnabled: true)
  }
}
