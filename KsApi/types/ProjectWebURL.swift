public protocol HasProjectWebURL {
  var projectWebURL: String { get }
}

extension Project: HasProjectWebURL {
  public var projectWebURL: String {
    self.urls.web.project
  }
}

extension GraphAPI.ProjectFragment: HasProjectWebURL {
  public var projectWebURL: String {
    self.url
  }
}
