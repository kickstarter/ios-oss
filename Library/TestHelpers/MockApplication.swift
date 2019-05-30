import Foundation
import UIKit

 final class MockApplication: UIApplicationType {
  var canOpenURL = false
  var canOpenURLWasCalled = false
  var openUrlWasCalled = false

  func canOpenURL(_ url: URL) -> Bool {
    self.canOpenURLWasCalled = true
    return self.canOpenURL
  }

  // swiftlint:disable:next line_length
  func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?) {
    self.openUrlWasCalled = true
  }
}
