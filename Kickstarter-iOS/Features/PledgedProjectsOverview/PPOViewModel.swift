import Combine
import Foundation
import GraphAPI
import KsApi
import Library
import UIKit

typealias PPOViewModelPaginator = Paginator<
  GraphAPI.FetchPledgedProjectsQuery.Data,
  PPOProjectCardViewModel,
  String,
  ErrorEnvelope,
  Void
>

protocol PPOViewModelInputs {
  func viewDidAppear()
  func refresh() async
  func loadMore() async

  func openBackedProjects()
  func handleCardEvent(_: PPOCardEvent, from: PPOProjectCardModel)
}

protocol PPOViewModelOutputs {
  var results: PPOViewModelPaginator.Results { get }
  var preparedEvents: AnyPublisher<PPOPreparedEvent, Never> { get }
}

enum PPOPreparedEvent: Equatable {
  case backedProjects
  case fixPaymentMethod(projectId: Int, backingId: Int)
  case fix3DSChallenge(clientSecret: String, onProgress: (PPOActionState) -> Void)
  case survey(url: String)
  case managePledge(url: String)
  case projectDetails(projectId: Int)
  case editAddress(url: String)
  case confirmAddress(
    backingId: String,
    addressId: String,
    address: String,
    onProgress: (PPOActionState) -> Void
  )
  case contactCreator(messageSubject: MessageSubject)

  static func == (lhs: PPOPreparedEvent, rhs: PPOPreparedEvent) -> Bool {
    switch (lhs, rhs) {
    case let (.survey(lhsUrl), .survey(rhsUrl)):
      return lhsUrl == rhsUrl
    case let (.managePledge(lhsUrl), .managePledge(rhsUrl)):
      return lhsUrl == rhsUrl
    case let (.projectDetails(lhsId), .projectDetails(rhsId)):
      return lhsId == rhsId
    case let (.editAddress(lhsUrl), .editAddress(rhsUrl)):
      return lhsUrl == rhsUrl
    case let (.contactCreator(lhsSubject), .contactCreator(rhsSubject)):
      return lhsSubject == rhsSubject
    case let (
      .fix3DSChallenge(clientSecret: lhsSecret, onProgress: _),
      .fix3DSChallenge(clientSecret: rhsSecret, onProgress: _)
    ):
      return lhsSecret == rhsSecret
    case let (
      .confirmAddress(lhsBackingId, lhsAddressId, lhsAddress, _),
      .confirmAddress(rhsBackingId, rhsAddressId, rhsAddress, _)
    ):
      return lhsBackingId == rhsBackingId && lhsAddressId == rhsAddressId && lhsAddress == rhsAddress
    case let (
      .fixPaymentMethod(lhsProjectId, lhsBackingId),
      .fixPaymentMethod(rhsProjectId, rhsBackingId)
    ):
      return lhsProjectId == rhsProjectId && lhsBackingId == rhsBackingId
    case (.backedProjects, .backedProjects):
      return true
    default:
      return false
    }
  }
}

