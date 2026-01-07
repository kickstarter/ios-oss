import Combine
import Foundation
import KsApi
import Library

protocol PPOProjectCardViewModelInputs {
  func eventTriggered(_: PPOProjectCardModel.CardEvent)
}

protocol PPOProjectCardViewModelOutputs {
  var handleEvent: AnyPublisher<PPOProjectCardModel.CardEvent, Never> { get }

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

  func eventTriggered(_ event: PPOProjectCardModel.CardEvent) {
    self.handleEventSubject.send(event)
  }

  // MARK: - Outputs

  var handleEvent: AnyPublisher<PPOProjectCardModel.CardEvent, Never> {
    self.handleEventSubject.eraseToAnyPublisher()
  }

  private let handleEventSubject = PassthroughSubject<PPOProjectCardModel.CardEvent, Never>()

  // MARK: - Helpers

  typealias ButtonAction = PPOProjectCardModel.ButtonAction
  typealias Alert = PPOProjectCardModel.Alert

  // MARK: - Equatable

  static func == (lhs: PPOProjectCardViewModel, rhs: PPOProjectCardViewModel) -> Bool {
    lhs.card == rhs.card
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
