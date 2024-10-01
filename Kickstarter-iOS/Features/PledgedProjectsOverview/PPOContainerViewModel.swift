import Combine
import Foundation
import KsApi
import Library

protocol PPOContainerViewModelInputs {
  func viewWillAppear()
  func projectAlertsCountChanged(_ count: Int?)
}

protocol PPOContainerViewModelOutputs {
  var projectAlertsBadge: AnyPublisher<TabBarBadge, Never> { get }
  var activityBadge: AnyPublisher<TabBarBadge, Never> { get }
}

final class PPOContainerViewModel: PPOContainerViewModelInputs, PPOContainerViewModelOutputs {
  init() {
    let sessionStarted = NotificationCenter.default
      .publisher(for: .ksr_sessionStarted)
      .map { _ in () }

    let sessionEnded = NotificationCenter.default
      .publisher(for: .ksr_sessionEnded)
      .map { _ in () }

    let userUpdated = NotificationCenter.default
      .publisher(for: .ksr_userUpdated)
      .map { _ in () }

    let currentUser = Publishers.Merge4(
      self.viewWillAppearSubject,
      userUpdated,
      sessionStarted,
      sessionEnded
    )
    .map { _ in AppEnvironment.current.currentUser }

    currentUser
      .map { user in TabBarBadge(count: user?.unseenActivityCount) }
      .subscribe(self.activityBadgeSubject)
      .store(in: &self.cancellables)

    self.projectAlertsCountSubject
      .map { count in TabBarBadge(count: count) }
      .subscribe(self.projectAlertsBadgeSubject)
      .store(in: &self.cancellables)
  }

  // MARK: - Inputs

  func viewWillAppear() {
    self.viewWillAppearSubject.send()
  }

  func projectAlertsCountChanged(_ count: Int?) {
    self.projectAlertsCountSubject.send(count)
  }

  // MARK: - Outputs

  var projectAlertsBadge: AnyPublisher<TabBarBadge, Never> {
    self.projectAlertsBadgeSubject.eraseToAnyPublisher()
  }

  var activityBadge: AnyPublisher<TabBarBadge, Never> {
    self.activityBadgeSubject.eraseToAnyPublisher()
  }

  // MARK: - Private

  private var viewWillAppearSubject = PassthroughSubject<Void, Never>()
  private var projectAlertsCountSubject = CurrentValueSubject<Int?, Never>(nil)
  private var projectAlertsBadgeSubject = CurrentValueSubject<TabBarBadge, Never>(.none)
  private var activityBadgeSubject = CurrentValueSubject<TabBarBadge, Never>(.none)

  private var cancellables: Set<AnyCancellable> = []
}
