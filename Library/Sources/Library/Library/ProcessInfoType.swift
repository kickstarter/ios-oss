import Foundation

public protocol ProcessInfoType {
  var environment: [String: String] { get }
}

extension ProcessInfo: ProcessInfoType {}
