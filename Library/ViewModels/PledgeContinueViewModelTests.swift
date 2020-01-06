@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeContinueViewModelTests: TestCase {
  private let vm = PledgeContinueViewModel()

  private let goToLoginSignupIntent = TestObserver<LoginIntent, Never>()
  private let goToLoginSignupProject = TestObserver<Project, Never>()
  private let goToLoginSignupReward = TestObserver<Reward, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToLoginSignup.map(first).observe(self.goToLoginSignupIntent.observer)
    self.vm.outputs.goToLoginSignup.map(second).observe(self.goToLoginSignupProject.observer)
    self.vm.outputs.goToLoginSignup.map(third).observe(self.goToLoginSignupReward.observer)
  }

  func testGoToLoginSignup() {
    self.goToLoginSignupIntent.assertDidNotEmitValue()
    self.goToLoginSignupProject.assertDidNotEmitValue()
    self.goToLoginSignupReward.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (Project.template, Reward.template))

    self.goToLoginSignupIntent.assertDidNotEmitValue()
    self.goToLoginSignupProject.assertDidNotEmitValue()
    self.goToLoginSignupReward.assertDidNotEmitValue()

    self.vm.inputs.continueButtonTapped()

    self.goToLoginSignupIntent.assertValues([LoginIntent.backProject])
    self.goToLoginSignupProject.assertValues([.template])
    self.goToLoginSignupReward.assertValues([.template])

    self.vm.inputs.continueButtonTapped()

    self.goToLoginSignupIntent.assertValueCount(2)
    self.goToLoginSignupProject.assertValueCount(2)
    self.goToLoginSignupReward.assertValueCount(2)
  }
}
