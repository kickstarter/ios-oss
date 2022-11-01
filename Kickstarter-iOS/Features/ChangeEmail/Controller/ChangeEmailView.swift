import Library
import SwiftUI

@available(iOS 15.0, *)
enum FieldType {
  case email
  case newEmail
  case newPassword

  var titleText: String {
    switch self {
    case .email: return Strings.Current_email()
    case .newEmail: return Strings.New_email()
    case .newPassword: return Strings.Current_password()
    }
  }

  var placeholderText: String {
    switch self {
    case .email: return ""
    case .newEmail: return Strings.login_placeholder_email()
    case .newPassword: return Strings.login_placeholder_password()
    }
  }

  var editable: Bool {
    switch self {
    case .email: return false
    case .newEmail: return true
    case .newPassword: return true
    }
  }

  var submitLabel: SubmitLabel {
    switch self {
    case .email: return .return
    case .newEmail: return .return
    case .newPassword: return .done
    }
  }

  var keyboardType: UIKeyboardType {
    switch self {
    case .email: return .default
    case .newEmail: return .emailAddress
    case .newPassword: return .default
    }
  }

  var secureField: Bool {
    switch self {
    case .email: return false
    case .newEmail: return false
    case .newPassword: return true
    }
  }

  var textColor: Color {
    switch self {
    case .email: return Color(.ksr_support_700)
    case .newEmail: return Color(.ksr_support_400)
    case .newPassword: return Color(.ksr_support_400)
    }
  }
}

@available(iOS 15.0, *)
struct ChangeEmailView: View {
  @State var emailText: String
  @State private var newEmailText = ""
  @State private var passwordText = ""
  @SwiftUI.Environment(\.defaultMinListRowHeight) var minListRow

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
          type: .email,
          valueText: $emailText
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
          type: .newEmail,
          valueText: $newEmailText
        )
        entryField(
          type: .newPassword,
          valueText: $passwordText
        )
        Color(.ksr_cell_separator).frame(width: .infinity, height: 1)
      }
      .listRowSeparator(.hidden)
      .listRowInsets(EdgeInsets())
    }
    .navigationTitle(Strings.Change_email())
    .background(Color(.ksr_support_100))
    .listStyle(.plain)
  }

  @ViewBuilder
  private func entryField(type: FieldType,
                          valueText: Binding<String>) -> some View {
    HStack {
      Text(type.titleText)
        .frame(
          maxWidth: .infinity,
          alignment: .leading
        )
        .font(Font(UIFont.ksr_body()))
        .foregroundColor(Color(.ksr_support_700))
      Spacer()

      newEntryField(type: type, valueText: valueText)
        .frame(
          maxWidth: .infinity,
          alignment: .trailing
        )
        .keyboardType(type.keyboardType)
        .font(Font(UIFont.ksr_body()))
        .foregroundColor(type.textColor)
        .lineLimit(1)
        .multilineTextAlignment(.trailing)
        .submitLabel(type.submitLabel)
        .disabled(!type.editable)
        .accessibilityElement()
        .accessibilityLabel(type.titleText)
    }
    .padding(12)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(type.titleText)
  }

  @ViewBuilder
  private func newEntryField(type: FieldType, valueText: Binding<String>) -> some View {
    if type.secureField {
      SecureField(
        "",
        text: valueText,
        prompt: Text(type.placeholderText).foregroundColor(Color(.ksr_support_400))
      )
    } else {
      TextField(
        "",
        text: valueText,
        prompt:
        Text(type.placeholderText).foregroundColor(Color(.ksr_support_400))
      )
    }
  }
}
