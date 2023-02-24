import Library
import SwiftUI

/*
 View modifiers are light weight packages of several individual attributes applied to a view. They come in handy when you want to reuse the same set of modifiers repeatedly with different input paramters.

 Let's keep this file just for text field modifiers. As you can see there are several applications of the same modifier to different input field parameters (functions below).
 */

@available(iOS 15.0, *)
struct TextInputFieldModifier: ViewModifier {
  let keyboardType: UIKeyboardType
  let textColor: Color
  let submitLabel: SubmitLabel
  let editable: Bool
  let titleText: String

  func body(content: Content) -> some View {
    content
      .frame(
        maxWidth: .infinity,
        alignment: .trailing
      )
      .keyboardType(self.keyboardType)
      .font(Font(UIFont.ksr_body()))
      .foregroundColor(self.textColor)
      .lineLimit(1)
      .multilineTextAlignment(.trailing)
      .submitLabel(self.submitLabel)
      .disabled(!self.editable)
      .accessibilityElement()
      .accessibilityLabel(self.titleText)
  }
}

@available(iOS 15.0, *)
extension View {
  func currentEmail(keyboardType: UIKeyboardType = .default,
                    textColor: Color = Color(.ksr_support_700),
                    submitLabel: SubmitLabel = .return,
                    editable: Bool = false,
                    titleText: String = Strings.Current_email()) -> some View {
    modifier(TextInputFieldModifier(
      keyboardType: keyboardType,
      textColor: textColor,
      submitLabel: submitLabel,
      editable: editable,
      titleText: titleText
    ))
  }

  func newEmail(keyboardType: UIKeyboardType = .emailAddress,
                textColor: Color = Color(.ksr_support_400),
                submitLabel: SubmitLabel = .next,
                editable: Bool = true,
                titleText: String = Strings.New_email()) -> some View {
    modifier(TextInputFieldModifier(
      keyboardType: keyboardType,
      textColor: textColor,
      submitLabel: submitLabel,
      editable: editable,
      titleText: titleText
    ))
  }

  func currentPassword(keyboardType: UIKeyboardType = .default,
                       textColor: Color = Color(.ksr_support_400),
                       submitLabel: SubmitLabel = .done,
                       editable: Bool = true,
                       titleText: String = Strings.Current_password()) -> some View {
    modifier(TextInputFieldModifier(
      keyboardType: keyboardType,
      textColor: textColor,
      submitLabel: submitLabel,
      editable: editable,
      titleText: titleText
    ))
  }
}
