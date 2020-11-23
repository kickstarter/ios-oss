import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class EmailVerificationViewModelTests: TestCase {
  private let vm: EmailVerificationViewModelType = EmailVerificationViewModel()

  private let notifyDelegateDidComplete = TestObserver<(), Never>()
  private let skipButtonHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateDidComplete.observe(self.notifyDelegateDidComplete.observer)
    self.vm.outputs.skipButtonHidden.observe(self.skipButtonHidden.observer)
  }

  func testSkipButtonHidden_FeatureEnabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: true]

    withEnvironment(config: config) {
      self.skipButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.skipButtonHidden.assertValues([false])
    }
  }

  func testSkipButtonHidden_FeatureDisabled() {
    let config = .template
      |> Config.lens.features .~ [Feature.emailVerificationSkip.rawValue: false]

    withEnvironment(config: config) {
      self.skipButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.skipButtonHidden.assertValues([true])
    }
  }

  func testNotifyDelegateDidComplete() {
    self.notifyDelegateDidComplete.assertDidNotEmitValue()

    self.vm.inputs.skipButtonTapped()

    self.notifyDelegateDidComplete.assertValueCount(1)
  }
}
