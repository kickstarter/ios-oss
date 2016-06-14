internal final class MockTrackingClient: TrackingClientType {
  internal var tracks: [(event: String, properties: [String:AnyObject])] = []

  func track(event event: String, properties: [String: AnyObject]) {
    self.tracks.append((event: event, properties: properties))
  }

  internal var events: [String] {
    return self.tracks.map { $0.event }
  }

  internal var properties: [[String:AnyObject]] {
    return self.tracks.map { $0.properties }
  }

  internal func properties(forKey key: String) -> [String?] {
    return self.properties(forKey: key, as: String.self)
  }

  internal func properties <A> (forKey key: String, as klass: A.Type) -> [A?] {
    return self.tracks.map { $0.properties[key] as? A }
  }
}
