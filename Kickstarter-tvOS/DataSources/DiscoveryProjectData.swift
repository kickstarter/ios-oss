import Models

/// Data model for use with the DiscoverySectionDataSource. It models
/// the state of having an actual project to render or still waiting
/// for data to load.
enum DiscoveryProjectData {
  case Project(Models.Project)
  case Loading

  var project: Models.Project? {
    switch self {
    case let .Project(project):
      return project
    case .Loading:
      return nil
    }
  }

  var isProject: Bool {
    switch self {
    case .Loading: return false
    case .Project: return true
    }
  }

  var isLoading: Bool {
    return !isProject
  }
}

extension DiscoveryProjectData: Equatable {
}
func == (lhs: DiscoveryProjectData, rhs: DiscoveryProjectData) -> Bool {
  switch (lhs, rhs) {
  case (.Loading, .Loading):
    return true
  case let (.Project(lhs), .Project(rhs)):
    return lhs == rhs
  case (.Loading, .Project), (.Project, .Loading):
    return false
  }
}
