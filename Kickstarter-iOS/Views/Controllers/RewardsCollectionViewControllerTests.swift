@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

final class RewardsCollectionViewControllerTests: TestCase {
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

  func testRewards_NonBacker_LiveProject() {
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language, locale: .init(identifier: language.rawValue)) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .portrait, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testRewards_NonBacker_LiveProject_Landscape() {
    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language, locale: .init(identifier: language.rawValue)) {
        let vc = RewardsCollectionViewController.instantiate(
          with: project,
          refTag: nil,
          context: .createPledge
        )
        _ = traitControllers(device: device, orientation: .landscape, child: vc)

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
