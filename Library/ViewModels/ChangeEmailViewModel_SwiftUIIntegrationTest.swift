import Combine
import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ChangeEmailViewModelInputs_SwiftUIIntegrationTest {
  func resendVerificationEmailButtonTapped()
  func viewDidLoad()
  func updateEmail(newEmail: String, newPassword: String)
}

public protocol ChangeEmailViewModelOutputs_SwiftUIIntegrationTest {
  var didFailToSendVerificationEmail: Signal<String, Never> { get }
  var didSendVerificationEmail: Signal<Void, Never> { get }
  var emailText: Signal<String, Never> { get }
  var messageLabelViewHidden: Signal<Bool, Never> { get }
  var resendVerificationEmailViewIsHidden: Signal<Bool, Never> { get }
  var unverifiedEmailLabelHidden: Signal<Bool, Never> { get }
  var warningMessageLabelHidden: Signal<Bool, Never> { get }
  var verificationEmailButtonTitle: Signal<String, Never> { get }
}

public protocol ChangeEmailViewModelType_SwiftUIIntegrationTest {
  var inputs: ChangeEmailViewModelInputs_SwiftUIIntegrationTest { get }
  var outputs: ChangeEmailViewModelOutputs_SwiftUIIntegrationTest { get }
}

public final class ChangeEmailViewModel_SwiftUIIntegrationTest: ChangeEmailViewModelType_SwiftUIIntegrationTest,
  ChangeEmailViewModelInputs_SwiftUIIntegrationTest,
  ChangeEmailViewModelOutputs_SwiftUIIntegrationTest, ObservableObject {
  private var cancellables = Set<AnyCancellable>()
  @Published public var hideVerifyView = false
  @Published public var showBanner: (Bool, MessageBannerViewViewModel?) = (false, nil)
  @Published public var verifyEmailButtonTitle = ""
  @Published public var hideMessageLabel = true
  @Published public var warningMessageWithAlert = ("", false)
  public var saveButtonEnabled: AnyPublisher<Bool, Never>
  public var retrievedEmailText: CurrentValueSubject<String, Never> = .init("")
  public var newEmailText: PassthroughSubject<String, Never> = .init()
  public var newPasswordText: PassthroughSubject<String, Never> = .init()
  public var saveTriggered: PassthroughSubject<Bool, Never> = .init()

  public init() {
    let changeEmailEvent = self.updateEmailAndPasswordProperty.signal.skipNil()
      .map(ChangeEmailInput.init(email:currentPassword:))
      .switchMap { input in
        AppEnvironment.current.apiService.changeEmail(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { _ in input.email }
          .materialize()
      }

    let userEmailEvent = self.viewDidLoadProperty.signal
      .switchMap { _ in
        AppEnvironment.current
          .apiService
          .fetchGraphUser(withStoredCards: false)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let resendEmailVerificationEvent = self.resendVerificationEmailButtonProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.sendVerificationEmail(input: EmptyInput())
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.didSendVerificationEmail = resendEmailVerificationEvent.values().ignoreValues()

    self.didFailToSendVerificationEmail = resendEmailVerificationEvent.errors()
      .map { $0.localizedDescription }

    self.emailText = Signal.merge(
      changeEmailEvent.values(),
      userEmailEvent.values().map { $0.me.email ?? "" }
    )

    let isEmailVerified = userEmailEvent.values().map { $0.me.isEmailVerified }.skipNil()
    let isEmailDeliverable = userEmailEvent.values().map { $0.me.isDeliverable }.skipNil()
    let emailVerifiedAndDeliverable = Signal.combineLatest(isEmailVerified, isEmailDeliverable)
      .map { isEmailVerified, isEmailDeliverable -> Bool in
        let r = isEmailVerified && isEmailDeliverable
        return r
      }

    self.resendVerificationEmailViewIsHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      emailVerifiedAndDeliverable
    ).skipRepeats()

    self.unverifiedEmailLabelHidden = Signal
      .combineLatest(isEmailVerified, isEmailDeliverable)
      .map { isEmailVerified, isEmailDeliverable -> Bool in
        guard isEmailVerified else { return !isEmailDeliverable }

        return true
      }

    self.warningMessageLabelHidden = isEmailDeliverable

    self.messageLabelViewHidden = Signal
      .merge(self.unverifiedEmailLabelHidden, self.warningMessageLabelHidden)
      .filter(isFalse)

    self.verificationEmailButtonTitle = self.viewDidLoadProperty.signal.map { _ in
      guard let user = AppEnvironment.current.currentUser else { return "" }
      return user.isCreator ? Strings.Resend_verification_email() : Strings.Send_verfication_email()
    }

    // MARK: Reactive Subscribers to Combine Publishers

    self.saveButtonEnabled = Publishers
      .CombineLatest3(self.retrievedEmailText, self.newEmailText, self.newPasswordText)
      .removeDuplicates(by: ==)
      .map(shouldEnableSaveButton(email:newEmail:password:))
      .eraseToAnyPublisher()

    _ = changeEmailEvent.errors()
      .observeForUI()
      .observeValues { [weak self] errorValue in
        let messageBannerViewViewModel = MessageBannerViewViewModel((
          type: .error,
          message: errorValue.localizedDescription
        ))

        self?.showBanner = (true, messageBannerViewViewModel)
      }

    _ = changeEmailEvent.values().ignoreValues()
      .observeForUI()
      .observeValues { [weak self] _ in
        let messageBannerViewViewModel = MessageBannerViewViewModel((
          type: .success,
          message: Strings.Verification_email_sent()
        ))

        self?.showBanner = (true, messageBannerViewViewModel)
      }

    Publishers.CombineLatest3(self.saveTriggered, self.newEmailText, self.newPasswordText)
      .filter { $0.0 }
      .sink(receiveValue: { [weak self] _, newEmailTextValue, newPasswordTextValue in
        self?.updateEmail(newEmail: newEmailTextValue, newPassword: newPasswordTextValue)
      })
      .store(in: &self.cancellables)

    _ = self.resendVerificationEmailViewIsHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.hideVerifyView = isHidden
      }

    _ = self.didSendVerificationEmail
      .observeForUI()
      .observeValues { [weak self] in
        let messageBannerViewViewModel = MessageBannerViewViewModel((
          type: .success,
          message: Strings.Verification_email_sent()
        ))

        self?.showBanner = (true, messageBannerViewViewModel)
      }

    _ = self.didFailToSendVerificationEmail
      .observeForUI()
      .observeValues { [weak self] message in
        let messageBannerViewViewModel = MessageBannerViewViewModel((
          type: .error,
          message: message
        ))

        self?.showBanner = (true, messageBannerViewViewModel)
      }

    _ = self.emailText
      .observeForUI()
      .observeValues { [weak self] emailText in
        self?.retrievedEmailText.send(emailText)
      }

    _ = self.verificationEmailButtonTitle
      .observeForUI()
      .observeValues { [weak self] titleText in
        self?.verifyEmailButtonTitle = titleText
      }

    _ = self.messageLabelViewHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.hideMessageLabel = isHidden
      }

    _ = self.unverifiedEmailLabelHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        guard !isHidden else { return }

        self?.warningMessageWithAlert = (Strings.Email_unverified(), false)
      }

    _ = self.warningMessageLabelHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        guard !isHidden else { return }

        self?.warningMessageWithAlert = (Strings.We_ve_been_unable_to_send_email(), true)
      }
  }

  private let updateEmailAndPasswordProperty = MutableProperty<(String, String)?>(nil)
  public func updateEmail(newEmail: String, newPassword: String) {
    self.updateEmailAndPasswordProperty.value = (newEmail, newPassword)
  }

  private let newEmailProperty = MutableProperty<String?>(nil)
  public func emailFieldTextDidChange(text: String?) {
    self.newEmailProperty.value = text
  }

  private let passwordProperty = MutableProperty<String?>(nil)
  public func passwordFieldTextDidChange(text: String?) {
    self.passwordProperty.value = text
  }

  private let resendVerificationEmailButtonProperty = MutableProperty(())
  public func resendVerificationEmailButtonTapped() {
    self.resendVerificationEmailButtonProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let didFailToSendVerificationEmail: Signal<String, Never>
  public let didSendVerificationEmail: Signal<Void, Never>
  public let emailText: Signal<String, Never>
  public let messageLabelViewHidden: Signal<Bool, Never>
  public let resendVerificationEmailViewIsHidden: Signal<Bool, Never>
  public let unverifiedEmailLabelHidden: Signal<Bool, Never>
  public let verificationEmailButtonTitle: Signal<String, Never>
  public let warningMessageLabelHidden: Signal<Bool, Never>

  public var inputs: ChangeEmailViewModelInputs_SwiftUIIntegrationTest {
    return self
  }

  public var outputs: ChangeEmailViewModelOutputs_SwiftUIIntegrationTest {
    return self
  }
}

private func shouldEnableSaveButton(email: String?, newEmail: String?, password: String?) -> Bool {
  guard
    let newEmail = newEmail,
    isValidEmail(newEmail),
    email != newEmail,
    password != nil

  else { return false }

  return ![newEmail, password]
    .compact()
    .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    .contains(false)
}
