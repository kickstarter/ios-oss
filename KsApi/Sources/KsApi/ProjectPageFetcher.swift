import ReactiveSwift

public struct ProjectPageFetcher {
  let apiService: ServiceType

  public init(withService apiService: any ServiceType) {
    self.apiService = apiService
  }

  /// A faster project page fetch.
  /// Runs two parallel fetches - one for basic project properties, and another for extras like the project story.
  /// The queries were originally split down that line so that we could implement a progressive page load,
  /// but that ended up not being worth the extra complexity.
  public func fastFetchProjectPage(
    projectParam param: Param,
    includeStoryRichText: Bool
  ) -> SignalProducer<Project, ErrorEnvelope> {
    let baseFetch = self.apiService
      .fastFetchProjectPageBase(projectParam: param)
    let extraFetch = self.apiService
      .fastFetchProjectPageExtendedProperties(projectParam: param, includeStoryRichText: includeStoryRichText)

    return SignalProducer.zip(
      baseFetch,
      extraFetch
    ).map { project, extraProperties in
      extraProperties.addExtraProperties(toProject: project)
    }
  }
}
