import Library

internal final class MockTrackingClient: TrackingClientType {
  internal var tracks: [(event: String, properties: [String: Any])] = []
  internal var screens: [(title: String, properties: [String: Any])] = []
  internal var userId: String?
  internal var traits: [String: Any]?

  func track(_ event: String, properties: [String: Any]?) {
    self.tracks.append((event: event, properties: properties ?? [:]))
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

extension MockTrackingClient: IdentifyingTrackingClient {
  func identify(_ userId: String?, traits: [String: Any]?) {
    self.userId = userId
    self.traits = traits
  }

  func reset() {
    self.userId = nil
    self.traits = nil
  }
}
