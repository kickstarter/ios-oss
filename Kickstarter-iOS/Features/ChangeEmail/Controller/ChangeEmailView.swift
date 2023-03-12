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
      message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Elit ut aliquam purus sit amet luctus venenatis. Id porta nibh venenatis cras sed felis eget. Dui sapien eget mi proin sed libero enim sed faucibus. Aliquam purus sit amet luctus. Non consectetur a erat nam at. Scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique senectus. Pellentesque adipiscing commodo elit at. Tortor posuere ac ut consequat semper viverra nam libero justo. Rutrum quisque non tellus orci. Dui id ornare arcu odio ut sem nulla pharetra. Integer feugiat scelerisque varius morbi enim nunc faucibus. At lectus urna duis convallis convallis tellus id interdum velit. Dignissim sodales ut eu sem integer vitae justo eget. Ut pharetra sit amet aliquam id diam. Fames ac turpis egestas maecenas pharetra convallis posuere. Duis ultricies lacus sed turpis tincidunt id aliquet risus feugiat.Ullamcorper dignissim cras tincidunt lobortis feugiat vivamus at augue eget. Ridiculus mus mauris vitae ultricies. Nunc faucibus a pellentesque sit amet porttitor eget dolor. Nam aliquam sem et tortor consequat id porta. Tellus id interdum velit laoreet id donec ultrices tincidunt. Netus et malesuada fames ac turpis. Velit sed ullamcorper morbi tincidunt ornare massa eget egestas. At ultrices mi tempus imperdiet nulla malesuada pellentesque elit. Sodales neque sodales ut etiam. Cursus sit amet dictum sit amet justo donec enim. Nec tincidunt praesent semper feugiat nibh sed pulvinar proin. Elit at imperdiet dui accumsan. Et sollicitudin ac orci phasellus. Habitasse platea dictumst vestibulum rhoncus. Ac turpis egestas maecenas pharetra convallis posuere morbi. Consectetur libero id faucibus nisl tincidunt eget. Sit amet facilisis magna etiam tempor orci eu. Adipiscing bibendum est ultricies integer quis auctor elit sed vulputate. Cras fermentum odio eu feugiat pretium. Tincidunt nunc pulvinar sapien et ligula ullamcorper. Sagittis vitae et leo duis ut. Vel eros donec ac odio. Nisi vitae suscipit tellus mauris a diam maecenas sed enim. Volutpat consequat mauris nunc congue. Libero nunc consequat interdum varius sit. Aliquam eleifend mi in nulla posuere sollicitudin aliquam ultrices sagittis. Auctor urna nunc id cursus metus aliquam eleifend mi. Tellus id interdum velit laoreet id donec ultrices. Magna etiam tempor orci eu lobortis elementum nibh. Aenean euismod elementum nisi quis eleifend quam adipiscing vitae. Posuere lorem ipsum dolor sit amet consectetur. Turpis cursus in hac habitasse platea dictumst quisque. Eu augue ut lectus arcu. Nulla aliquet enim tortor at auctor. Congue quisque egestas diam in arcu cursus euismod quis. Aliquam eleifend mi in nulla posuere sollicitudin aliquam ultrices sagittis. Etiam tempor orci eu lobortis. Tincidunt praesent semper feugiat nibh sed. Senectus et netus et malesuada fames. Nunc vel risus commodo viverra. Viverra accumsan in nisl nisi scelerisque eu ultrices vitae auctor. Eu sem integer vitae justo eget magna. Rhoncus urna neque viverra justo nec ultrices dui sapien. Turpis in eu mi bibendum neque egestas. Mattis aliquam faucibus purus in massa tempor nec feugiat nisl. Aliquet porttitor lacus luctus accumsan. Natoque penatibus et magnis dis parturient montes nascetur. Risus sed vulputate odio ut enim. Magnis dis parturient montes nascetur ridiculus mus mauris vitae ultricies. Volutpat diam ut venenatis tellus in metus. Non diam phasellus vestibulum lorem sed. Et ultrices neque ornare aenean euismod elementum. At in tellus integer feugiat scelerisque varius morbi enim nunc. Aliquam sem fringilla ut morbi tincidunt."
    ))

  init(emailText: String) {
    self.emailText = emailText
  }

  // FIXME: Background colour is not correct when landscape on larger iPhones (13 Pro Max) because it shows the non-safe area color as white.
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
              print("Button tapped \(resendVerificationEmailButtonTitle)")
              showBanner.toggle()
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
        if showBanner {
          MessageBannerView(viewModel: messageBannerViewViewModel)
            .frame(
              minWidth: proxy.size.width,
              idealWidth: proxy.size.width,
              maxHeight: proxy.size.height / 4,
              alignment: .bottom
            )
        }
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

/** Currently not working - pauses
 struct CircleImage_Previews: PreviewProvider {
 static var previews: some View {
 if #available(iOS 15, *) {
 ChangeEmailView(emailText: "sample@email.com")
 }
 }
 }
 */
