import Foundation

public enum VariableName: String {
  case trackingEnabled = "TRACKING_ENABLED"
}

public struct EnvironmentVariables {
  private let processInfo: ProcessInfoType

  public init(processInfo: ProcessInfoType = ProcessInfo.processInfo) {
    self.processInfo = processInfo
  }
}

extension EnvironmentVariables {
  public var isTrackingEnabled: Bool {
    #if DEBUG
      guard let value = self.processInfo.environment[VariableName.trackingEnabled.rawValue] else {
        return false
      }

      return NSString(string: value).boolValue
    #else
      return true
    #endif
  }
}
