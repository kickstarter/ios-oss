import Foundation

public enum ProjectState: String, CaseIterable, Swift.Decodable, Equatable {
  case canceled = "CANCELED"
  case failed = "FAILED"
  case live = "LIVE"
  case purged = "PURGED"
  case started = "STARTED"
  case submitted = "SUBMITTED"
  case successful = "SUCCESSFUL"
  case suspended = "SUSPENDED"
}
