import Combine
import Foundation
import KsApi

protocol PPOProjectCardViewModelInputs {
  func sendCreatorMessage()
  func performAction(action: PPOProjectCardModel.Action)
}

protocol PPOProjectCardViewModelOutputs {
  var sendMessageTapped: AnyPublisher<Void, Never> { get }
  var actionPerformed: AnyPublisher<PPOProjectCardModel.Action, Never> { get }

  var card: PPOProjectCardModel { get }
  var parentSize: CGSize { get }
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

typealias PPOProjectCardViewModelType = Equatable & Identifiable & ObservableObject &
  PPOProjectCardViewModelInputs &
  PPOProjectCardViewModelOutputs

final class PPOProjectCardViewModel: PPOProjectCardViewModelType {
  @Published private(set) var card: PPOProjectCardModel
  @Published private(set) var parentSize: CGSize

  init(
    card: PPOProjectCardModel,
    parentSize: CGSize
  ) {
    self.card = card
    self.parentSize = parentSize
  }

  // MARK: - Inputs

  func sendCreatorMessage() {
    self.sendCreatorMessageSubject.send(())
  }

  func performAction(action: Action) {
    self.actionPerformedSubject.send(action)
  }

  // MARK: - Outputs

  var sendMessageTapped: AnyPublisher<(), Never> { self.sendCreatorMessageSubject.eraseToAnyPublisher() }
  var actionPerformed: AnyPublisher<Action, Never> { self.actionPerformedSubject.eraseToAnyPublisher() }

  private let sendCreatorMessageSubject = PassthroughSubject<Void, Never>()
  private let actionPerformedSubject = PassthroughSubject<PPOProjectCardModel.Action, Never>()

  // MARK: - Helpers

  typealias Action = PPOProjectCardModel.Action
  typealias Alert = PPOProjectCardModel.Alert

  // MARK: - Equatable

  static func == (lhs: PPOProjectCardViewModel, rhs: PPOProjectCardViewModel) -> Bool {
    lhs.card == rhs.card && lhs.parentSize == rhs.parentSize
  }
}
