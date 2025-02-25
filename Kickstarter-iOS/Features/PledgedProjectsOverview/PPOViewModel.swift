import Combine
import Foundation
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
  func fixPaymentMethod(from: PPOProjectCardModel)
  func fix3DSChallenge(
    from: PPOProjectCardModel,
    clientSecret: String,
    onProgress: @escaping (PPOActionState) -> Void
  )
  func openSurvey(from: PPOProjectCardModel)
  func viewBackingDetails(from: PPOProjectCardModel)
  func editAddress(from: PPOProjectCardModel)
  func confirmAddress(from: PPOProjectCardModel, address: String, addressId: String)
  func contactCreator(from: PPOProjectCardModel)
}

protocol PPOViewModelOutputs {
  var results: PPOViewModelPaginator.Results { get }
  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> { get }
}

enum PPONavigationEvent: Equatable {
  case backedProjects
  case fixPaymentMethod(projectId: Int, backingId: Int)
  case fix3DSChallenge(clientSecret: String, onProgress: (PPOActionState) -> Void)
  case survey(url: String)
  case backingDetails(url: String)
  case editAddress(url: String)
  case confirmAddress(
    backingId: String,
    addressId: String,
    address: String,
    onProgress: (PPOActionState) -> Void
  )
  case contactCreator(messageSubject: MessageSubject)

  static func == (lhs: PPONavigationEvent, rhs: PPONavigationEvent) -> Bool {
    switch (lhs, rhs) {
    case let (.survey(lhsUrl), .survey(rhsUrl)):
      return lhsUrl == rhsUrl
    case let (.backingDetails(lhsUrl), .backingDetails(rhsUrl)):
      return lhsUrl == rhsUrl
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
        AppEnvironment.current.apiService.fetchPledgedProjects(cursor: nil, limit: Constants.pageSize)
      },
      requestFromCursor: { cursor in
        AppEnvironment.current.apiService.fetchPledgedProjects(cursor: cursor, limit: Constants.pageSize)
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

    // Route navigation events
    Publishers.Merge8(
      self.openBackedProjectsSubject.map { PPONavigationEvent.backedProjects },
      self.openSurveySubject.map { viewModel in PPONavigationEvent.survey(url: viewModel.backingDetailsUrl) },
      self.viewBackingDetailsSubject
        .map { viewModel in PPONavigationEvent.survey(url: viewModel.backingDetailsUrl) },
      self.editAddressSubject
        .map { viewModel in PPONavigationEvent.editAddress(url: viewModel.backingDetailsUrl) },
      self.confirmAddressSubject.map { viewModel, address, addressId in
        PPONavigationEvent.confirmAddress(
          backingId: viewModel.backingGraphId,
          addressId: addressId,
          address: address,
          onProgress: { [weak self] state in
            self?.confirmAddressProgressSubject.send((viewModel, state))
          }
        )
      },
      self.contactCreatorSubject.map { viewModel in
        let messageSubject = MessageSubject.project(id: viewModel.projectId, name: viewModel.projectName)
        return PPONavigationEvent.contactCreator(messageSubject: messageSubject)
      },
      self.fixPaymentMethodSubject.map { model in PPONavigationEvent.fixPaymentMethod(
        projectId: model.projectId,
        backingId: model.backingId
      ) },
      self.fix3DSChallengeSubject.map { _, clientSecret, onProgress in
        PPONavigationEvent.fix3DSChallenge(
          clientSecret: clientSecret,
          onProgress: onProgress
        )
      }
    )
    .subscribe(self.navigationEventSubject)
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

    // Analytics: Tap messaging creator
    self.contactCreatorSubject
      .withFirst(from: latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOMessagingCreator(
          from: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)

    // Analytics: Fixing payment failure
    self.fixPaymentMethodSubject
      .withFirst(from: latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOFixingPaymentFailure(
          project: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)

    // Analytics: Opening survey
    self.openSurveySubject
      .withFirst(from: latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOOpeningSurvey(
          project: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)

    // Analytics: Initiate confirming address
    self.confirmAddressSubject
      .withFirst(from: latestLoadedResults)
      .sink { cardProperties, overallProperties in
        let (card, _, _) = cardProperties
        AppEnvironment.current.ksrAnalytics.trackPPOInitiateConfirmingAddress(
          project: card.projectAnalytics,
          properties: overallProperties
        )
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

    // Analytics: Edit address
    self.editAddressSubject
      .withFirst(from: latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOEditAddress(
          project: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)
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

  // TODO: Add any additional properties for routing (MBL-1451)

  func openBackedProjects() {
    self.openBackedProjectsSubject.send(())
  }

  func fixPaymentMethod(from: PPOProjectCardModel) {
    self.fixPaymentMethodSubject.send(from)
  }

  func fix3DSChallenge(
    from: PPOProjectCardModel,
    clientSecret: String,
    onProgress: @escaping (PPOActionState) -> Void
  ) {
    self.fix3DSChallengeSubject.send((from, clientSecret, onProgress))
  }

  func openSurvey(from: PPOProjectCardModel) {
    self.openSurveySubject.send(from)
  }

  func viewBackingDetails(from: PPOProjectCardModel) {
    self.viewBackingDetailsSubject.send(from)
  }

  func editAddress(from: PPOProjectCardModel) {
    self.editAddressSubject.send(from)
  }

  func confirmAddress(from: PPOProjectCardModel, address: String, addressId: String) {
    self.confirmAddressSubject.send((from, address, addressId))
  }

  func contactCreator(from: PPOProjectCardModel) {
    self.contactCreatorSubject.send(from)
  }

  // MARK: - Outputs

  @Published var results = PPOViewModelPaginator.Results.unloaded

  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> {
    self.navigationEventSubject.eraseToAnyPublisher()
  }

  // MARK: - Private

  private let paginator: PPOViewModelPaginator

  private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
  private let loadMoreSubject = PassthroughSubject<Void, Never>()
  private let pullToRefreshSubject = PassthroughSubject<Void, Never>()
  private let openBackedProjectsSubject = PassthroughSubject<Void, Never>()
  private let fixPaymentMethodSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let fix3DSChallengeSubject = PassthroughSubject<
    (PPOProjectCardModel, String, (PPOActionState) -> Void),
    Never
  >()
  private let openSurveySubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let viewBackingDetailsSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let editAddressSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let confirmAddressSubject = PassthroughSubject<(PPOProjectCardModel, String, String), Never>()
  private let confirmAddressProgressSubject = PassthroughSubject<
    (PPOProjectCardModel, PPOActionState),
    Never
  >()
  private let contactCreatorSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private var navigationEventSubject = PassthroughSubject<PPONavigationEvent, Never>()

  private var cancellables: Set<AnyCancellable> = []

  private enum Constants {
    static let pageSize = 20
  }
}

extension Sequence where Element == PPOProjectCardViewModel {
  func ppoAnalyticsProperties(total: Int?, page: Int?) -> KSRAnalytics.PledgedProjectOverviewProperties {
    var paymentFailedCount: Int = 0
    var cardAuthRequiredCount: Int = 0
    var surveyAvailableCount: Int = 0
    var addressLocksSoonCount: Int = 0

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
      }
    }

    return KSRAnalytics.PledgedProjectOverviewProperties(
      addressLocksSoonCount: addressLocksSoonCount,
      surveyAvailableCount: surveyAvailableCount,
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
