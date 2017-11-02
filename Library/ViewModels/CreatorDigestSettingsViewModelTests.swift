import Foundation
import XCTest
import ReactiveSwift
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class CreatorDigestSettingsViewModelTests: TestCase {
  let vm = CreatorDigestSettingsViewModel()

  let dailyDigestSelected = TestObserver<Bool, NoError>()
  let individualEmailSelected = TestObserver<Bool, NoError>()
  let unableToSaveError = TestObserver<String, NoError>()
  let updateCurrentUser = TestObserver<User, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.dailyDigestSelected.observe(self.dailyDigestSelected.observer)
    self.vm.outputs.individualEmailSelected.observe(self.individualEmailSelected.observer)
    self.vm.outputs.unableToSaveError.observe(self.unableToSaveError.observer)
    self.vm.outputs.updateCurrentUser.observe(self.updateCurrentUser.observer)
  }

  func testDailyDigestToggle() {
    let user = User.template
    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

    self.vm.inputs.viewDidLoad()

    self.dailyDigestSelected.assertValues([false])
    self.individualEmailSelected.assertValues([false])

    self.vm.inputs.dailyDigestTapped(on: true)
    self.dailyDigestSelected.assertValues([false, true], "Daily digest toggled on.")
    self.individualEmailSelected.assertValues([false, false], "Daily digest toggled off.")

    self.vm.inputs.dailyDigestTapped(on: false)
    self.dailyDigestSelected.assertValues([false, true, false], "Daily digest toggled off.")
    self.individualEmailSelected.assertValues([false, false, true], "Daily digest toggled on." )
  }

}
