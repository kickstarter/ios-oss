import Combine
import Foundation
import KsApi
import Library

protocol PPOProjectCardViewModelInputs {
  func performAction(action: PPOProjectCardModel.CardAction)
}

protocol PPOProjectCardViewModelOutputs {
  var actionPerformed: AnyPublisher<PPOProjectCardModel.CardAction, Never> { get }

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
  @Published var rewardToggleEnabled: Bool

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.card)
  }

  init(
    card: PPOProjectCardModel
  ) {
    self.card = card
    self.rewardToggleEnabled = card.rewardReceivedToggleState == .rewardReceived
  }

  // MARK: - Inputs

  func performAction(action: PPOProjectCardModel.CardAction) {
    self.actionPerformedSubject.send(action)
  }

  // MARK: - Outputs

  var actionPerformed: AnyPublisher<PPOProjectCardModel.CardAction, Never> {
    self.actionPerformedSubject.eraseToAnyPublisher()
  }

  private let actionPerformedSubject = PassthroughSubject<PPOProjectCardModel.CardAction, Never>()

  // MARK: - Helpers

  typealias Alert = PPOProjectCardModel.Alert

  // MARK: - Equatable

  static func == (lhs: PPOProjectCardViewModel, rhs: PPOProjectCardViewModel) -> Bool {
    lhs.card == rhs.card
  }

//  func fix3DSChallenge(clientSecret: String) {
//    self.performAction(action: .buttonAction(buttonAction: .authenticateCard(clientSecret: clientSecret)))
//  }

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
