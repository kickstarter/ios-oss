import Combine
import ReactiveSwift
import SwiftUI

public final class ChangeEmailViewViewModel: ObservableObject {
  // MARK: Inputs

  @Published public var savedButtonIsEnabled = false
  public func newEmailTextDidChange(_ value: String) {
    self.newEmailText.send(value)
  }

  public func newPasswordTextDidChange(_ value: String) {
    self.newPasswordText.send(value)
  }

  // MARK: Outputs

  public var emailText: CurrentValueSubject<String, Never> = .init("sample@gmail.com")
  public var newEmailText: CurrentValueSubject<String, Never> = .init("")
  public var newPasswordText: CurrentValueSubject<String, Never> = .init("")

  /// Assign publishers here to maintain the life of the event stream after initialization.
  private var cancellables = Set<AnyCancellable>()

  public init() {
    // FIXME: Make a network call to update `emailText` from `fetchGraphUser`

    Publishers.CombineLatest3(self.emailText, self.newEmailText, self.newPasswordText)
      .removeDuplicates(by: ==)
      .map(self.shouldEnableSaveButton(email:newEmail:password:))
      .sink(receiveValue: { [weak self] flag in
        print("*** \(flag)")
        self?.savedButtonIsEnabled = flag
      })
      .store(in: &self.cancellables)
  }

  // MARK: Helpers

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
}
