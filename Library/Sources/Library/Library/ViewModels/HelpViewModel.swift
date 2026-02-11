import MessageUI
import Prelude
import ReactiveSwift

public enum HelpContext {
  case loginTout
  case facebookConfirmation
  case settings
  case signup

  public var trackingString: String {
    switch self {
    case .loginTout:
      return "Login Tout"
    case .facebookConfirmation:
      return "Facebook Confirmation"
    case .settings:
      return "Settings"
    case .signup:
      return "Signup"
    }
  }
}

public protocol HelpViewModelInputs {
  /// Call to set whether Mail can be composed.
  func canSendEmail(_ canSend: Bool)

  /// Call to configure with HelpContext.
  func configureWith(helpContext: HelpContext)

  /// Call when a help button is tapped.
  func helpTypeButtonTapped(_ helpType: HelpType)

  /// Call when mail compose view controller has closed with a result.
  func mailComposeCompletion(result: MFMailComposeResult)

  /// Call when to show the help sheet from a button tap.
  func showHelpSheetButtonTapped()
}

public protocol HelpViewModelOutputs {
  /// Emits to show an alert when Mail is not available.
  var showNoEmailError: Signal<UIAlertController, Never> { get }

  /// Emits when to show the help actionsheet.
  var showHelpSheet: Signal<[HelpType], Never> { get }

  /// Emits when to show a MFMailComposeViewController to contact support.
  var showMailCompose: Signal<(), Never> { get }

  /// Emits when to show a WebViewController with a HelpType.
  var showWebHelp: Signal<HelpType, Never> { get }
}

public protocol HelpViewModelType {
  var inputs: HelpViewModelInputs { get }
  var outputs: HelpViewModelOutputs { get }
}

public final class HelpViewModel: HelpViewModelType, HelpViewModelInputs, HelpViewModelOutputs {
  public init() {
    let canSendEmail = self.canSendEmailProperty.signal.skipNil()
    let helpTypeTapped = self.helpTypeButtonTappedProperty.signal.skipNil()

    self.showMailCompose = canSendEmail
      .takePairWhen(helpTypeTapped)
      .filter { canSend, type in type == .contact && canSend }
      .ignoreValues()

    self.showNoEmailError = canSendEmail
      .takePairWhen(helpTypeTapped)
      .filter { canSend, type in type == .contact && !canSend }
      .map { _ in noEmailError() }

    self.showWebHelp = helpTypeTapped
      .filter { $0 != .contact }

    self.showHelpSheet = self.showHelpSheetButtonTappedProperty.signal
      .mapConst([HelpType.howItWorks, .contact, .terms, .privacy, .cookie])
  }

  public var inputs: HelpViewModelInputs { return self }
  public var outputs: HelpViewModelOutputs { return self }

  public let showNoEmailError: Signal<UIAlertController, Never>
  public let showHelpSheet: Signal<[HelpType], Never>
  public let showMailCompose: Signal<(), Never>
  public let showWebHelp: Signal<HelpType, Never>

  fileprivate let canSendEmailProperty = MutableProperty<Bool?>(nil)
  public func canSendEmail(_ canSend: Bool) {
    self.canSendEmailProperty.value = canSend
  }

  fileprivate let helpContextProperty = MutableProperty<HelpContext?>(nil)
  public func configureWith(helpContext: HelpContext) {
    self.helpContextProperty.value = helpContext
  }

  fileprivate let showHelpSheetButtonTappedProperty = MutableProperty(())
  public func showHelpSheetButtonTapped() {
    self.showHelpSheetButtonTappedProperty.value = ()
  }

  fileprivate let helpTypeButtonTappedProperty = MutableProperty<HelpType?>(nil)
  public func helpTypeButtonTapped(_ helpType: HelpType) {
    self.helpTypeButtonTappedProperty.value = helpType
  }

  fileprivate let mailComposeCompletionProperty = MutableProperty<MFMailComposeResult?>(nil)
  public func mailComposeCompletion(result: MFMailComposeResult) {
    self.mailComposeCompletionProperty.value = result
  }
}

private func noEmailError() -> UIAlertController {
  let alertController = UIAlertController(
    title: Strings.support_email_noemail_title(),
    message: Strings.support_email_noemail_message(),
    preferredStyle: .alert
  )
  alertController.addAction(
    UIAlertAction(
      title: Strings.general_alert_buttons_ok(),
      style: .cancel,
      handler: nil
    )
  )

  return alertController
}
