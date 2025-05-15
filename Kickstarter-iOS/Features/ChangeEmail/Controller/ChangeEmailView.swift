import Combine
import Library
import SwiftUI

enum FocusField {
  case newEmail
  case currentPassword
}

struct ChangeEmailView: View {
  @SwiftUI.Environment(\.defaultMinListRowHeight) var minListRow
  @FocusState private var focusField: FocusField?
  private let contentPadding = 12.0
  @ObservedObject private var reactiveViewModel = ChangeEmailViewModelSwiftUIIntegrationTest()
  @State private var retrievedEmailText = ""
  @State private var newEmailText = ""
  @State private var newPasswordText = ""
  @State private var saveEnabled = false
  @State private var showLoading = false
  @State private var showBannerMessage = false
  @State private var bannerMessage: MessageBannerViewViewModel?

  var body: some View {
    GeometryReader { proxy in
      List {
        LegacyColors.ksr_support_100.swiftUIColor()
          .frame(maxWidth: .infinity, maxHeight: self.minListRow, alignment: .center)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())

        VStack(alignment: .center, spacing: 0) {
          InputFieldView(
            titleText: Strings.Current_email(),
            secureField: false,
            placeholderText: "",
            contentPadding: self.contentPadding,
            valueText: self.$retrievedEmailText
          )
          .currentEmail()
          .onReceive(self.reactiveViewModel.retrievedEmailText) { newValue in
            self.retrievedEmailText = newValue
          }

          LegacyColors.ksr_cell_separator.swiftUIColor().frame(maxWidth: .infinity, maxHeight: 1)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())

        if !self.reactiveViewModel.hideMessageLabel {
          self.warningLabel(
            text: self.reactiveViewModel.warningMessageWithAlert.0,
            self.reactiveViewModel.warningMessageWithAlert.1
          )
          .frame(maxWidth: .infinity, maxHeight: self.minListRow, alignment: .leading)
          .background(LegacyColors.ksr_support_100.swiftUIColor())
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())
        }

        if !self.reactiveViewModel.hideVerifyView {
          VStack(alignment: .leading, spacing: 0) {
            Button(self.reactiveViewModel.verifyEmailButtonTitle) {
              self.reactiveViewModel.inputs.resendVerificationEmailButtonTapped()
            }
            .font(Font(UIFont.ksr_body()))
            .foregroundColor(LegacyColors.ksr_create_700.swiftUIColor())
            .padding(self.contentPadding)
            .disabled(self.showLoading)

            LegacyColors.ksr_cell_separator.swiftUIColor().frame(maxWidth: .infinity, maxHeight: 1)
          }
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())
        }

        LegacyColors.ksr_support_100.swiftUIColor()
          .frame(maxWidth: .infinity, maxHeight: self.minListRow, alignment: .center)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())

        VStack(alignment: .center, spacing: 0) {
          InputFieldView(
            titleText: Strings.New_email(),
            secureField: false,
            placeholderText: Strings.login_placeholder_email(),
            contentPadding: self.contentPadding,
            valueText: self.$newEmailText
          )
          .onReceive(self.reactiveViewModel.resetEditableText) { newValue in
            if newValue {
              self.newEmailText = ""
            }
          }
          .onChange(of: self.newEmailText) { newValue in
            self.reactiveViewModel.newEmailText.send(newValue)
          }
          .newEmail(editable: !self.showLoading)
          .focused(self.$focusField, equals: .newEmail)
          .onSubmit {
            self.focusField = .currentPassword
          }

          InputFieldView(
            titleText: Strings.Current_password(),
            secureField: true,
            placeholderText: Strings.login_placeholder_password(),
            contentPadding: self.contentPadding,
            valueText: self.$newPasswordText
          )
          .onChange(of: self.newPasswordText) { newValue in
            self.reactiveViewModel.currentPasswordText.send(newValue)
          }
          .currentPassword(editable: !self.showLoading)
          .focused(self.$focusField, equals: .currentPassword)
          .onReceive(self.reactiveViewModel.resetEditableText) { resetFlag in
            if resetFlag {
              self.newPasswordText = ""
            }
          }
          // FIXME: So "Done" on keyboard doesn't trigger Save --> in the future we might want to add this (was in the old `ChangeEmailViewController`)

          LegacyColors.ksr_cell_separator.swiftUIColor().frame(maxWidth: .infinity, maxHeight: 1)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
      }
      .navigationTitle(Strings.Change_email())
      .background(LegacyColors.ksr_support_100.swiftUIColor())
      .listStyle(.plain)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          LoadingBarButtonItem(
            saveEnabled: self.$saveEnabled,
            showLoading: self.$showLoading,
            titleText: Strings.Save()
          ) {
            self.focusField = nil
            self.reactiveViewModel.didTapSaveButton()
          }
          .onReceive(self.reactiveViewModel.saveButtonEnabled) { newValue in
            self.saveEnabled = newValue
          }
          .onReceive(self.reactiveViewModel.resetEditableText) { newValue in
            self.showLoading = !newValue
          }
        }
      }
      .overlay(alignment: .bottom) {
        MessageBannerView(viewModel: self.$bannerMessage)
          .frame(
            minWidth: proxy.size.width,
            idealWidth: proxy.size.width,
            maxHeight: proxy.size.height / 5,
            alignment: .bottom
          )
          .animation(.easeInOut)
      }
      .onReceive(self.reactiveViewModel.bannerMessage) { newValue in
        self.bannerMessage = newValue
      }
      .onAppear {
        self.reactiveViewModel.inputs.viewDidLoad()
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
        Text(self.titleText)
          .frame(
            maxWidth: .infinity,
            alignment: .leading
          )
          .font(Font(UIFont.ksr_body()))
          .foregroundColor(LegacyColors.ksr_support_700.swiftUIColor())
        Spacer()

        InputFieldUserInputView(
          secureField: self.secureField,
          placeholderText: self.placeholderText,
          valueText: self.valueText
        )
      }
      .padding(self.contentPadding)
      .accessibilityElement(children: .combine)
      .accessibilityLabel(self.titleText)
    }
  }

  private struct InputFieldUserInputView: View {
    var secureField: Bool
    var placeholderText: String
    var valueText: Binding<String>

    var body: some View {
      if self.secureField {
        SecureField(
          "",
          text: self.valueText,
          prompt: Text(self.placeholderText).foregroundColor(LegacyColors.ksr_support_400.swiftUIColor())
        )
      } else {
        TextField(
          "",
          text: self.valueText,
          prompt:
          Text(self.placeholderText).foregroundColor(LegacyColors.ksr_support_400.swiftUIColor())
        )
      }
    }
  }

  @ViewBuilder
  private func warningLabel(text: String, _ alert: Bool) -> some View {
    let textColor = alert ? LegacyColors.ksr_alert.swiftUIColor() : LegacyColors.ksr_support_400
      .swiftUIColor()

    Label(text, systemImage: "exclamationmark.triangle.fill")
      .labelStyle(.titleOnly)
      .font(Font(UIFont.ksr_body(size: 13)))
      .lineLimit(nil)
      .padding([.leading, .trailing], self.contentPadding)
      .foregroundColor(textColor)
  }
}
