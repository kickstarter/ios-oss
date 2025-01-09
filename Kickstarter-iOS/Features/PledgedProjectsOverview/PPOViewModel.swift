import Combine
import Foundation
import KsApi
import Library
import Stripe
import UIKit

typealias PPOViewModelPaginator = Paginator<
  GraphAPI.FetchPledgedProjectsQuery.Data,
  PPOProjectCardViewModel,
  String,
  ErrorEnvelope,
  Void
>

protocol PPOViewModelInputs {
  func viewDidAppear(authenticationContext: any STPAuthenticationContext)
  func refresh() async
  func loadMore() async

  func openBackedProjects()
  func fixPaymentMethod(from: PPOProjectCardModel)
  func fix3DSChallenge(
    from: PPOProjectCardModel,
    clientSecret: String,
    setLoading: @escaping (Bool) -> Void
  )
  func openSurvey(from: PPOProjectCardModel)
  func viewBackingDetails(from: PPOProjectCardModel)
  func editAddress(from: PPOProjectCardModel)
  func confirmAddress(from: PPOProjectCardModel)
  func contactCreator(from: PPOProjectCardModel)
}

protocol PPOViewModelOutputs {
  var results: PPOViewModelPaginator.Results { get }
  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> { get }
}

enum PPONavigationEvent: Equatable {
  case backedProjects
  case fixPaymentMethod(projectId: Int, backingId: Int)
  case fix3DSChallenge(clientSecret: String, setLoading: (Bool) -> Void)
  case survey(url: String)
  case backingDetails(url: String)
  case editAddress(url: String)
  case confirmAddress
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
    case (.backedProjects, .backedProjects),
         (.confirmAddress, .confirmAddress),
         (.fixPaymentMethod, .fixPaymentMethod):
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
      .combineLatest(self.filteredResultsSubject) { results, filteredIds in
        // Filter out any values that are in the filtered set
        results.mapValues { values in
          values.filter { value in
            !filteredIds.contains(value.card.id)
          }
        }
      }
      .receive(on: RunLoop.main)
      .sink(receiveValue: { results in
        self.results = results
      })
      .store(in: &self.cancellables)

