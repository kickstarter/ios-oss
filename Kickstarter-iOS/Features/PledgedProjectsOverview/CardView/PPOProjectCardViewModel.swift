import Combine
import Foundation
import KsApi

protocol PPOProjectCardViewModelInputs {
  func sendCreatorMessage()
  func performAction(action: PPOProjectCardAction)
}

protocol PPOProjectCardViewModelOutputs {
  var sendMessageTapped: AnyPublisher<Void, Never> { get }
  var actionPerformed: AnyPublisher<PPOProjectCardAction, Never> { get }

  var isUnread: AnyPublisher<Bool, Never> { get }
  var alerts: AnyPublisher<[PPOProjectCardAlert], Never> { get }
  var imageURL: AnyPublisher<URL, Never> { get }
  var title: AnyPublisher<String, Never> { get }
  var pledge: AnyPublisher<GraphAPI.MoneyFragment, Never> { get }
  var creatorName: AnyPublisher<String, Never> { get }
  var address: AnyPublisher<String?, Never> { get }
  var actions: AnyPublisher<(PPOProjectCardAction, PPOProjectCardAction?), Never> { get }
  var parentSize: AnyPublisher<CGSize, Never> { get }
}

extension PPOProjectCardViewModelOutputs {
  var primaryAction: AnyPublisher<PPOProjectCardAction, Never> {
    self.actions.map({ $0.0 }).eraseToAnyPublisher()
  }

  var secondaryAction: AnyPublisher<PPOProjectCardAction?, Never> {
    self.actions.map({ $0.1 }).eraseToAnyPublisher()
  }
}

typealias PPOProjectCardViewModelType = Identifiable & ObservableObject & PPOProjectCardViewModelInputs &
  PPOProjectCardViewModelOutputs

final class PPOProjectCardViewModel: PPOProjectCardViewModelType {
  let isUnread: AnyPublisher<Bool, Never>
  let alerts: AnyPublisher<[PPOProjectCardAlert], Never>
  let imageURL: AnyPublisher<URL, Never>
  let title: AnyPublisher<String, Never>
  let pledge: AnyPublisher<GraphAPI.MoneyFragment, Never>
  let creatorName: AnyPublisher<String, Never>
  let address: AnyPublisher<String?, Never>
  let actions: AnyPublisher<(PPOProjectCardAction, PPOProjectCardAction?), Never>
  let parentSize: AnyPublisher<CGSize, Never>

  private let sendCreatorMessageSubject = PassthroughSubject<Void, Never>()
  private let actionPerformedSubject = PassthroughSubject<PPOProjectCardViewModel.Action, Never>()

  init(
    isUnread: Bool,
    alerts: [PPOProjectCardViewModel.Alert],
    imageURL: URL,
    title: String,
    pledge: GraphAPI.MoneyFragment,
    creatorName: String,
    address: String?,
    actions: (PPOProjectCardViewModel.Action, PPOProjectCardViewModel.Action?),
    parentSize: CGSize
  ) {
    self.isUnread = Just(isUnread).eraseToAnyPublisher()
    self.alerts = Just(alerts).eraseToAnyPublisher()
    self.imageURL = Just(imageURL).eraseToAnyPublisher()
    self.title = Just(title).eraseToAnyPublisher()
    self.pledge = Just(pledge).eraseToAnyPublisher()
    self.creatorName = Just(creatorName).eraseToAnyPublisher()
    self.address = Just(address).eraseToAnyPublisher()
    self.actions = Just(actions).eraseToAnyPublisher()
    self.parentSize = Just(parentSize).eraseToAnyPublisher()
  }

  // Inputs

  func sendCreatorMessage() {
    self.sendCreatorMessageSubject.send(())
  }

  func performAction(action: Action) {
    self.actionPerformedSubject.send(action)
  }

  // Outputs

  var sendMessageTapped: AnyPublisher<(), Never> { self.sendCreatorMessageSubject.eraseToAnyPublisher() }
  var actionPerformed: AnyPublisher<Action, Never> { self.actionPerformedSubject.eraseToAnyPublisher() }

  // Helpers

  typealias Action = PPOProjectCardAction
  typealias Alert = PPOProjectCardAlert
}

// Types

enum PPOProjectCardAction: Identifiable {
  case confirmAddress
  case editAddress
  case completeSurvey
  case fixPayment
  case authenticateCard

  // TODO: Localize
  var label: String {
    switch self {
    case .confirmAddress:
      "Confirm"
    case .editAddress:
      "Edit"
    case .completeSurvey:
      "Complete survey"
    case .fixPayment:
      "Fix payment"
    case .authenticateCard:
      "Authenticate card"
    }
  }

  var style: Style {
    switch self {
    case .confirmAddress:
      .green
    case .editAddress:
      .black
    case .completeSurvey:
      .green
    case .fixPayment:
      .red
    case .authenticateCard:
      .red
    }
  }

  enum Style: Identifiable {
    case green
    case red
    case black

    var id: String {
      switch self {
      case .green: "green"
      case .red: "red"
      case .black: "black"
      }
    }
  }

  var id: String {
    "\(self.label) \(self.style.id)"
  }
}

struct PPOProjectCardAlert: Identifiable {
  let type: AlertType
  let icon: AlertIcon
  let message: String

  var id: String {
    "\(self.type)-\(self.icon)-\(self.message)"
  }

  enum AlertType: Identifiable {
    case time
    case alert

    var id: String {
      switch self {
      case .time:
        "time"
      case .alert:
        "alert"
      }
    }
  }

  enum AlertIcon: Identifiable {
    case warning
    case alert

    var id: String {
      switch self {
      case .warning:
        "warning"
      case .alert:
        "alert"
      }
    }
  }
}
