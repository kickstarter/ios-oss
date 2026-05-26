import KsApi

extension VideoFeedItem: HasProjectCreatorProperties {
  public var projectCreatorProperties: ProjectCreatorProperties {
    ProjectCreatorProperties(
      id: self.pid,
      name: self.title,
      projectWebURL: self.projectURL
    )
  }
}

extension VideoFeedItem: HasProjectWebURL {
  public var projectWebURL: String { self.projectURL }
}
