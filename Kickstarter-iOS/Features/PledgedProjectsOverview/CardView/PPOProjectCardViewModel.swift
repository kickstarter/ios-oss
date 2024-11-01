import Combine
import Foundation
import KsApi

protocol PPOProjectCardViewModelInputs {
  func viewBackingDetails()
  func sendCreatorMessage()
  func performAction(action: PPOProjectCardModel.Action)
}

protocol PPOProjectCardViewModelOutputs {
  var viewBackingDetailsTapped: AnyPublisher<Void, Never> { get }
  var sendMessageTapped: AnyPublisher<Void, Never> { get }
  var actionPerformed: AnyPublisher<PPOProjectCardModel.Action, Never> { get }

  var card: PPOProjectCardModel { get }
}

extension PPOProjectCardViewModelOutputs {
  var primaryAction: PPOProjectCardModel.Action {
    let (primary, _) = self.card.actions
    return primary
  }

  var secondaryAction: PPOProjectCardModel.Action? {
    let (_, secondary) = self.card.actions
    return secondary
  }
}

typealias PPOProjectCardViewModelType = Equatable & Hashable & Identifiable & ObservableObject &
  PPOProjectCardViewModelInputs &
  PPOProjectCardViewModelOutputs

final class PPOProjectCardViewModel: PPOProjectCardViewModelType {
  @Published private(set) var card: PPOProjectCardModel

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.card)
  }

  init(
    card: PPOProjectCardModel
  ) {
    self.card = card
  }

  // MARK: - Inputs

  func sendCreatorMessage() {
    self.sendCreatorMessageSubject.send()
  }

  func performAction(action: Action) {
    self.actionPerformedSubject.send(action)
  }

  func viewBackingDetails() {
    self.viewBackingDetailsSubject.send()
  }

  // MARK: - Outputs

  var viewBackingDetailsTapped: AnyPublisher<(), Never> { self.viewBackingDetailsSubject.eraseToAnyPublisher() }
  var sendMessageTapped: AnyPublisher<(), Never> { self.sendCreatorMessageSubject.eraseToAnyPublisher() }
  var actionPerformed: AnyPublisher<Action, Never> { self.actionPerformedSubject.eraseToAnyPublisher() }

  private let viewBackingDetailsSubject = PassthroughSubject<Void, Never>()
  private let sendCreatorMessageSubject = PassthroughSubject<Void, Never>()
  private let actionPerformedSubject = PassthroughSubject<PPOProjectCardModel.Action, Never>()

  // MARK: - Helpers

  typealias Action = PPOProjectCardModel.Action
  typealias Alert = PPOProjectCardModel.Alert

  // MARK: - Equatable

  static func == (lhs: PPOProjectCardViewModel, rhs: PPOProjectCardViewModel) -> Bool {
    lhs.card == rhs.card
  }
}