    Publishers.Merge(
      self.viewDidAppearSubject
        .map { _ in () }
        .first(),
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

    // Handle 3DS authentication challenges
    self.fix3DSChallengeSubject
      .combineLatest(self.viewDidAppearSubject) { ($0.0, $0.1, $0.2, $1) }
      .sink { [weak self] model, setupIntent, setLoading, authenticationContext in
        guard let self else { return }
        self.handle3DSChallenge(
          model: model,
          authenticationContext: authenticationContext,
          setupIntent: setupIntent,
          setLoading: setLoading
        )
      }
      .store(in: &self.cancellables)

    // Route navigation events
    Publishers.Merge7(
      self.openBackedProjectsSubject.map { PPONavigationEvent.backedProjects },
      self.fixPaymentMethodSubject
        .map { viewModel in
          PPONavigationEvent.fixPaymentMethod(projectId: viewModel.projectId, backingId: viewModel.backingId)
        },
      self.openSurveySubject.map { viewModel in PPONavigationEvent.survey(url: viewModel.backingDetailsUrl) },
      self.viewBackingDetailsSubject
        .map { viewModel in PPONavigationEvent.survey(url: viewModel.backingDetailsUrl) },
      self.editAddressSubject
        .map { viewModel in PPONavigationEvent.editAddress(url: viewModel.backingDetailsUrl) },
      self.confirmAddressSubject.map { _ in PPONavigationEvent.confirmAddress },
      self.contactCreatorSubject.map { viewModel in
        let messageSubject = MessageSubject.project(id: viewModel.projectId, name: viewModel.projectName)
        return PPONavigationEvent.contactCreator(messageSubject: messageSubject)
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
      .combineLatest(latestLoadedResults)
      .sink { _, properties in
        AppEnvironment.current.ksrAnalytics.trackPPODashboardOpens(properties: properties)
      }
      .store(in: &self.cancellables)

    // Analytics: Tap messaging creator
    self.contactCreatorSubject
      .combineLatest(latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOMessagingCreator(
          from: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)

    // Analytics: Fixing payment failure
    self.fixPaymentMethodSubject
      .combineLatest(latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOFixingPaymentFailure(
          project: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)

    // Analytics: Opening survey
    self.openSurveySubject
      .combineLatest(latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOOpeningSurvey(
          project: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)

    // Analytics: Initiate confirming address
    self.confirmAddressSubject
      .combineLatest(latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOInitiateConfirmingAddress(
          project: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)

    // Analytics: Edit address
    self.editAddressSubject
      .combineLatest(latestLoadedResults)
      .sink { card, overallProperties in
        AppEnvironment.current.ksrAnalytics.trackPPOEditAddress(
          project: card.projectAnalytics,
          properties: overallProperties
        )
      }
      .store(in: &self.cancellables)

    // Trigger haptic feedback when user taps
    self.showBannerSubject
      .dropFirst() // Skip initial nil value
      .compactMap { $0 } // Only trigger on non-nil values
      .sink { banner in
        // Determine feedback type based on banner type
        switch banner.type {
        case .success, .info:
          generateNotificationSuccessFeedback()
        case .error:
          generateNotificationWarningFeedback()
        }
      }
      .store(in: &self.cancellables)

    self.showBannerSubject
      .map { MessageBannerViewViewModel($0) }
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] viewModel in
        self?.bannerViewModel = viewModel
      })
      .store(in: &self.cancellables)
  }

  // MARK: - Inputs

  func viewDidAppear(authenticationContext: any STPAuthenticationContext) {
    self.viewDidAppearSubject.send(authenticationContext)
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
    setLoading: @escaping (Bool) -> Void
  ) {
    self.fix3DSChallengeSubject.send((from, clientSecret, setLoading))
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

  func confirmAddress(from: PPOProjectCardModel) {
    self.confirmAddressSubject.send(from)
  }

  func contactCreator(from: PPOProjectCardModel) {
    self.contactCreatorSubject.send(from)
  }

  // MARK: - Outputs

  @Published var bannerViewModel: MessageBannerViewViewModel? = nil
  @Published var results = PPOViewModelPaginator.Results.unloaded

  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> {
    self.navigationEventSubject.eraseToAnyPublisher()
  }

  // MARK: - Private

  private let paginator: PPOViewModelPaginator

  private let viewDidAppearSubject = PassthroughSubject<any STPAuthenticationContext, Never>()
  private let loadMoreSubject = PassthroughSubject<Void, Never>()
  private let pullToRefreshSubject = PassthroughSubject<Void, Never>()
  private let openBackedProjectsSubject = PassthroughSubject<Void, Never>()
  private let fixPaymentMethodSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let fix3DSChallengeSubject = PassthroughSubject<
    (PPOProjectCardModel, String, (Bool) -> Void),
    Never
  >()
  private let openSurveySubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let viewBackingDetailsSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let editAddressSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let confirmAddressSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let contactCreatorSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let showBannerSubject = PassthroughSubject<MessageBannerConfiguration, Never>()
  private var navigationEventSubject = PassthroughSubject<PPONavigationEvent, Never>()
  private let filteredResultsSubject = CurrentValueSubject<Set<UUID>, Never>([])

  private var cancellables: Set<AnyCancellable> = []

  private enum Constants {
    static let pageSize = 20
  }

  private func handle3DSChallenge(
    model: PPOProjectCardModel,
    authenticationContext: any STPAuthenticationContext,
    setupIntent: String,
    setLoading: @escaping (Bool) -> Void
  ) {
    let confirmParams = STPSetupIntentConfirmParams(clientSecret: setupIntent)

    // Set initial loading state
    setLoading(true)

    #if DEBUG
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] () in
        guard let self else { return }

        self.showBannerSubject.send((.success, "Your payment has been processed."))
        self.filteredResultsSubject.value.insert(model.id)

        setLoading(false)
      }
    #else
      STPPaymentHandler.shared().confirmSetupIntent(
        confirmParams,
        with: authenticationContext,
        completion: { [weak self] status, _, _ in
          switch status {
          case .succeeded:
            self?.showBannerSubject.send((.success, "Your payment has been processed."))
            self?.filteredResultsSubject.value.insert(model.id)
            setLoading(false)
          case .canceled:
            setLoading(false)
          case let .failed:
            self?.showBannerSubject.send((.error, Strings.Something_went_wrong_please_try_again()))
            setLoading(false)
          }
        }
      )
    #endif
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
