import SwiftUI

@available(iOS 15.0, *)
struct ChangeEmailView: View {
  @State var emailText: String
  @State private var newEmailText = ""
  @State private var password = ""
  @Environment(\.defaultMinListRowHeight) var minListRow

  init(emailText: String) {
    self.emailText = emailText
  }

  var body: some View {
    List {
      Color(.ksr_support_100)
        .frame(width: .infinity, height: minListRow, alignment: .center)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

      VStack(alignment: .center, spacing: 0) {
        entryField(
          textLabelText: "Current email",
          textFieldText: $emailText,
          placeholder: "Current email"
        )
        Color(.ksr_cell_separator).frame(width: .infinity, height: 1)
      }
      .listRowSeparator(.hidden)
      .listRowInsets(EdgeInsets())

      Color(.ksr_support_100)
        .frame(width: .infinity, height: minListRow, alignment: .center)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

      VStack(alignment: .center, spacing: 0) {
        entryField(
          textLabelText: "New email",
          textFieldText: $newEmailText,
          placeholder: "Email address"
        )
        entryField(
          textLabelText: "Current password",
          textFieldText: $password,
          placeholder: "Password"
        )
        Color(.ksr_cell_separator).frame(width: .infinity, height: 1)
      }
      .listRowSeparator(.hidden)
      .listRowInsets(EdgeInsets())
    }
    .background(Color(.ksr_support_100))
    .listStyle(.plain)
  }

  @ViewBuilder
  private func entryField(textLabelText: String,
                          textFieldText: Binding<String>,
                          placeholder: String) -> some View {
    HStack {
      Text(textLabelText)
        .frame(
          maxWidth: .infinity,
          alignment: .leading
        )
        .font(Font(UIFont.ksr_body()))
        .foregroundColor(Color(.ksr_support_700))
      Spacer()
      TextField("", text: textFieldText, prompt: Text(placeholder))
        .frame(
          maxWidth: .infinity,
          alignment: .trailing
        )
        .font(Font(UIFont.ksr_body()))
        .foregroundColor(Color(.ksr_support_700))
        .multilineTextAlignment(.trailing)
    }
    .padding(12)
  }
}
