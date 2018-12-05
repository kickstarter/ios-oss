import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

final class SettingsPrivacySwitchCellViewModelTests: TestCase {
  private let privacySwitchIsOn = TestObserver<Bool, NoError>()
  private let privacySwitchToggledOn = TestObserver<Bool, NoError>()

  private let vm = SettingsPrivacySwitchCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.privacySwitchIsOn.observe(privacySwitchIsOn.observer)
    self.vm.privacySwitchToggledOn.observe(privacySwitchToggledOn.observer)
  }

  func testPrivacySwitchIsOn_configuredWithUser() {
    let showPublicProfileUser = User.template
      |> UserAttribute.privacy(.showPublicProfile).keyPath .~ true
    let privateProfileUser = User.template
      |> UserAttribute.privacy(.showPublicProfile).keyPath .~ false

    self.vm.configure(with: showPublicProfileUser)

    self.privacySwitchIsOn.assertValues([false])

    self.vm.configure(with: privateProfileUser)

    self.privacySwitchIsOn.assertValues([false, true])
  }

  func testPrivacySwitch() {
    self.vm.inputs.switchToggled(on: true)

    self.privacySwitchToggledOn.assertValues([true])

    self.vm.inputs.switchToggled(on: false)

    self.privacySwitchToggledOn.assertValues([true, false])
  }
}
