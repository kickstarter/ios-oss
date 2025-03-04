import Foundation
import ReactiveSwift

public protocol SimilarProjectsUseCaseType {
  var inputs: SimilarProjectsUseCaseInputs { get }
  var outputs: SimilarProjectsUseCaseOutputs { get }
}

public protocol SimilarProjectsUseCaseInputs {
  func projectTapped(project: any SimilarProject)
  func projectIDLoaded(projectID: String)
}

public protocol SimilarProjectsUseCaseOutputs {
  var similarProjects: Property<SimilarProjectsState> { get }
  var navigateToProject: Signal<any SimilarProject, Never> { get }
}

public final class SimilarProjectsUseCase: SimilarProjectsUseCaseType, SimilarProjectsUseCaseInputs,
  SimilarProjectsUseCaseOutputs {
  // MARK: - Initialization

  init() {
    self.navigateToProject = self.projectTappedSignal

    self.projectIDLoadedSignal
      .flatMap(.latest, self.fetchProjects(projectID:))
      .observeForUI()
      .observeValues { [weak self] state in
        self?.similarProjectsProperty.value = state
      }
  }

  // MARK: - Data loading

  private func fetchProjects(projectID: String) -> SignalProducer<SimilarProjectsState, Never> {
    // TODO: MBL-2165
    SignalProducer(value: projectID)
      .delay(1.0, on: AppEnvironment.current.scheduler)
      .map { _ in
        .loaded(projects: [FakeProject(), FakeProject(), FakeProject(), FakeProject()])
      }
  }

  // MARK: - Inputs

  private let (projectTappedSignal, projectTappedObserver) = Signal<any SimilarProject, Never>.pipe()
  public func projectTapped(project: any SimilarProject) {
    self.projectTappedObserver.send(value: project)
  }

  private let (projectIDLoadedSignal, projectIDLoadedObserver) = Signal<String, Never>.pipe()
  public func projectIDLoaded(projectID: String) {
    self.projectIDLoadedObserver.send(value: projectID)
  }

  // MARK: - Outputs

  public let navigateToProject: Signal<any SimilarProject, Never>

  public let similarProjectsProperty = MutableProperty<SimilarProjectsState>(.loading)
  public var similarProjects: Property<SimilarProjectsState> {
    Property(self.similarProjectsProperty)
  }

  // MARK: - Type

  public var inputs: any SimilarProjectsUseCaseInputs { return self }
  public var outputs: any SimilarProjectsUseCaseOutputs { return self }
}

// MARK: - Supporting Types

private struct FakeProject: SimilarProject {
  let pid: String
  init() {
    self.pid = UUID().uuidString
  }
}
