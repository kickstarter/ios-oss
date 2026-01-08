import Combine
import Foundation
import KsApi
import Library

public enum PPOCardEvent: Equatable, Hashable {
  case editAddress
  case sendMessage
  case viewProjectDetails
  case confirmAddress(address: String, addressId: String)
  case completeSurvey
  case managePledge
  case fixPayment
  case authenticateCard(clientSecret: String)
}

protocol PPOProjectCardViewModelInputs {
  // Trigger a PPOCardEvent directly.
  func eventTriggered(_: PPOCardEvent)
  // Trigger the PPOCardEvent corresponding to the ButtonAction.
  func performAction(_: PPOProjectCardModel.ButtonAction)
}

protocol PPOProjectCardViewModelOutputs {
  var handleEvent: AnyPublisher<PPOCardEvent, Never> { get }

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

  func eventTriggered(_ event: PPOCardEvent) {
    self.handleEventSubject.send(event)
  }

  func performAction(_ action: ButtonAction) {
    let event: PPOCardEvent
    switch action {
    case let .authenticateCard(clientSecret: clientSecret):
      event = .authenticateCard(clientSecret: clientSecret)
    case .completeSurvey:
      event = .completeSurvey
    case let .confirmAddress(address: address, addressId: addressId):
      event = .confirmAddress(address: address, addressId: addressId)
    case .fixPayment:
      event = .fixPayment
    case .managePledge:
      event = .managePledge
    }
    self.handleEventSubject.send(event)
  }

  // MARK: - Outputs

  var handleEvent: AnyPublisher<PPOCardEvent, Never> {
    self.handleEventSubject.eraseToAnyPublisher()
  }

  private let handleEventSubject = PassthroughSubject<PPOCardEvent, Never>()

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