final class PPOViewModel: ObservableObject, PPOViewModelInputs, PPOViewModelOutputs {
  init() {
    let tierTypes = featurePledgedProjectsOverviewV2Enabled()
      ? PPOTierType.fundedProjectGraphQLTypes()
      : PPOTierType.projectAlertGraphQLTypes()

    let paginator: PPOViewModelPaginator = Paginator(
      valuesFromEnvelope: { data -> [PPOProjectCardViewModel] in
        data.pledgeProjectsOverview?.pledges?.edges?
          .compactMap { edge in edge?.node }
          .compactMap { node in PPOProjectCardModel(node: node) }
          .compactMap { model in PPOProjectCardViewModel(card: model) } ?? []
      },
      cursorFromEnvelope: { data in data.pledgeProjectsOverview?.pledges?.pageInfo.endCursor },
      totalFromEnvelope: { data in data.pledgeProjectsOverview?.pledges?.totalCount },
      requestFromParams: { () in
        AppEnvironment.current.apiService.fetchPledgedProjects(
          tierTypes: tierTypes,
          cursor: nil,
          limit: Constants.pageSize
        )
      },
      requestFromCursor: { cursor in
        AppEnvironment.current.apiService.fetchPledgedProjects(
          tierTypes: tierTypes,
          cursor: cursor,
          limit: Constants.pageSize
        )
      }
    )
    self.paginator = paginator

    paginator.$results
      .drop(while: { results in
        if case .unloaded = results {
          return true
        } else {
          return false
        }
      })
      // SwiftUI List jumps around if reloading frequently. This code path prevents
      // unnecessary reloads if the data has loaded. If the values are the same and
      // both states have been loaded, then we can drop this change.
      .removeDuplicates(by: { left, right in
        left.hasLoaded && right.hasLoaded && left.values == right.values
      })
      .receive(on: RunLoop.main)
      .sink(receiveValue: { results in
        self.results = results
      })
      .store(in: &self.cancellables)

    Publishers.Merge(
      self.viewDidAppearSubject
        .withEmptyValues(),
      self.pullToRefreshSubject
    )
    .sink { () in
      paginator.requestFirstPage()
    }
    .store(in: &self.cancellables)

    self.loadMoreSubject
      .sink { () in
        paginator.requestNextPage()
      }
      .store(in: &self.cancellables)

    // Prepare and route events

    Publishers.Merge(
      self.openBackedProjectsSubject
        .map { PPOPreparedEvent.backedProjects },
      self.handleCardEventSubject
        .map { event, card in
          self.preparedEvent(for: event, cardModel: card)
        }
    )
    .eraseToAnyPublisher()
    .subscribe(self.preparedEventSubject)
    .store(in: &self.cancellables)

    let latestLoadedResults = self.paginator.$results
      .compactMap { results in
        results.hasLoaded ? results.values
          .ppoAnalyticsProperties(total: results.total, page: results.page) : nil
      }

    // Analytics: When view appears, the next time it loads, send a PPO dashboard open
    self.viewDidAppearSubject
      .withFirst(from: latestLoadedResults)
      .sink { _, properties in
        AppEnvironment.current.ksrAnalytics.trackPPODashboardOpens(properties: properties)
      }
      .store(in: &self.cancellables)

    // Analytics: Card event
    self.handleCardEventSubject
      .withFirst(from: latestLoadedResults)
      .map { eventAndCardModel, overallProperties in
        (eventAndCardModel.0, eventAndCardModel.1, overallProperties)
      }
      .sink { event, card, overallProperties in
        self.trackCardEvent(event, cardModel: card, overallProperties: overallProperties)
      }
      .store(in: &self.cancellables)

    // Analytics: Finish confirming address
    self.confirmAddressProgressSubject
      .filter { $0.1 == .confirmed }
      .map { $0.0 } // we just need the card
      .withFirst(from: latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOSubmitAddressConfirmation(
          project: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)
  }

  // MARK: Helpers

  func trackCardEvent(
    _ event: PPOCardEvent,
    cardModel: PPOProjectCardModel,
    overallProperties: KSRAnalytics.PledgedProjectOverviewProperties
  ) {
    switch event {
    case .sendMessage:
      AppEnvironment.current.ksrAnalytics.trackPPOMessagingCreator(
        from: cardModel.projectAnalytics,
        properties: overallProperties
      )
    case .editAddress:
      AppEnvironment.current.ksrAnalytics.trackPPOEditAddress(
        project: cardModel.projectAnalytics,
        properties: overallProperties
      )
    case .fixPayment:
      AppEnvironment.current.ksrAnalytics.trackPPOFixingPaymentFailure(
        project: cardModel.projectAnalytics,
        properties: overallProperties
      )
    case .completeSurvey:
      AppEnvironment.current.ksrAnalytics.trackPPOOpeningSurvey(
        project: cardModel.projectAnalytics,
        properties: overallProperties
      )
    case .managePledge:
      AppEnvironment.current.ksrAnalytics.trackPPOManagePledge(
        project: cardModel.projectAnalytics,
        properties: overallProperties
      )
    case .confirmAddress:
      AppEnvironment.current.ksrAnalytics.trackPPOInitiateConfirmingAddress(
        project: cardModel.projectAnalytics,
        properties: overallProperties
      )
    case .authenticateCard, .viewProjectDetails:
      // These cases are (hopefully) intentionally untracked.
      // TODO(MBL-2818): Confirm that we don't need to add analytics for these events.
      break
    }
  }

  func preparedEvent(
    for event: PPOCardEvent,
    cardModel: PPOProjectCardModel
  ) -> PPOPreparedEvent {
    switch event {
    case .editAddress:
      return PPOPreparedEvent.editAddress(url: cardModel.backingDetailsUrl)
    case .viewProjectDetails:
      return PPOPreparedEvent.projectDetails(projectId: cardModel.projectId)
    case .sendMessage:
      let messageSubject = MessageSubject.project(
        id: cardModel.projectId,
        name: cardModel.projectName
      )
      return PPOPreparedEvent.contactCreator(messageSubject: messageSubject)
    case .completeSurvey:
      return PPOPreparedEvent.survey(url: cardModel.backingDetailsUrl)
    case .fixPayment:
      return PPOPreparedEvent.fixPaymentMethod(
        projectId: cardModel.projectId,
        backingId: cardModel.backingId
      )
    case .managePledge:
      return PPOPreparedEvent.managePledge(url: cardModel.backingDetailsUrl)
    case let .confirmAddress(address, addressId):
      return PPOPreparedEvent.confirmAddress(
        backingId: cardModel.backingGraphId,
        addressId: addressId,
        address: address,
        onProgress: { [weak self] state in
          self?.confirmAddressProgressSubject.send((cardModel, state))
        }
      )
    case let .authenticateCard(clientSecret, onProgress):
      return PPOPreparedEvent.fix3DSChallenge(
        clientSecret: clientSecret,
        onProgress: onProgress
      )
    }
  }

  // MARK: - Inputs

  func viewDidAppear() {
    self.viewDidAppearSubject.send()
  }

  func loadMore() async {
    self.loadMoreSubject.send(())
    _ = await self.paginator.nextResult()
  }

  func refresh() async {
    self.pullToRefreshSubject.send(())
    _ = await self.paginator.nextResult()
  }

  func openBackedProjects() {
    self.openBackedProjectsSubject.send(())
  }

  func handleCardEvent(_ cardAction: PPOCardEvent, from cardModel: PPOProjectCardModel) {
    self.handleCardEventSubject.send((cardAction, cardModel))
  }

  // MARK: - Outputs

  @Published var results = PPOViewModelPaginator.Results.unloaded

  var preparedEvents: AnyPublisher<PPOPreparedEvent, Never> {
    self.preparedEventSubject.eraseToAnyPublisher()
  }

  // MARK: - Private

  private let paginator: PPOViewModelPaginator

  private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
  private let loadMoreSubject = PassthroughSubject<Void, Never>()
  private let pullToRefreshSubject = PassthroughSubject<Void, Never>()
  private let openBackedProjectsSubject = PassthroughSubject<Void, Never>()
  private let confirmAddressProgressSubject = PassthroughSubject<
    (PPOProjectCardModel, PPOActionState),
    Never
  >()

  private let handleCardEventSubject = PassthroughSubject<
    (PPOCardEvent, PPOProjectCardModel),
    Never
  >()

  private var preparedEventSubject = PassthroughSubject<PPOPreparedEvent, Never>()

  private var cancellables: Set<AnyCancellable> = []

  private enum Constants {
    static let pageSize = 10
  }
}

extension Sequence where Element == PPOProjectCardViewModel {
  func ppoAnalyticsProperties(total: Int?, page: Int?) -> KSRAnalytics.PledgedProjectOverviewProperties {
    var paymentFailedCount: Int = 0
    var cardAuthRequiredCount: Int = 0
    var surveyAvailableCount: Int = 0
    var addressLocksSoonCount: Int = 0
    var pledgeManagementCount: Int = 0

    for viewModel in self {
      switch viewModel.card.tierType {
      case .fixPayment:
        paymentFailedCount += 1
      case .authenticateCard:
        cardAuthRequiredCount += 1
      case .openSurvey:
        surveyAvailableCount += 1
      case .confirmAddress:
        addressLocksSoonCount += 1
      case .pledgeManagement:
        pledgeManagementCount += 1
      case .surveySubmitted, .pledgeCollected, .addressConfirmed, .awaitingReward, .rewardReceived:
        // TODO(MBL-2818): Add analytics for PPO v2.
        break
      }
    }

    return KSRAnalytics.PledgedProjectOverviewProperties(
      addressLocksSoonCount: addressLocksSoonCount,
      surveyAvailableCount: surveyAvailableCount,
      pledgeManagementCount: pledgeManagementCount,
      paymentFailedCount: paymentFailedCount,
      cardAuthRequiredCount: cardAuthRequiredCount,
      total: total,
      page: page
    )
  }
}

extension Publisher {
  /// Combines this publisher with the first value emitted by another publisher.
  /// - Warning: This is not a direct replacement for `withLatestFrom` from other ReactiveX libraries.
  /// - Parameter other: The publisher to grab the first value from
  /// - Returns: A publisher that emits tuples of values from this publisher paired with the first value from the other publisher
  func withFirst<B>(from other: B) -> AnyPublisher<(Self.Output, B.Output), Self.Failure> where B: Publisher,
    B.Failure == Self.Failure {
    return self.flatMap { foo in
      other.first().map { (foo, $0) }
    }.eraseToAnyPublisher()
  }
}
