import Combine
import Foundation
import KsApi
import Library

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
  func fix3DSChallenge(from: PPOProjectCardModel, clientSecret: String)
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
  case fix3DSChallenge(clientSecret: String)
  case survey(url: String)
  case backingDetails(url: String)
  case editAddress(url: String)
  case confirmAddress
  case contactCreator(messageSubject: MessageSubject)
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
      .receive(on: RunLoop.main)
      .assign(to: &self.$results)

    Publishers.Merge(
      self.viewDidAppearSubject
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

    // Route navigation events
    Publishers.Merge8(
      self.openBackedProjectsSubject.map { PPONavigationEvent.backedProjects },
<<<<<<< HEAD
      self.fixPaymentMethodSubject
        .map { viewModel in
          PPONavigationEvent.fixPaymentMethod(projectId: viewModel.projectId, backingId: viewModel.backingId)
        },
      self.fix3DSChallengeSubject.map { _ in PPONavigationEvent.fix3DSChallenge },
=======
      self.fixPaymentMethodSubject.map { _ in PPONavigationEvent.fixPaymentMethod },
      self.fix3DSChallengeSubject.map { secret in
        PPONavigationEvent.fix3DSChallenge(
          clientSecret: secret
        )
      },
>>>>>>> ccf05dbeb (Propagate client secret through PPOProjectCardModel action and bubble it up through to PPOContainerViewController)
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

    // TODO: Send actual banner messages in response to card actions instead.
    self.shouldSendSampleMessageSubject
      .sink { [weak self] _ in
//        self?.bannerViewModel = MessageBannerViewViewModel((
//          .success,
//          "Survey submitted! Need to change your address? Visit your backing details on our website."
//        ))
        self?.bannerViewModel = MessageBannerViewViewModel((.success, "Your payment has been processed."))
      }
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
  }

  // MARK: - Inputs

  func shouldSendSampleMessage() {
    self.shouldSendSampleMessageSubject.send(())
  }

  func viewDidAppear() {
    self.viewDidAppearSubject.send(())
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

  func fix3DSChallenge(from _: PPOProjectCardModel, clientSecret: String) {
    self.fix3DSChallengeSubject.send(clientSecret)
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

  private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
  private let loadMoreSubject = PassthroughSubject<Void, Never>()
  private let pullToRefreshSubject = PassthroughSubject<Void, Never>()
  private let shouldSendSampleMessageSubject = PassthroughSubject<Void, Never>()
  private let openBackedProjectsSubject = PassthroughSubject<Void, Never>()
  private let fixPaymentMethodSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let fix3DSChallengeSubject = PassthroughSubject<String, Never>()
  private let openSurveySubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let viewBackingDetailsSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let editAddressSubject = PassthroughSubject<PPOProjectCardModel, Never>()
  private let confirmAddressSubject = PassthroughSubject<PPOProjectCardModel, Never>()
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
