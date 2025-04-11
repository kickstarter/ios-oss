public protocol HasServiceProjectWebURL {
  var serviceProjectWebURL: String { get }
}

extension Project: HasServiceProjectWebURL {
  public var serviceProjectWebURL: String {
    self.urls.web.project
  }
}

extension GraphAPI.ProjectFragment: HasServiceProjectWebURL {
  public var serviceProjectWebURL: String {
    self.url
  }
}
