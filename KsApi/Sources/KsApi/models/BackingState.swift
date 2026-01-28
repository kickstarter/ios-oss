import Foundation

public enum BackingState: String, CaseIterable, Decodable, Equatable {
  case canceled
  case collected
  case dropped
  case errored
  case pledged
  case preauth
}
