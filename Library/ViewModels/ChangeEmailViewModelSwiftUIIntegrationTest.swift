import Combine
import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ChangeEmailViewModelInputsSwiftUIIntegrationTest {
  func resendVerificationEmailButtonTapped()
  func viewDidLoad()
  func updateEmail(newEmail: String, currentPassword: String)
  func didTapSaveButton()
  func testAsync()
}

public protocol ChangeEmailViewModelOutputsSwiftUIIntegrationTest {
  var didFailToSendVerificationEmail: Signal<String, Never> { get }
  var didSendVerificationEmail: Signal<Void, Never> { get }
  var emailText: Signal<String, Never> { get }
  var messageLabelViewHidden: Signal<Bool, Never> { get }
  var resendVerificationEmailViewIsHidden: Signal<Bool, Never> { get }
  var unverifiedEmailLabelHidden: Signal<Bool, Never> { get }
  var warningMessageLabelHidden: Signal<Bool, Never> { get }
  var verificationEmailButtonTitle: Signal<String, Never> { get }
}

public protocol ChangeEmailViewModelTypeSwiftUIIntegrationTest {
  var inputs: ChangeEmailViewModelInputsSwiftUIIntegrationTest { get }
  var outputs: ChangeEmailViewModelOutputsSwiftUIIntegrationTest { get }
}

public final class ChangeEmailViewModelSwiftUIIntegrationTest: ChangeEmailViewModelTypeSwiftUIIntegrationTest,
  ChangeEmailViewModelInputsSwiftUIIntegrationTest,
  ChangeEmailViewModelOutputsSwiftUIIntegrationTest, ObservableObject {
  private var cancellables = Set<AnyCancellable>()
  @Published public var hideVerifyView = false
  @Published public var verifyEmailButtonTitle = ""
  @Published public var hideMessageLabel = true
  @Published public var warningMessageWithAlert = ("", false)
  public var saveButtonEnabled: AnyPublisher<Bool, Never>
  public var bannerMessage: PassthroughSubject<MessageBannerViewViewModel, Never> = .init()
  public var retrievedEmailText: PassthroughSubject<String, Never> = .init()
  public var newEmailText: PassthroughSubject<String, Never> = .init()
  public var currentPasswordText: PassthroughSubject<String, Never> = .init()
  public var saveTriggered: PassthroughSubject<Bool, Never> = .init()
  public var resetEditableText: PassthroughSubject<Bool, Never> = .init()
  public var testAsyncPublisher: PassthroughSubject<Bool, Never> = .init()

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
    let emailVerifiedAndDeliverable: Signal<Bool, Never> = Signal
      .combineLatest(isEmailVerified, isEmailDeliverable)
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
      .CombineLatest3(self.retrievedEmailText, self.newEmailText, self.currentPasswordText)
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

        self?.saveTriggered.send(false)
        self?.resetEditableText.send(true)
        self?.bannerMessage.send(messageBannerViewViewModel)
      }

    _ = changeEmailEvent.values().ignoreValues()
      .observeForUI()
      .observeValues { [weak self] _ in
        let messageBannerViewViewModel = MessageBannerViewViewModel((
          type: .success,
          message: Strings.Got_it_your_changes_have_been_saved()
        ))

        self?.saveTriggered.send(false)
        self?.resetEditableText.send(true)
        self?.bannerMessage.send(messageBannerViewViewModel)
      }

    Publishers
      .CombineLatest4(self.saveButtonEnabled, self.saveTriggered, self.newEmailText, self.currentPasswordText)
      .filter { enabledValue, triggeredValue, _, _ in
        enabledValue && triggeredValue
      }
      .sink(receiveValue: { [weak self] _, _, newEmailTextValue, newPasswordTextValue in
        self?.updateEmail(newEmail: newEmailTextValue, currentPassword: newPasswordTextValue)
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

        self?.bannerMessage.send(messageBannerViewViewModel)
      }

    _ = self.didFailToSendVerificationEmail
      .observeForUI()
      .observeValues { [weak self] message in
        let messageBannerViewViewModel = MessageBannerViewViewModel((
          type: .error,
          message: message
        ))

        self?.bannerMessage.send(messageBannerViewViewModel)
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

    // GraphQL test
//    let refreshAsync = self.testAsyncProperty.signal
//      .switchMap { _ in
//        AppEnvironment.current
//          .apiService
//          .fetchGraphUser(withStoredCards: false)
//          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
//          .materialize()
//      }
//      .values()
//
//    _ = refreshAsync
//      .observeForUI()
//      .observeValues({ [weak self] user in
//        self?.testAsyncPublisher.send(true)
//      })

    // v1 test
    let refreshAsync = self.testAsyncProperty.signal
      .switchMap { _ in
        AppEnvironment.current
          .apiService
          .fetchFriendStats()
          .ksr_delay(.seconds(1), on: AppEnvironment.current.scheduler) // See refresh
          .materialize()
      }
      .values()

    _ = refreshAsync
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.testAsyncPublisher.send(true)
      }
  }

  private let updateEmailAndPasswordProperty = MutableProperty<(String, String)?>(nil)
  public func updateEmail(newEmail: String, currentPassword: String) {
    self.updateEmailAndPasswordProperty.value = (newEmail, currentPassword)
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

  public func didTapSaveButton() {
    self.saveTriggered.send(true)
  }

  private let testAsyncProperty = MutableProperty(())
  public func testAsync() {
    self.testAsyncProperty.value = ()
  }

  public let didFailToSendVerificationEmail: Signal<String, Never>
  public let didSendVerificationEmail: Signal<Void, Never>
  public let emailText: Signal<String, Never>
  public let messageLabelViewHidden: Signal<Bool, Never>
  public let resendVerificationEmailViewIsHidden: Signal<Bool, Never>
  public let unverifiedEmailLabelHidden: Signal<Bool, Never>
  public let verificationEmailButtonTitle: Signal<String, Never>
  public let warningMessageLabelHidden: Signal<Bool, Never>

  public var inputs: ChangeEmailViewModelInputsSwiftUIIntegrationTest {
    return self
  }

  public var outputs: ChangeEmailViewModelOutputsSwiftUIIntegrationTest {
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
