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

  var isUnread: Bool { get }
  var alerts: [PledgedProjectOverviewCard.Alert] { get }
  var imageURL: URL { get }
  var title: String { get }
  var pledge: GraphAPI.MoneyFragment { get }
  var creatorName: String { get }
  var address: String? { get }
  var actions: (PledgedProjectOverviewCard.Action, PledgedProjectOverviewCard.Action?) { get }
  var tierType: PledgedProjectOverviewCard.TierType { get }
  var parentSize: CGSize { get }
}

extension PPOProjectCardViewModelOutputs {
  var primaryAction: PledgedProjectOverviewCard.Action {
    let (primary, _) = self.actions
    return primary
  }

  var secondaryAction: PledgedProjectOverviewCard.Action? {
    let (_, secondary) = self.actions
    return secondary
  }
}

typealias PPOProjectCardViewModelType = Equatable & Identifiable & ObservableObject &
  PPOProjectCardViewModelInputs &
  PPOProjectCardViewModelOutputs

final class PPOProjectCardViewModel: PPOProjectCardViewModelType {
  @Published private(set) var isUnread: Bool
  @Published private(set) var alerts: [PledgedProjectOverviewCard.Alert]
  @Published private(set) var imageURL: URL
  @Published private(set) var title: String
  @Published private(set) var project: Project
  @Published private(set) var pledge: GraphAPI.MoneyFragment
  @Published private(set) var creatorName: String
  @Published private(set) var address: String?
  @Published private(set) var actions: (PledgedProjectOverviewCard.Action, PledgedProjectOverviewCard.Action?)
  @Published private(set) var tierType: PledgedProjectOverviewCard.TierType
  @Published private(set) var parentSize: CGSize

  private let sendCreatorMessageSubject = PassthroughSubject<Void, Never>()
  private let actionPerformedSubject = PassthroughSubject<PledgedProjectOverviewCard.Action, Never>()

  init(
    isUnread: Bool,
    alerts: [PledgedProjectOverviewCard.Alert],
    imageURL: URL,
    title: String,
    project: Project,
    pledge: GraphAPI.MoneyFragment,
    creatorName: String,
    address: String?,
    actions: (PledgedProjectOverviewCard.Action, PledgedProjectOverviewCard.Action?),
    tierType: PledgedProjectOverviewCard.TierType,
    parentSize: CGSize
  ) {
    self.isUnread = isUnread
    self.alerts = alerts
    self.imageURL = imageURL
    self.title = title
    self.project = project
    self.pledge = pledge
    self.creatorName = creatorName
    self.address = address
    self.actions = actions
    self.tierType = tierType
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

  // For some reason this isn't generated because of the `actions` tuple
  // If that ever is fixed, this can be removed in favor of a synthesized Equatable implementation
  static func == (lhs: PPOProjectCardViewModel, rhs: PPOProjectCardViewModel) -> Bool {
    lhs.isUnread == rhs.isUnread &&
      lhs.alerts == rhs.alerts &&
      lhs.imageURL == rhs.imageURL &&
      lhs.title == rhs.title &&
      lhs.project == rhs.project &&
      lhs.pledge == rhs.pledge &&
      lhs.creatorName == rhs.creatorName &&
      lhs.address == rhs.address &&
      lhs.actions == rhs.actions &&
      lhs.parentSize == rhs.parentSize
  }
}

extension GraphAPI.MoneyFragment: Equatable {
  public static func == (lhs: KsApi.GraphAPI.MoneyFragment, rhs: KsApi.GraphAPI.MoneyFragment) -> Bool {
    return lhs.amount == rhs.amount &&
      lhs.currency == rhs.currency &&
      lhs.symbol == rhs.symbol
  }
}
