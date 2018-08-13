import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class SettingsPrivacyViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    let currentUser = User.template
    let exportData = .template
      |> ExportDataEnvelope.lens.expiresAt .~ nil
      |> ExportDataEnvelope.lens.state .~ .expired
      |> ExportDataEnvelope.lens.dataUrl .~ nil

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: MockService(fetchExportStateResponse: exportData),
                      currentUser: currentUser,
                      language: language) {
        let vc = Storyboard.SettingsPrivacy.instantiate(SettingsPrivacyViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        vc.viewModel.inputs.viewDidLoad()
        self.scheduler.advance()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
