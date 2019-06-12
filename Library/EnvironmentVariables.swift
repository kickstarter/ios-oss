import Foundation

public enum VariableName: String {
  case koalaTracking = "KOALA_TRACKING"
}

public struct EnvironmentVariables {
  private let processInfo: ProcessInfoType

  public init(processInfo: ProcessInfoType = ProcessInfo.processInfo) {
    self.processInfo = processInfo
  }
}

extension EnvironmentVariables {
  public var isKoalaTrackingEnabled: Bool {
    #if DEBUG
      guard
        let value = self.processInfo.environment[VariableName.koalaTracking.rawValue] else { return false }

      return NSString(string: value).boolValue
    #else
      return true
    #endif
  }
}
