import Foundation

public protocol ApiDateProtocol {
  var date: Date { get }
  func addingTimeInterval(_: TimeInterval) -> Self
  init()
  init(timeIntervalSince1970: TimeInterval)
  init(timeIntervalSinceNow: TimeInterval)
  var timeIntervalSince1970: TimeInterval { get }
}

extension Date: ApiDateProtocol {
  public var date: Date {
    return self
  }
}

internal struct ApiMockDate: ApiDateProtocol {
  private let time: TimeInterval

  internal init() {
    self.time = 1_475_361_315
  }

  internal init(timeIntervalSince1970 time: TimeInterval) {
    self.time = time
  }

  internal init(timeIntervalSinceNow time: TimeInterval) {
    self.time = time
  }

  internal var timeIntervalSince1970: TimeInterval {
    return self.time
  }

  internal var date: Date {
    return Date(timeIntervalSince1970: self.time)
  }

  internal func addingTimeInterval(_ interval: TimeInterval) -> ApiMockDate {
    return ApiMockDate(timeIntervalSince1970: self.time + interval)
  }
}
