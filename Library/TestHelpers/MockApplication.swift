import Foundation
import Library
import UIKit

final class MockApplication: UIApplicationType {
  var applicationIconBadgeNumber = 0
  var canOpenURL = false
  var canOpenURLWasCalled = false
  var openUrlWasCalled = false

  func canOpenURL(_: URL) -> Bool {
    self.canOpenURLWasCalled = true
    return self.canOpenURL
  }

  func open(
    _: URL,
    options _: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler _: ((Bool) -> Void)?
  ) {
    self.openUrlWasCalled = true
  }
}
