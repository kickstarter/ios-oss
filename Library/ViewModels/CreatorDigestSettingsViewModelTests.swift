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

    self.dailyDigestSelected.assertValueCount(0)
    self.individualEmailSelected.assertValueCount(0)

    self.vm.inputs.configureWith(user: user)
    self.vm.inputs.viewDidLoad()

    self.dailyDigestSelected.assertValues([false], "Daily digest toggled off.")
    self.individualEmailSelected.assertValues([true], "Daily digest toggled on.")

    self.vm.inputs.dailyDigestTapped(on: true)
    self.dailyDigestSelected.assertValues([false, true], "Daily digest toggled on after tap.")
    self.individualEmailSelected.assertValues([true, false], "Daily digest toggled off after tap.")

    self.vm.inputs.dailyDigestTapped(on: false)
    self.dailyDigestSelected.assertValues([false, true, false], "Daily digest toggled off after tap.")
    self.individualEmailSelected.assertValues([true, false, true], "Daily digest toggled on after tap." )
  }
}
