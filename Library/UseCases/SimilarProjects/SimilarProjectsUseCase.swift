import Foundation
import KsApi
import ReactiveSwift

public protocol SimilarProjectsUseCaseType {
  var inputs: SimilarProjectsUseCaseInputs { get }
  var outputs: SimilarProjectsUseCaseOutputs { get }
}

public protocol SimilarProjectsUseCaseInputs {
  /// Call when a user taps on a similar project.
  /// Triggers navigation to the selected project's details.
  ///
  /// - Parameter project: The project that was tapped.
  func projectTapped(project: any SimilarProject)

  /// Call when a project ID is loaded or becomes available.
  /// Initiates fetching of similar projects for the given project ID.
  ///
  /// - Parameter projectID: The ID of the project to find similar projects for.
  func projectIDLoaded(projectID: String)
}

public protocol SimilarProjectsUseCaseOutputs {
  /// The current state of similar projects.
  var similarProjects: Property<SimilarProjectsState> { get }

  /// Signal that emits when a user has tapped on a similar project.
  /// Use this to navigate to the selected project's details.
  var navigateToProject: Signal<any SimilarProject, Never> { get }
}

/// A Use Case for fetching similar projects and navigating to them when the user taps them.
public final class SimilarProjectsUseCase: SimilarProjectsUseCaseType, SimilarProjectsUseCaseInputs,
  SimilarProjectsUseCaseOutputs {
  // MARK: - Initialization

  init() {
    self.navigateToProject = self.projectTappedSignal

    if featureSimilarProjectsCarouselEnabled() {
      self.projectIDLoadedSignal
        .flatMap(.latest, self.fetchProjects(projectID:))
        .observeForUI()
        .observeValues { [weak self] state in
          self?.similarProjectsProperty.value = state
        }
    } else {
      self.similarProjectsProperty.value = .hidden
    }
  }

  // MARK: - Data loading

  private func fetchProjects(projectID: String) -> SignalProducer<SimilarProjectsState, Never> {
    AppEnvironment.current.apiService.fetch(query: GraphAPI.FetchSimilarProjectsQuery(projectID: projectID))
      .map { response in response.projects?.nodes ?? [] }
      .map { nodes in nodes
        .compactMap { node in node?.fragments.projectCardFragment }
        .compactMap { fragment in SimilarProjectFragment(fragment) }
      }
      .map { projects in .loaded(projects: projects) }
      .flatMapError { error in
        SignalProducer(value: SimilarProjectsState.error(error: error))
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
