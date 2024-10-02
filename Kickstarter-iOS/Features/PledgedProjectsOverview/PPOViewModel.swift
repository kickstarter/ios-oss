import Combine
import Foundation
import KsApi
import Library

typealias PPOViewModelPaginator = Paginator<
  PledgedProjectOverviewCardsEnvelope,
  PPOProjectCardViewModel,
  String,
  ErrorEnvelope,
  Void
>

protocol PPOViewModelInputs {
  func viewDidAppear()
  func loadMore()
  func pullToRefresh()

  func openBackedProjects()
  func fixPaymentMethod()
  func fix3DSChallenge()
  func openSurvey()
  func editAddress()
  func confirmAddress()
  func contactCreator()
}

protocol PPOViewModelOutputs {
  var results: PPOViewModelPaginator.Results { get }
  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> { get }
}

enum PPONavigationEvent {
  case backedProjects
  case fixPaymentMethod
  case fix3DSChallenge
  case survey
  case editAddress
  case confirmAddress
  case contactCreator
}

final class PPOViewModel: ObservableObject, PPOViewModelInputs, PPOViewModelOutputs {
  init() {
    let paginator: PPOViewModelPaginator = Paginator(
      valuesFromEnvelope: { data in
        data.cards.compactMap { PPOProjectCardViewModel(card: $0, parentSize: .zero) }
      },
      cursorFromEnvelope: { data in data.cursor },
      totalFromEnvelope: { data in data.totalCount },
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
    Publishers.Merge7(
      self.openBackedProjectsSubject.map { PPONavigationEvent.backedProjects },
      self.fixPaymentMethodSubject.map { PPONavigationEvent.fixPaymentMethod },
      self.fix3DSChallengeSubject.map { PPONavigationEvent.fix3DSChallenge },
      self.openSurveySubject.map { PPONavigationEvent.survey },
      self.editAddressSubject.map { PPONavigationEvent.editAddress },
      self.confirmAddressSubject.map { PPONavigationEvent.confirmAddress },
      self.contactCreatorSubject.map { PPONavigationEvent.contactCreator }
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
        results.hasLoaded ? results.values : nil
      }
      .map { results in results.ppoAnalyticsProperties }

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
      .sink { _, _ in
        // TODO
      }
      .store(in: &self.cancellables)

    // Analytics: Fixing payment failure
    self.fixPaymentMethodSubject
      .combineLatest(latestLoadedResults)
      .sink { _, _ in
        // TODO
      }
      .store(in: &self.cancellables)

    // Analytics: Opening survey
    self.openSurveySubject
      .combineLatest(latestLoadedResults)
      .sink { _, _ in
        // TODO
      }
      .store(in: &self.cancellables)

    // Analytics: Initiate confirming address
    self.confirmAddressSubject
      .combineLatest(latestLoadedResults)
      .sink { _, _ in
        // TODO
      }
      .store(in: &self.cancellables)

    // Analytics: Edit address
    self.editAddressSubject
      .combineLatest(latestLoadedResults)
      .sink { _, _ in
        // TODO
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

  func loadMore() {
    self.loadMoreSubject.send(())
  }

  func pullToRefresh() {
    self.pullToRefreshSubject.send(())
  }

  // TODO: Add any additional properties for routing (MBL-1451)

  func openBackedProjects() {
    self.openBackedProjectsSubject.send(())
  }

  func fixPaymentMethod() {
    self.fixPaymentMethodSubject.send(())
  }

  func fix3DSChallenge() {
    self.fix3DSChallengeSubject.send(())
  }

  func openSurvey() {
    self.openSurveySubject.send(())
  }

  func editAddress() {
    self.editAddressSubject.send(())
  }

  func confirmAddress() {
    self.confirmAddressSubject.send(())
  }

  func contactCreator() {
    self.contactCreatorSubject.send(())
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
  private let shouldSendSampleMessageSubject = PassthroughSubject<(), Never>()
  private let openBackedProjectsSubject = PassthroughSubject<Void, Never>()
  private let fixPaymentMethodSubject = PassthroughSubject<Void, Never>()
  private let fix3DSChallengeSubject = PassthroughSubject<Void, Never>()
  private let openSurveySubject = PassthroughSubject<Void, Never>()
  private let editAddressSubject = PassthroughSubject<Void, Never>()
  private let confirmAddressSubject = PassthroughSubject<Void, Never>()
  private let contactCreatorSubject = PassthroughSubject<Void, Never>()

  private var navigationEventSubject = PassthroughSubject<PPONavigationEvent, Never>()

  private var cancellables: Set<AnyCancellable> = []

  private enum Constants {
    static let pageSize = 20
  }
}

extension Sequence where Element == PPOProjectCardViewModel {
  var ppoAnalyticsProperties: KSRAnalytics.PledgedProjectOverviewProperties {
    var paymentFailedCount: Int = 0
    var cardAuthRequiredCount: Int = 0
    var surveyAvailableCount: Int = 0
    var addressLocksSoonCount: Int = 0
    var total: Int = 0
    let page: Int? = nil

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
