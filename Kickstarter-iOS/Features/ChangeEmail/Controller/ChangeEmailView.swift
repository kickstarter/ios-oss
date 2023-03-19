import Library
import SwiftUI

enum FocusField {
  case newEmail
  case currentPassword
}

@available(iOS 15.0, *)
struct ChangeEmailView: View {
  @State var showBanner: Bool = false
  @State var emailText: String
  @State private var newEmailText = ""
  @State private var passwordText = ""
  // FIXME: Requires view model integration. In the view model output, alternate text is `Email_unverified`
  @State private var warningMessage: (String, Bool)? = (Strings.We_ve_been_unable_to_send_email(), true)
  // FIXME: Requires view moel integration. In the view model output, alternate text is `Send_verfication_email`
  @State private var resendVerificationEmailButtonTitle = Strings.Resend_verification_email()
  @State private var saveEnabled = true
  @SwiftUI.Environment(\.defaultMinListRowHeight) var minListRow
  @FocusState private var focusField: FocusField?

  private let contentPadding = 12.0
  /** FIXME: Requires view model integration. Causes the compilation of init to fail
   private var viewModel: ChangeEmailViewModelType = ChangeEmailViewModel()
   */
  private let messageBannerViewViewModel =
    MessageBannerViewViewModel((
      type: .success,
      message: Strings.Verification_email_sent()
    ))

  init(emailText: String) {
    self.emailText = emailText
  }

  var body: some View {
    GeometryReader { proxy in
      List {
        Color(.ksr_support_100)
          .frame(maxWidth: .infinity, maxHeight: minListRow, alignment: .center)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())

        VStack(alignment: .center, spacing: 0) {
          inputFieldView(
            titleText: Strings.Current_email(),
            placeholderText: "",
            secureField: false,
            valueText: $emailText
          )
          .currentEmail()

          Color(.ksr_cell_separator).frame(maxWidth: .infinity, maxHeight: 1)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        if let (warningText, alert) = warningMessage {
          warningLabel(text: warningText, alert)
            .frame(maxWidth: .infinity, maxHeight: minListRow, alignment: .leading)
            .background(Color(.ksr_support_100))
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }

        if let _ = warningMessage {
          VStack(alignment: .leading, spacing: 0) {
            Button(resendVerificationEmailButtonTitle) {
              showBanner = true
            }
            .font(Font(UIFont.ksr_body()))
            .foregroundColor(Color(.ksr_create_700))
            .padding(contentPadding)

            Color(.ksr_cell_separator).frame(maxWidth: .infinity, maxHeight: 1)
          }
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())
        }

        Color(.ksr_support_100)
          .frame(maxWidth: .infinity, maxHeight: minListRow, alignment: .center)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())

        VStack(alignment: .center, spacing: 0) {
          inputFieldView(
            titleText: Strings.New_email(),
            placeholderText: Strings.login_placeholder_email(),
            secureField: false,
            valueText: $newEmailText
          )
          .newEmail()
          .focused($focusField, equals: .newEmail)
          .onSubmit {
            focusField = .currentPassword
          }

          inputFieldView(
            titleText: Strings.Current_password(),
            placeholderText: Strings.login_placeholder_password(),
            secureField: true,
            valueText: $passwordText
          )
          .currentPassword()
          .focused($focusField, equals: .currentPassword)
          .submitScope(passwordText.isEmpty)
          .onSubmit {
            focusField = nil
          }

          Color(.ksr_cell_separator).frame(maxWidth: .infinity, maxHeight: 1)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
      }
      .navigationTitle(Strings.Change_email())
      .background(Color(.ksr_support_100))
      .listStyle(.plain)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          LoadingBarButtonItem(
            titleText: Strings.Save(),
            saveEnabled: saveEnabled
          )
        }
      }
      .overlay(alignment: .bottom) {
        MessageBannerView(viewModel: messageBannerViewViewModel, showBanner: $showBanner)
          .frame(
            minWidth: proxy.size.width,
            idealWidth: proxy.size.width,
            maxHeight: proxy.size.height / 6,
            alignment: .bottom
          )
          .animation(.easeInOut)
      }
    }
  }

  @ViewBuilder
  private func inputFieldView(titleText: String,
                              placeholderText: String,
                              secureField: Bool,
                              valueText: Binding<String>) -> some View {
    HStack {
      Text(titleText)
        .frame(
          maxWidth: .infinity,
          alignment: .leading
        )
        .font(Font(UIFont.ksr_body()))
        .foregroundColor(Color(.ksr_support_700))
      Spacer()

      inputFieldUserInputView(
        secureField: secureField,
        placeholderText: placeholderText,
        valueText: valueText
      )
    }
    .padding(self.contentPadding)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(titleText)
  }

  @ViewBuilder
  private func inputFieldUserInputView(secureField: Bool,
                                       placeholderText: String,
                                       valueText: Binding<String>) -> some View {
    if secureField {
      SecureField(
        "",
        text: valueText,
        prompt: Text(placeholderText).foregroundColor(Color(.ksr_support_400))
      )
    } else {
      TextField(
        "",
        text: valueText,
        prompt:
        Text(placeholderText).foregroundColor(Color(.ksr_support_400))
      )
    }
  }

  @ViewBuilder
  private func warningLabel(text: String, _ alert: Bool) -> some View {
    let textColor = alert ? Color(.ksr_alert) : Color(.ksr_support_400)

    Label(text, systemImage: "exclamationmark.triangle.fill")
      .labelStyle(.titleOnly)
      .font(Font(UIFont.ksr_body(size: 13)))
      .lineLimit(nil)
      .padding([.leading, .trailing], self.contentPadding)
      .foregroundColor(textColor)
  }
}
