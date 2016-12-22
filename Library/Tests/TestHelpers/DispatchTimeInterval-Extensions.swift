import Foundation

extension DispatchTimeInterval {

  public func scale(by scale: Float) -> DispatchTimeInterval {
    switch self {
    case let .seconds(interval):
      return .milliseconds(Float(interval * 1_000) * scale)
    case let .milliseconds(interval):
      return .microseconds(Float(interval * 1_000) * scale)
    case let .microseconds(interval):
      return .nanoseconds(Float(interval * 1_000) * scale)
    case let .nanoseconds(interval):
      return .nanoseconds(Float(interval) * scale)
    }
  }

  public func halved() -> DispatchTimeInterval {
    return self.scale(by: 0.5)
  }

  fileprivate var nanoseconds: UInt64 {
    switch self {
    case .seconds(let s):
      return Int64(s) * Int64(NSEC_PER_SEC)
    case .milliseconds(let ms):
      return Int64(ms) * Int64(NSEC_PER_MSEC)
    case .microseconds(let us):
      return Int64(us) * Int64(NSEC_PER_USEC)
    case .nanoseconds(let ns):
      return Int64(ns)
    }
  }
}

public func + (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> DispatchTimeInterval {
  return .nanoseconds(lhs.nanoseconds + rhs.nanoseconds)
}
