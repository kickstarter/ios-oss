@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class SettingsPrivacySwitchCellViewModelTests: TestCase {
  private let privacySwitchIsOn = TestObserver<Bool, Never>()
  private let privacySwitchToggledOn = TestObserver<Bool, Never>()

  private let vm = SettingsPrivacySwitchCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.privacySwitchIsOn.observe(self.privacySwitchIsOn.observer)
    self.vm.privacySwitchToggledOn.observe(self.privacySwitchToggledOn.observer)
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
