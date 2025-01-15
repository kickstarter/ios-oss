import Combine
import Foundation
import KsApi
import Library
import UIKit

protocol PPOContainerViewModelInputs {
  func viewWillAppear()
  func projectAlertsCountChanged(_ count: Int?)
  func handle(navigationEvent: PPONavigationEvent)
  func process3DSAuthentication(state: PPOActionState)
}

protocol PPOContainerViewModelOutputs {
  var projectAlertsBadge: AnyPublisher<TabBarBadge, Never> { get }
  var activityBadge: AnyPublisher<TabBarBadge, Never> { get }
  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> { get }
  var showBanner: AnyPublisher<MessageBannerConfiguration, Never> { get }
}

final class PPOContainerViewModel: PPOContainerViewModelInputs, PPOContainerViewModelOutputs {
  init() {
    let sessionStarted = NotificationCenter.default
      .publisher(for: .ksr_sessionStarted)
      .withEmptyValues()

    let sessionEnded = NotificationCenter.default
      .publisher(for: .ksr_sessionEnded)
      .withEmptyValues()

    let userUpdated = NotificationCenter.default
      .publisher(for: .ksr_userUpdated)
      .withEmptyValues()

    let currentUser = Publishers.Merge4(
      self.viewWillAppearSubject.withEmptyValues(),
      userUpdated,
      sessionStarted,
      sessionEnded
    )
    .map { _ in AppEnvironment.current.currentUser }

    // Update the activity tab bar badge from the user object when it changes
    currentUser
      .map { user in TabBarBadge(count: user?.unseenActivityCount) }
      .subscribe(self.activityBadgeSubject)
      .store(in: &self.cancellables)

    // Update the project alerts tab bar badge from the supplied count when it changes
    self.projectAlertsCountSubject
      .map { count in TabBarBadge(count: count) }
      .subscribe(self.projectAlertsBadgeSubject)
      .store(in: &self.cancellables)

    // Handle 3DS authentication event banners
    self.process3DSAuthenticationState
      .compactMap { state -> MessageBannerConfiguration? in
        switch state {
        case .succeeded:
          return (
            .success,
            Strings.Youve_been_authenticated_successfully_pull_to_refresh()
          )
        case .failed:
          return (.error, Strings.Something_went_wrong_please_try_again())
        case .processing, .cancelled:
          return nil
        }
      }
      .sink { [weak self] configuration in
        self?.showBannerSubject.send(configuration)
      }
      .store(in: &self.cancellables)
  }

  // MARK: - Inputs

  func viewWillAppear() {
    self.viewWillAppearSubject.send()
  }

  func projectAlertsCountChanged(_ count: Int?) {
    self.projectAlertsCountSubject.send(count)
  }

  func handle(navigationEvent: PPONavigationEvent) {
    self.handleNavigationEventSubject.send(navigationEvent)
  }

  func process3DSAuthentication(state: PPOActionState) {
    self.process3DSAuthenticationState.send(state)
  }

  // MARK: - Outputs

  var projectAlertsBadge: AnyPublisher<TabBarBadge, Never> {
    self.projectAlertsBadgeSubject.eraseToAnyPublisher()
  }

  var activityBadge: AnyPublisher<TabBarBadge, Never> {
    self.activityBadgeSubject.eraseToAnyPublisher()
  }

  var navigationEvents: AnyPublisher<PPONavigationEvent, Never> {
    self.handleNavigationEventSubject.eraseToAnyPublisher()
  }

  var showBanner: AnyPublisher<MessageBannerConfiguration, Never> {
    self.showBannerSubject.eraseToAnyPublisher()
  }

  // MARK: - Private

  private var viewWillAppearSubject = PassthroughSubject<Void, Never>()
  private var projectAlertsCountSubject = CurrentValueSubject<Int?, Never>(nil)
  private var projectAlertsBadgeSubject = CurrentValueSubject<TabBarBadge, Never>(.none)
  private var activityBadgeSubject = CurrentValueSubject<TabBarBadge, Never>(.none)
  private var handleNavigationEventSubject = PassthroughSubject<PPONavigationEvent, Never>()
  private let showBannerSubject = PassthroughSubject<MessageBannerConfiguration, Never>()
  private let process3DSAuthenticationState = PassthroughSubject<PPOActionState, Never>()

  private var cancellables: Set<AnyCancellable> = []
}
