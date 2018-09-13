import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

final class SettingsPrivacySwitchCellViewModelTests: TestCase {
  private let privacySwitchIsOnObserver = TestObserver<Bool, NoError>()
  private let privacySwitchToggledOnObserver = TestObserver<Bool, NoError>()

  private let vm = SettingsPrivacySwitchCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.privacySwitchIsOn.observe(privacySwitchIsOnObserver.observer)
    self.vm.privacySwitchToggledOn.observe(privacySwitchToggledOnObserver.observer)
  }

  func testPrivacySwitchIsOn_configuredWithUser() {
    let showPublicProfileUser = User.template
      |> UserAttribute.privacy(.showPublicProfile).lens .~ true
    let privateProfileUser = User.template
      |> UserAttribute.privacy(.showPublicProfile).lens .~ false

    self.vm.configure(with: showPublicProfileUser)

    self.privacySwitchIsOnObserver.assertValues([false])

    self.vm.configure(with: privateProfileUser)

    self.privacySwitchIsOnObserver.assertValues([false, true])
  }

  func testPrivacySwitch() {
    self.vm.inputs.switchToggled(on: true)

    self.privacySwitchToggledOnObserver.assertValues([true])

    self.vm.inputs.switchToggled(on: false)

    self.privacySwitchToggledOnObserver.assertValues([true, false])
  }
}
