import Foundation
import Library

public protocol AppEnvironmentType {
  static func logout()
}

extension AppEnvironment: AppEnvironmentType {
  public var appEnvironment: AppEnvironment {
    return self
  }
}
