@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class LandingPageViewModelTests: TestCase {
  fileprivate let vm: LandingPageViewModelType = LandingPageViewModel()

  fileprivate let landingPageCards = TestObserver<[UIView], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.landingPageCards.observe(self.landingPageCards.observer)
  }
}
