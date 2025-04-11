public protocol HasProjectWebURL {
  var serviceProjectWebURL: String { get }
}

extension Project: HasProjectWebURL {
  public var serviceProjectWebURL: String {
    self.urls.web.project
  }
}

extension GraphAPI.ProjectFragment: HasProjectWebURL {
  public var serviceProjectWebURL: String {
    self.url
  }
}
