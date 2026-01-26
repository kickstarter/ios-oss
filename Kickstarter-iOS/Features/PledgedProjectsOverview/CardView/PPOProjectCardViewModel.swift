import Combine
import Foundation
import KsApi
import Library

public enum PPOCardEvent: Equatable {
  case editAddress(url: String)
  case sendMessage
  case updateRewardReceived(rewardReceived: Bool)
  case viewProjectDetails
  case confirmAddress(address: String, addressId: String)
  case completeSurvey(url: String)
  case managePledge(url: String)
  case fixPayment
  case authenticateCard(clientSecret: String, onProgress: (PPOActionState) -> Void)

  public static func == (lhs: PPOCardEvent, rhs: PPOCardEvent) -> Bool {
    switch (lhs, rhs) {
    case (.sendMessage, .sendMessage): return true
    case (.viewProjectDetails, .viewProjectDetails): return true
    case (.fixPayment, .fixPayment): return true
    case let (.editAddress(lhsUrl), .editAddress(rhsUrl)): return lhsUrl == rhsUrl
    case let (.completeSurvey(lhsUrl), .completeSurvey(rhsUrl)): return lhsUrl == rhsUrl
    case let (.managePledge(lhsUrl), .managePledge(rhsUrl)): return lhsUrl == rhsUrl
    case let (
      .confirmAddress(address: lhsAddress, addressId: lhsId),
      .confirmAddress(address: rhsAddress, addressId: rhsId)
    ):
      return lhsAddress == rhsAddress && lhsId == rhsId
    case let (
      .authenticateCard(lhsClientSecret, _),
      .authenticateCard(rhsClientSecret, _)
    ):
      return lhsClientSecret == rhsClientSecret
    case let (.updateRewardReceived(lhsRewardReceived), .updateRewardReceived(rhsRewardReceived)):
      return lhsRewardReceived == rhsRewardReceived
    default:
      return false
    }
  }
}

protocol PPOProjectCardViewModelInputs {
  // Trigger a PPOCardEvent directly.
  func eventTriggered(_: PPOCardEvent)
  // Trigger the PPOCardEvent corresponding to the ButtonAction.
  func performAction(_: PPOProjectCardModel.ButtonAction)
  // React to toggle being flipped.
  func rewardToggleTapped(toggleOn: Bool)
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
  @Published var rewardToggleEnabled: Bool

  private var cancellables: Set<AnyCancellable> = []

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.card)
  }

  init(
    card: PPOProjectCardModel
  ) {
    self.card = card
    self.rewardToggleEnabled = card.rewardReceivedToggleState == .rewardReceived

    self.rewardToggleTappedSubject
      .debounce(for: 0.3 /* seconds */, scheduler: DispatchQueue.main)
      .sink { toggleOn in
        self.handleEventSubject.send(.updateRewardReceived(rewardReceived: toggleOn))
      }
      .store(in: &self.cancellables)
  }

  // MARK: - Inputs

  func eventTriggered(_ event: PPOCardEvent) {
    self.handleEventSubject.send(event)
  }

  func performAction(_ action: ButtonAction) {
    let event: PPOCardEvent
    switch action {
    case let .authenticateCard(clientSecret: clientSecret):
      event = .authenticateCard(clientSecret: clientSecret, onProgress: { [weak self] state in
        self?.handle3DSState(state)
      })
    case let .completeSurvey(url: url):
      event = .completeSurvey(url: url)
    case let .confirmAddress(address: address, addressId: addressId):
      event = .confirmAddress(address: address, addressId: addressId)
    case .fixPayment:
      event = .fixPayment
    case let .managePledge(url: url):
      event = .managePledge(url: url)
    }
    self.handleEventSubject.send(event)
  }

  func rewardToggleTapped(toggleOn: Bool) {
    self.rewardToggleTappedSubject.send(toggleOn)
  }

  // MARK: - Outputs

  var handleEvent: AnyPublisher<PPOCardEvent, Never> {
    self.handleEventSubject.eraseToAnyPublisher()
  }

  private let handleEventSubject = PassthroughSubject<PPOCardEvent, Never>()

  private let rewardToggleTappedSubject = PassthroughSubject<Bool, Never>()

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
