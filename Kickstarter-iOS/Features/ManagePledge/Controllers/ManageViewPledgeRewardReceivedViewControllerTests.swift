@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class ManageViewPledgeRewardReceivedViewControllerTests: TestCase {
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

  func testView_Toggle_Off() {
    let data = ManageViewPledgeRewardReceivedViewData(
      project: .template,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .collected,
      estimatedShipping: nil
    )

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    orthogonalCombos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.configureWith(data: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 80

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_Toggle_On() {
    let data = ManageViewPledgeRewardReceivedViewData(
      project: .template,
      backerCompleted: true,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .collected,
      estimatedShipping: nil
    )

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    orthogonalCombos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.configureWith(data: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 80

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testEstimatedShipping_NoToggle() {
    let data = ManageViewPledgeRewardReceivedViewData(
      project: .template,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .pledged,
      estimatedShipping: "About $3-$5"
    )

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.noShippingAtCheckout.rawValue: true
    ]
    orthogonalCombos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language, remoteConfigClient: mockConfigClient) {
        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.configureWith(data: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 60

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testEstimatedShipping_Toggle() {
    let data = ManageViewPledgeRewardReceivedViewData(
      project: .template,
      backerCompleted: false,
      estimatedDeliveryOn: 1_475_361_315,
      backingState: .collected,
      estimatedShipping: "About $10-$100"
    )

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.noShippingAtCheckout.rawValue: true
    ]
    orthogonalCombos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language, remoteConfigClient: mockConfigClient) {
        let controller = ManageViewPledgeRewardReceivedViewController.instantiate()
        controller.configureWith(data: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 110

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
