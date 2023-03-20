import Library
import SwiftUI

enum FocusField {
  case newEmail
  case currentPassword
}

@available(iOS 15.0, *)
struct ChangeEmailView: View {
  private var warningMessage: (String, Bool) = (Strings.We_ve_been_unable_to_send_email(), true)

  private var resendVerificationEmailButtonTitle = Strings.Resend_verification_email()
  @SwiftUI.Environment(\.defaultMinListRowHeight) var minListRow
  @FocusState private var focusField: FocusField?

  private let contentPadding = 12.0
  @ObservedObject private var viewModel = ChangeEmailViewViewModel()

  private var reactiveViewModel = ChangeEmailViewModel_SwiftUIIntegrationTest()

  var body: some View {
    GeometryReader { proxy in
      List {
        Color(.ksr_support_100)
          .frame(maxWidth: .infinity, maxHeight: minListRow, alignment: .center)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())

        VStack(alignment: .center, spacing: 0) {
          InputFieldView(
            titleText: Strings.Current_email(),
            secureField: false,
            placeholderText: "",
            contentPadding: contentPadding,
            valueText: viewModel.emailText.value
          )
          .currentEmail()

          Color(.ksr_cell_separator).frame(maxWidth: .infinity, maxHeight: 1)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        /**
         if !reactiveViewModel.hideVerifyView {
           warningLabel(text: warningMessage.0, warningMessage.1)
             .frame(maxWidth: .infinity, maxHeight: minListRow, alignment: .leading)
             .background(Color(.ksr_support_100))
             .listRowSeparator(.hidden)
             .listRowInsets(EdgeInsets())
         }
         */

        if !reactiveViewModel.hideVerifyView {
          VStack(alignment: .leading, spacing: 0) {
            Button(resendVerificationEmailButtonTitle) {
              reactiveViewModel.inputs.resendVerificationEmailButtonTapped()
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
          InputFieldView(
            titleText: Strings.New_email(),
            secureField: false,
            placeholderText: Strings.login_placeholder_email(),
            contentPadding: contentPadding,
            valueText: $viewModel.newEmailText.value.wrappedValue
          )
          .newEmail()
          .focused($focusField, equals: .newEmail)
          .onSubmit {
            focusField = .currentPassword
          }

          InputFieldView(
            titleText: Strings.Current_password(),
            secureField: true,
            placeholderText: Strings.login_placeholder_password(),
            contentPadding: contentPadding,
            valueText: $viewModel.newPasswordText.value.wrappedValue
          )
          .currentPassword()
          .focused($focusField, equals: .currentPassword)
          .submitScope(viewModel.newPasswordText.value.isEmpty)
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
            saveEnabled: viewModel.savedButtonIsEnabled
          )
        }
      }
      .overlay(alignment: .bottom) {
        if reactiveViewModel.showBanner.0,
          let messageBannerViewViewModel = reactiveViewModel.showBanner.1 {
          MessageBannerView(viewModel: messageBannerViewViewModel)
            .frame(
              minWidth: proxy.size.width,
              idealWidth: proxy.size.width,
              maxHeight: proxy.size.height / 6,
              alignment: .bottom
            )
            .animation(.easeInOut)
        }
      }
      .onAppear {
        reactiveViewModel.inputs.viewDidLoad()
      }
    }
  }

  private struct InputFieldView: View {
    var titleText: String
    var secureField: Bool
    var placeholderText: String
    var contentPadding: CGFloat
    @State var valueText: String

    var body: some View {
      HStack {
        Text(titleText)
          .frame(
            maxWidth: .infinity,
            alignment: .leading
          )
          .font(Font(UIFont.ksr_body()))
          .foregroundColor(Color(.ksr_support_700))
        Spacer()

        InputFieldUserInputView(
          secureField: secureField,
          placeholderText: placeholderText,
          valueText: valueText
        )
      }
      .padding(contentPadding)
      .accessibilityElement(children: .combine)
      .accessibilityLabel(titleText)
    }
  }

  private struct InputFieldUserInputView: View {
    var secureField: Bool
    var placeholderText: String
    @State var valueText: String

    var body: some View {
      if secureField {
        SecureField(
          "",
          text: $valueText,
          prompt: Text(placeholderText).foregroundColor(Color(.ksr_support_400))
        )
      } else {
        TextField(
          "",
          text: $valueText,
          prompt:
          Text(placeholderText).foregroundColor(Color(.ksr_support_400))
        )
      }
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
