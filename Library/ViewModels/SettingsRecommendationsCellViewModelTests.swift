import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsRecommendationsCellViewModelTests: TestCase {
  internal let vm = SettingsRecommendationsCellViewModel()
  internal let recommendationsOn = TestObserver<Bool, NoError>()
  internal let unableToSaveError = TestObserver<String, NoError>()
  internal let updateCurrentUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.recommendationsOn.observe(self.recommendationsOn.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testOpOutOfRecommendations() {
    let user = User.template
    self.vm.inputs.configureWith(user: user)
    self.recommendationsOn.assertValues([true])
    self.vm.inputs.recommendationsTapped(on: false)
    self.recommendationsOn.assertValues([true, false])
  }

  func testUpdateUser() {
    let user = User.template
    self.vm.inputs.configureWith(user: user)
    self.updateCurrentUser.assertValueCount(1)
    self.vm.inputs.recommendationsTapped(on: true)
    self.updateCurrentUser.assertValueCount(2)
    self.vm.inputs.recommendationsTapped(on: true)
    self.updateCurrentUser.assertValueCount(3)
  }

  func testUnableToSaveError() {
    let error = ErrorEnvelope(
      errorMessages: ["Unable to save."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(updateUserSelfError: error)) {
      let user = User.template
      self.vm.inputs.configureWith(user: user)

      self.recommendationsOn.assertValues([true], "Recommendations turned on as default.")

      self.vm.inputs.recommendationsTapped(on: false)

      self.recommendationsOn.assertValues([true, false], "Recommendations immediately turned off on tap.")

      self.scheduler.advance()

      self.unableToSaveError.assertValueCount(1, "Updating user errored.")
      self.recommendationsOn.assertValues([true, false, true], "Did not successfully save preference.")
    }
  }
}
