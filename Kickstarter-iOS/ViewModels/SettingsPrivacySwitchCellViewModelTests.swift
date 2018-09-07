import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

final class SettingsPrivacySwitchCellViewModelTests: TestCase {
  private let privacySwitchEnabledObserver = TestObserver<Bool, NoError>()
  private let privacySwitchToggledOnObserver = TestObserver<Bool, NoError>()

  private let vm = SettingsPrivacySwitchCellViewModel()

  override func setUp() {
    super.setUp()

    self.vm.privacySwitchEnabled.observe(privacySwitchEnabledObserver.observer)
    self.vm.privacySwitchToggledOn.observe(privacySwitchToggledOnObserver.observer)
  }

  func testPrivacySwitchEnabled_configuredWithUser() {
    let showPublicProfileUser = User.template
      |> UserAttribute.privacy(.showPublicProfile).lens .~ true
    let privateProfileUser = User.template
      |> UserAttribute.privacy(.showPublicProfile).lens .~ false

    self.vm.configure(with: showPublicProfileUser)

    self.privacySwitchEnabledObserver.assertValues([false])

    self.vm.configure(with: privateProfileUser)

    self.privacySwitchEnabledObserver.assertValues([false, true])
  }

  func testPrivacySwitch() {
    self.vm.inputs.switchToggled(on: true)

    self.privacySwitchToggledOnObserver.assertValues([true])

    self.vm.inputs.switchToggled(on: false)

    self.privacySwitchToggledOnObserver.assertValues([true, false])
  }
}
