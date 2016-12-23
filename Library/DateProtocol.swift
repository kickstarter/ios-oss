import Foundation

public protocol DateProtocol {
  var date: Date { get }
  func addingTimeInterval(_: TimeInterval) -> Self
  init()
  init(timeIntervalSince1970: TimeInterval)
  var timeIntervalSince1970: TimeInterval { get }
}

extension Date: DateProtocol {
  public var date: Date {
    return self
  }
}

internal struct MockDate: DateProtocol {
  private let time: TimeInterval

  internal init() {
    self.time = 1475361315
  }

  internal init(timeIntervalSince1970 time: TimeInterval) {
    self.time = time
  }

  internal var timeIntervalSince1970: TimeInterval {
    return self.time
  }

  internal var date: Date {
    return Date(timeIntervalSince1970: self.time)
  }

  internal func addingTimeInterval(_ interval: TimeInterval) -> MockDate {
    return MockDate(timeIntervalSince1970: self.time + interval)
  }
}
