@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class TwoFactorViewControllerTests: TestCase {
  func testView() {
    orthogonalCombos(
      Language.allLanguages,
      [Device.phone4_7inch, Device.phone5_8inch, Device.pad],
      [true, false]
    ).forEach {
      language, device, useNewDesignSystem in

      let remoteConfig = MockRemoteConfigClient()
      remoteConfig.features = [
        RemoteConfigFeature.newDesignSystem.rawValue: useNewDesignSystem
      ]

      withEnvironment(language: language, remoteConfigClient: remoteConfig) {
        let controller = Storyboard.Login.instantiate(TwoFactorViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "lang_\(language)_device_\(device)_newDesignSystem_\(useNewDesignSystem)"
        )
      }
    }
  }
}
