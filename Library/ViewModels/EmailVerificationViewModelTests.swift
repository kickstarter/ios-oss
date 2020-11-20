import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class EmailVerificationViewModelTests: TestCase {
  private let vm: EmailVerificationViewModelType = EmailVerificationViewModel()

  private let footerStackViewIsHidden = TestObserver<Bool, Never>()
  private let notifyDelegateDidComplete = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.footerStackViewIsHidden.observe(self.footerStackViewIsHidden.observer)
    self.vm.outputs.notifyDelegateDidComplete.observe(self.notifyDelegateDidComplete.observer)
  }

  func testFooterStackViewHidden_FeatureEnabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: true]

    withEnvironment(config: config) {
      self.footerStackViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.footerStackViewIsHidden.assertValues([false])
    }
  }

  func testFooterStackViewHidden_FeatureDisabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: false]

    withEnvironment(config: config) {
      self.footerStackViewIsHidden.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.footerStackViewIsHidden.assertValues([true])
    }
  }

  func testNotifyDelegateDidComplete() {
    self.notifyDelegateDidComplete.assertDidNotEmitValue()

    self.vm.inputs.skipButtonTapped()

    self.notifyDelegateDidComplete.assertValueCount(1)
  }
}
