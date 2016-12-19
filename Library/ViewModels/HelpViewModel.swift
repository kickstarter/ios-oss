#if os(iOS)
import Prelude
import ReactiveSwift
import Result
import MessageUI

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
  /// Call when Cancel button is tapped on the help sheet.
  func cancelHelpSheetButtonTapped()

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
  var showNoEmailError: Signal<UIAlertController, NoError> { get }

  /// Emits when to show the help actionsheet.
  var showHelpSheet: Signal<[HelpType], NoError> { get }

  /// Emits when to show a MFMailComposeViewController to contact support.
  var showMailCompose: Signal<(), NoError> { get }

  /// Emits when to show a WebViewController with a HelpType.
  var showWebHelp: Signal<HelpType, NoError> { get }
}

public protocol HelpViewModelType {
  var inputs: HelpViewModelInputs { get }
  var outputs: HelpViewModelOutputs { get }
}

public final class HelpViewModel: HelpViewModelType, HelpViewModelInputs, HelpViewModelOutputs {
  // swiftlint:disable function_body_length
  public init() {
    let context = self.helpContextProperty.signal.skipNil()
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

    context
      .takeWhen(self.showHelpSheetButtonTappedProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackShowedHelpMenu(context: $0) }

    context
      .takeWhen(self.cancelHelpSheetButtonTappedProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackCanceledHelpMenu(context: $0) }

    context
      .takePairWhen(helpTypeTapped)
      .observeValues { AppEnvironment.current.koala.trackSelectedHelpOption(context: $0, type: $1) }

    context
      .takePairWhen(self.showMailCompose)
      .observeValues { context, _ in AppEnvironment.current.koala.trackOpenedContactEmail(context: context) }

    context
      .takePairWhen(self.mailComposeCompletionProperty.signal.skipNil())
      .filter { $1 == .sent }
      .observeValues { context, _ in AppEnvironment.current.koala.trackSentContactEmail(context: context) }

    context
      .takePairWhen(self.mailComposeCompletionProperty.signal.skipNil())
      .filter { $1 == .cancelled }
      .observeValues { context, _ in AppEnvironment.current.koala.trackCanceledContactEmail(context: context) }
  }
  // swiftlint:enable function_body_length

  public var inputs: HelpViewModelInputs { return self }
  public var outputs: HelpViewModelOutputs { return self }

  public let showNoEmailError: Signal<UIAlertController, NoError>
  public let showHelpSheet: Signal<[HelpType], NoError>
  public let showMailCompose: Signal<(), NoError>
  public let showWebHelp: Signal<HelpType, NoError>

  fileprivate let canSendEmailProperty = MutableProperty<Bool?>(nil)
  public func canSendEmail(_ canSend: Bool) {
    self.canSendEmailProperty.value = canSend
  }
  fileprivate let cancelHelpSheetButtonTappedProperty = MutableProperty()
  public func cancelHelpSheetButtonTapped() {
    self.cancelHelpSheetButtonTappedProperty.value = ()
  }
  fileprivate let helpContextProperty = MutableProperty<HelpContext?>(nil)
  public func configureWith(helpContext: HelpContext) {
    self.helpContextProperty.value = helpContext
  }
  fileprivate let showHelpSheetButtonTappedProperty = MutableProperty()
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
#endif
