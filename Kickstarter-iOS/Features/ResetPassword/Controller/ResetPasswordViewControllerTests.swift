import Foundation
@testable import Kickstarter_Framework
import Library
import SnapshotTesting

internal final class ResetPasswordViewControllerTests: TestCase {
  func testView() {
    orthogonalCombos(
      Language.allLanguages,
      [Device.pad, Device.phone4_7inch, Device.phone5_8inch],
      [true, false]
    ).forEach {
      language, device, useNewDesignSystem in

      let remoteConfig = MockRemoteConfigClient()
      remoteConfig.features = [
        RemoteConfigFeature.newDesignSystem.rawValue: useNewDesignSystem
      ]

      withEnvironment(language: language, remoteConfigClient: remoteConfig) {
        let controller = ResetPasswordViewController
          .configuredWith(email: "americasnexttopmodulus@example.com")
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image,
          named: "lang_\(language)_device_\(device)_useNewDesignSystem_\(useNewDesignSystem)"
        )
      }
    }
  }
}
