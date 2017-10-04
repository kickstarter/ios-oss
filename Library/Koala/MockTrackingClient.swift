internal final class MockTrackingClient: TrackingClientType {
  internal var tracks: [(event: String, properties: [String: Any])] = []

  func track(event: String, properties: [String: Any]) {
    self.tracks.append((event: event, properties: properties))
  }

  internal var events: [String] {
    return self.tracks.map { $0.event }
  }

  internal var properties: [[String: Any]] {
    return self.tracks.map { $0.properties }
  }

  internal func properties(forKey key: String) -> [String?] {
    return self.properties(forKey: key, as: String.self)
  }

  internal func properties <A> (forKey key: String, as klass: A.Type) -> [A?] {
    return self.tracks.map { $0.properties[key] as? A }
  }
}
