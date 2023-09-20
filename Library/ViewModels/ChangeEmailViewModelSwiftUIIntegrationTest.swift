import Combine
import KsApi
import Prelude
import UIKit

public final class ChangeEmailViewModelSwiftUIIntegrationTest: ObservableObject {
  private var cancellables = Set<AnyCancellable>()

  /// Outputs (going out to the view) - cannot yet fully grasp the difference between receiving a `PassthroughSubject` or `Publisher` on the view side.
  @Published public var hideVerifyView = true
  @Published public var verifyEmailButtonTitle = ""
  @Published public var hideMessageLabel = true
  @Published public var warningMessageWithAlert = ("", false)
  @Published public var networkConnectionAvailable = false
  public var resetEditableText: PassthroughSubject<Bool, Never> = .init()
  public var saveButtonEnabled: PassthroughSubject<Bool, Never> = .init()
  public var retrievedEmailText: PassthroughSubject<String, Never> = .init()
  public var bannerMessage: PassthroughSubject<MessageBannerViewViewModel, Never> = .init()

  /// Inputs (values passed in from view)
  public var saveTriggered: PassthroughSubject<Bool, Never> = .init()
  public var newEmailText: PassthroughSubject<String, Never> = .init()
  public var currentPasswordText: PassthroughSubject<String, Never> = .init()

  /// Internal (only updated in view model) - not input or output
  private var viewDidLoadProperty: PassthroughSubject<Void, Never> = .init()
  private var updateEmailAndPasswordProperty: PassthroughSubject<(String, String), Never> = .init()
  private var resendVerificationEmailButtonProperty: PassthroughSubject<Void, Never> = .init()

  public init() {
    // MARK: Passthroughsubject sinks.

    self.viewDidLoadProperty
      .flatMap { _ in
        AppEnvironment.current.apiService
          // FIXME: Ideally we're going to use - `AppEnvironment.current.apiDelayInterval` but that needs a refactoring out of `DispatchTimeInterval` to `TimeIntveral`
          .fetchGraphUser(withStoredCards: false)
          .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
          .receive(on: DispatchQueue.global())
      }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case .finished:
          break
        case let .failure(errorValue):
          let messageBannerViewViewModel = MessageBannerViewViewModel((
            type: .error,
            message: errorValue.localizedDescription
          ))

          self?.bannerMessage.send(messageBannerViewViewModel)
          self?.hideVerifyView = true
        }
      }, receiveValue: { [weak self] envelope in
        let isEmailVerified = envelope.me.isEmailVerified ?? false
        let isDeliverable = envelope.me.isDeliverable ?? false

        /// Hide show email verification message (alongside resend email button)
        switch (isEmailVerified, isDeliverable) {
        case (true, true):
          self?.hideVerifyView = true
          self?.hideMessageLabel = true
          self?.warningMessageWithAlert = (Strings.We_ve_been_unable_to_send_email(), true)
        case (true, false):
          self?.hideVerifyView = false
          self?.hideMessageLabel = false
          self?.warningMessageWithAlert = (Strings.We_ve_been_unable_to_send_email(), true)
        case (false, _):
          self?.hideVerifyView = false
          self?.hideMessageLabel = false
          self?.warningMessageWithAlert = (Strings.Email_unverified(), false)
        }

        guard let user = AppEnvironment.current.currentUser else {
          self?.verifyEmailButtonTitle = ""

          return
        }

        let verificationEmailButtonText = user.isCreator ? Strings.Resend_verification_email() : Strings
          .Send_verfication_email()

        self?.verifyEmailButtonTitle = verificationEmailButtonText

        /// Display current users' email under "Current Email"
        self?.retrievedEmailText.send(envelope.me.email ?? "")
      })
      .store(in: &self.cancellables)

    self.updateEmailAndPasswordProperty
      .map(ChangeEmailInput.init(email: currentPassword:))
      .flatMap { input in
        AppEnvironment.current.apiService.changeEmail(input: input)
          .map { _ in input.email }
          // FIXME: Ideally we're going to use - `AppEnvironment.current.apiDelayInterval` but that needs a refactoring out of `DispatchTimeInterval` to `TimeIntveral`
          .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
          .receive(on: DispatchQueue.global())
          .eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completed in
        switch completed {
        case .finished:
          break
        case let .failure(errorValue):
          let messageBannerViewViewModel = MessageBannerViewViewModel((
            type: .error,
            message: errorValue.localizedDescription
          ))

          self?.saveTriggered.send(false)
          self?.resetEditableText.send(true)
          self?.bannerMessage.send(messageBannerViewViewModel)
        }
      }, receiveValue: { [weak self] text in
        let messageBannerViewViewModel = MessageBannerViewViewModel((
          type: .success,
          message: Strings.Got_it_your_changes_have_been_saved()
        ))

        self?.saveTriggered.send(false)
        self?.resetEditableText.send(true)
        self?.bannerMessage.send(messageBannerViewViewModel)
        self?.retrievedEmailText.send(text)
      })
      .store(in: &self.cancellables)

    self.resendVerificationEmailButtonProperty
      .flatMap { _ in
        AppEnvironment.current.apiService.sendVerificationEmail(input: EmptyInput())
      }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case .finished:
          break
        case let .failure(error):
          let messageBannerViewViewModel = MessageBannerViewViewModel((
            type: .error,
            message: error.localizedDescription
          ))

          self?.bannerMessage.send(messageBannerViewViewModel)
        }
      }, receiveValue: { [weak self] _ in
        let messageBannerViewViewModel = MessageBannerViewViewModel((
          type: .success,
          message: Strings.Verification_email_sent()
        ))

        self?.bannerMessage.send(messageBannerViewViewModel)
      })
      .store(in: &self.cancellables)

    // MARK: Higher order sinks

    Reachability.reachabilityPublisher
      .receive(on: DispatchQueue.global())
      .sink(receiveValue: { [weak self] status in
        switch status {
        case .wifi, .wwan:
          self?.networkConnectionAvailable = true
        case .none:
          self?.networkConnectionAvailable = false
        }
      })
      .store(in: &self.cancellables)

    Publishers.CombineLatest3(self.retrievedEmailText, self.newEmailText, self.currentPasswordText)
      .eraseToAnyPublisher()
      .removeDuplicates(by: ==)
      .map(shouldEnableSaveButton(email:newEmail:password:))
      .sink { [weak self] flag in
        self?.saveButtonEnabled.send(flag)
      }
      .store(in: &self.cancellables)

    Publishers
      .CombineLatest4(
        self.saveButtonEnabled,
        self.saveTriggered,
        self.newEmailText,
        self.currentPasswordText
      )
      .filter { enabledValue, triggeredValue, _, _ in
        enabledValue && triggeredValue
      }
      .sink(receiveValue: { [weak self] _, _, newEmailTextValue, newPasswordTextValue in
        self?.updateEmail(newEmail: newEmailTextValue, currentPassword: newPasswordTextValue)
      })
      .store(in: &self.cancellables)
  }

  /// Input functions
  private func updateEmail(newEmail: String, currentPassword: String) {
    let emailAndPassword = (newEmail, currentPassword)

    self.updateEmailAndPasswordProperty.send(emailAndPassword)
  }

  public func resendVerificationEmailButtonTapped() {
    self.resendVerificationEmailButtonProperty.send(())
  }

  public func viewDidLoad() {
    self.viewDidLoadProperty.send(())
  }
}

/// Helper functions
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
