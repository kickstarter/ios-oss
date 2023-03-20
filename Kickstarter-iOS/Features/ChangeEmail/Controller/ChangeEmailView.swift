import Combine
import Library
import SwiftUI

enum FocusField {
  case newEmail
  case currentPassword
}

@available(iOS 15.0, *)
struct ChangeEmailView: View {
  @SwiftUI.Environment(\.defaultMinListRowHeight) var minListRow
  @FocusState private var focusField: FocusField?
  var cancellables = Set<AnyCancellable>()
  private let contentPadding = 12.0
  @ObservedObject private var viewModel = ChangeEmailViewViewModel()

  @ObservedObject private var reactiveViewModel = ChangeEmailViewModel_SwiftUIIntegrationTest()
  @State private var newEmailText = ""
  @State private var newPasswordText = ""
  @State private var saveEnabled = false
  @State private var saveTriggered = false

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
            valueText: $reactiveViewModel.retrievedEmailText.value
          )
          .currentEmail()

          Color(.ksr_cell_separator).frame(maxWidth: .infinity, maxHeight: 1)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        if !reactiveViewModel.hideMessageLabel {
          warningLabel(
            text: reactiveViewModel.warningMessageWithAlert.0,
            reactiveViewModel.warningMessageWithAlert.1
          )
          .frame(maxWidth: .infinity, maxHeight: minListRow, alignment: .leading)
          .background(Color(.ksr_support_100))
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())
        }

        if !reactiveViewModel.hideVerifyView {
          VStack(alignment: .leading, spacing: 0) {
            Button(reactiveViewModel.verifyEmailButtonTitle) {
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
            valueText: $newEmailText
          )
          .onChange(of: newEmailText) { newValue in
            reactiveViewModel.newEmailText.send(newValue)
          }
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
            valueText: $newPasswordText
          )
          .onChange(of: newPasswordText) { newValue in
            reactiveViewModel.newPasswordText.send(newValue)
          }
          .currentPassword()
          .focused($focusField, equals: .currentPassword)
          .submitScope(viewModel.newPasswordText.value.isEmpty)
          .onSubmit {
            focusField = nil
            
            // FIXME: Maybe this should live in the view model?
            if saveEnabled {
              saveTriggered = true
              reactiveViewModel.saveTriggered.send(true)
            }
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
            saveEnabled: $saveEnabled,
            saveTriggered: $saveTriggered,
            titleText: Strings.Save()
          )
          .onReceive(reactiveViewModel.saveButtonEnabled) { newValue in
            saveEnabled = newValue
          }
          .onChange(of: saveTriggered) { newValue in
            focusField = nil
            reactiveViewModel.saveTriggered.send(newValue)
          }
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
    var valueText: Binding<String>

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
    var valueText: Binding<String>

    var body: some View {
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
