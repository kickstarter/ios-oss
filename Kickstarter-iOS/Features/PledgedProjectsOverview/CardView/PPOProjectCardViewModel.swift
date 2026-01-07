import Combine
import Foundation
import KsApi
import Library

protocol PPOProjectCardViewModelInputs {
  func viewBackingDetails()
  func sendCreatorMessage()
  func editAddress()
  func performAction(action: PPOProjectCardModel.ButtonAction)
}

protocol PPOProjectCardViewModelOutputs {
  var viewBackingDetailsTapped: AnyPublisher<Void, Never> { get }
  var sendMessageTapped: AnyPublisher<Void, Never> { get }
  var editAddressTapped: AnyPublisher<Void, Never> { get }
  var actionPerformed: AnyPublisher<PPOProjectCardModel.ButtonAction, Never> { get }

  var card: PPOProjectCardModel { get }
}

extension PPOProjectCardViewModelOutputs {
  // Action details related to the action, if any.
  var actionDetails: String? {
    switch self.card.action {
    case .managePledge:
      return Strings.This_may_involve_submitting_a_delivery_address()
    default:
      return nil
    }
  }
}

typealias PPOProjectCardViewModelType = Equatable & Hashable & Identifiable & ObservableObject &
  PPOProjectCardViewModelInputs &
  PPOProjectCardViewModelOutputs

final class PPOProjectCardViewModel: PPOProjectCardViewModelType {
  @Published private(set) var card: PPOProjectCardModel
  @Published var buttonState: PPOButtonState = .active

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.card)
  }

  init(
    card: PPOProjectCardModel
  ) {
    self.card = card
  }

  // MARK: - Inputs

  func editAddress() {
    self.editAddressSubject.send()
  }

  func sendCreatorMessage() {
    self.sendCreatorMessageSubject.send()
  }

  func performAction(action: ButtonAction) {
    self.actionPerformedSubject.send(action)
  }

  func viewBackingDetails() {
    self.viewBackingDetailsSubject.send()
  }

  // MARK: - Outputs

  var viewBackingDetailsTapped: AnyPublisher<(), Never> {
    self.viewBackingDetailsSubject.eraseToAnyPublisher()
  }

  var sendMessageTapped: AnyPublisher<(), Never> { self.sendCreatorMessageSubject.eraseToAnyPublisher() }
  var editAddressTapped: AnyPublisher<(), Never> { self.editAddressSubject.eraseToAnyPublisher() }
  var actionPerformed: AnyPublisher<ButtonAction, Never> { self.actionPerformedSubject.eraseToAnyPublisher() }

  private let viewBackingDetailsSubject = PassthroughSubject<Void, Never>()
  private let sendCreatorMessageSubject = PassthroughSubject<Void, Never>()
  private let editAddressSubject = PassthroughSubject<Void, Never>()
  private let actionPerformedSubject = PassthroughSubject<PPOProjectCardModel.ButtonAction, Never>()

  // MARK: - Helpers

  typealias ButtonAction = PPOProjectCardModel.ButtonAction
  typealias Alert = PPOProjectCardModel.Alert

  // MARK: - Equatable

  static func == (lhs: PPOProjectCardViewModel, rhs: PPOProjectCardViewModel) -> Bool {
    lhs.card == rhs.card
  }

  func fix3DSChallenge(clientSecret: String) {
    self.performAction(action: .authenticateCard(clientSecret: clientSecret))
  }

  func handle3DSState(_ state: PPOActionState) {
    switch state {
    case .processing, .confirmed:
      self.buttonState = .loading
    case .succeeded:
      self.buttonState = .disabled
    case .cancelled, .failed:
      self.buttonState = .active
    }
  }
}

public enum PPOActionState {
  case processing
  case confirmed
  case succeeded
  case cancelled
  case failed
}

enum PPOButtonState {
  case active
  case loading
  case disabled
}
