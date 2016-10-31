import Foundation

public protocol DateProtocol {
  var date: NSDate { get }
  func dateByAddingTimeInterval(_: NSTimeInterval) -> Self
  init()
  init(timeIntervalSince1970: NSTimeInterval)
  var timeIntervalSince1970: NSTimeInterval { get }
}

extension NSDate: DateProtocol {
  public var date: NSDate {
    return self
  }
}

internal struct MockDate: DateProtocol {
  private let time: NSTimeInterval

  internal init() {
    self.time = 1475361315
  }

  internal init(timeIntervalSince1970 time: NSTimeInterval) {
    self.time = time
  }

  internal var timeIntervalSince1970: NSTimeInterval {
    return self.time
  }

  internal var date: NSDate {
    return NSDate(timeIntervalSince1970: self.time)
  }

  internal func dateByAddingTimeInterval(interval: NSTimeInterval) -> MockDate {
    return MockDate(timeIntervalSince1970: self.time + interval)
  }
}
