/// Represents the various states of the similar projects presentation.
public enum SimilarProjectsState {
  /// The similar projects section is hidden from view.
  case hidden

  /// The similar projects are currently being loaded .
  case loading

  /// Similar projects have been successfully loaded.
  case loaded(projects: [ProjectCardProperties])

  /// An error occurred while loading similar projects.
  case error(error: Error)
}
