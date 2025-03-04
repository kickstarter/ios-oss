public enum SimilarProjectsState {
  case loading
  case loaded(projects: [any SimilarProject])
  case error(error: Error)
}
