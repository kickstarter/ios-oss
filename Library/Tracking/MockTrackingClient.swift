import Library

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

  internal func properties<A>(forKey key: String, as _: A.Type) -> [A?] {
    return self.tracks.map { $0.properties[key] as? A }
  }

  internal func containsKeyPrefix(_ prefix: String) -> Bool {
    for key in self.properties.map(\.keys).flatMap({ $0 }) where key.hasPrefix(prefix) { return true }

    return false
  }
}
