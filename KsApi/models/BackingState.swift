import Foundation

public enum BackingState: String, CaseIterable, Swift.Decodable {
  case canceled
  case collected
  case dropped
  case errored
  case pledged
  case preauth
}
