import Prelude
import XCTest
@testable import KsApi
@testable import Library
@testable import Kickstarter_Framework

internal final class ProjectPamphletViewControllerTests: TestCase {
  private var project: Project = .cosmicSurgery

  override func setUp() {
    super.setUp()

    self.project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ "" // prevents flaky tests caused by async photo download
      |> (Project.lens.creator.avatar..User.Avatar.lens.small) .~ ""
      |> Project.lens.rewards %~ { rewards in
        [
          rewards[0]
            |> Reward.lens.startsAt .~ 0,
          rewards[2]
            |> Reward.lens.startsAt .~ 0
        ]
      }
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (Project.template.stats.goal * 3/4)

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testNonBacker_LiveProject_NativeCheckout_Disabled() {
    let config = Config.template
      |> \.features .~ [Feature.checkout.rawValue: false]

    combos([Language.en], Device.allCases).forEach { language, device in
      withEnvironment(config: config, language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 2_300 : 1_800

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testNonBacker_LiveProject_NativeCheckout_Enabled() {
    let config = Config.template
      |> \.features .~ [Feature.checkout.rawValue: true]

    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(config: config, language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : 800

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testNonBacker_LiveProject_NativeCheckout_Enabled_Landscape() {
    let config = Config.template
      |> \.features .~ [Feature.checkout.rawValue: true]

    [Device.phone4inch, Device.phone5_5inch, Device.phone5_8inch].forEach { device in
      let language = Language.en
      withEnvironment(config: config, language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)

        let (parent, _) = traitControllers(device: device, orientation: .landscape, child: vc)
        parent.view.frame.size.height = device == .pad ? 1_200 : parent.view.frame.size.height

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testNonBacker_LiveProject_NativeCheckout_Feature_Undefined() {
    let config = Config.template
      |> \.features .~ [:]

    combos([Language.en], Device.allCases).forEach { language, device in
      withEnvironment(config: config, language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = device == .pad ? 2_300 : 1_800

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
