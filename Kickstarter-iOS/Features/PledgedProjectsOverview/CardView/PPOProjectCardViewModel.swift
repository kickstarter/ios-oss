import Combine
import Foundation
import KsApi

protocol PPOProjectCardViewModelInputs {
  func sendCreatorMessage()
  func performAction(action: PledgedProjectOverviewCard.Action)
}

protocol PPOProjectCardViewModelOutputs {
  var sendMessageTapped: AnyPublisher<Void, Never> { get }
  var actionPerformed: AnyPublisher<PledgedProjectOverviewCard.Action, Never> { get }

  var card: PledgedProjectOverviewCard { get }
  var parentSize: CGSize { get }
}

extension PPOProjectCardViewModelOutputs {
  var primaryAction: PledgedProjectOverviewCard.Action {
    let (primary, _) = self.card.actions
    return primary
  }

  var secondaryAction: PledgedProjectOverviewCard.Action? {
    let (_, secondary) = self.card.actions
    return secondary
  }
}

typealias PPOProjectCardViewModelType = Equatable & Identifiable & ObservableObject &
  PPOProjectCardViewModelInputs &
  PPOProjectCardViewModelOutputs

final class PPOProjectCardViewModel: PPOProjectCardViewModelType {
  @Published private(set) var card: PledgedProjectOverviewCard
  @Published private(set) var parentSize: CGSize

  private let sendCreatorMessageSubject = PassthroughSubject<Void, Never>()
  private let actionPerformedSubject = PassthroughSubject<PledgedProjectOverviewCard.Action, Never>()

  init(
    card: PledgedProjectOverviewCard,
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

  // MARK: - Helpers

  typealias Action = PledgedProjectOverviewCard.Action
  typealias Alert = PledgedProjectOverviewCard.Alert

  // MARK: - Equatable

  static func == (lhs: PPOProjectCardViewModel, rhs: PPOProjectCardViewModel) -> Bool {
    lhs.card == rhs.card && lhs.parentSize == rhs.parentSize
  }
}
