import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

internal final class ProjectPamphletContentViewControllerConversionTests: TestCase {
  fileprivate var cosmicSurgery: Project = Project.cosmicSurgery

  override func setUp() {
    super.setUp()
    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
    let launchedAt = self.dateType.init().timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 14.0
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar..User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.dates.launchedAt .~ launchedAt
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3/4)

    self.cosmicSurgery = project

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)

    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func test_UKProject_USUser_USLocation() {
    withEnvironment(countryCode: "US") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height =  2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_US_userLocation_US")
    }
  }

  func test_UKProject_USUser_NonUSLocation() {
    withEnvironment(countryCode: "AU") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height =  2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_US_userLocation_AU")
    }
  }

  func test_USProject_USUser_USLocation() {
    cosmicSurgery = cosmicSurgery
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrencyRate .~ 1.0

    withEnvironment(countryCode: "US") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height =  2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_US_userCurrency_US_userLocation_US")
    }
  }

  func test_USProject_USUser_NonUSLocation() {
    cosmicSurgery = cosmicSurgery
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrencyRate .~ 1.0

    withEnvironment(countryCode: "CA") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height =  2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_US_userCurrency_US_userLocation_CA")
    }
  }

  func test_USProject_NonUSUser_NonUSLocation() {
    cosmicSurgery = cosmicSurgery
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrency .~ "SEK"
      |> Project.lens.stats.currentCurrencyRate .~ 3.0

    withEnvironment(countryCode: "SE") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height =  2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_US_userCurrency_SEK_userLocation_SE")
    }
  }

  func test_UKProject_UndefinedUser_USLocation() {
    cosmicSurgery = cosmicSurgery
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil

    withEnvironment(countryCode: "US") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height =  2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_nil_userLocation_US")
    }
  }

  func test_UKProject_UndefinedUser_NonUSLocation() {
    cosmicSurgery = cosmicSurgery
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil

    withEnvironment(countryCode: "CA") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height =  2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_nil_userLocation_SE")
    }
  }

  func test_UKProject_UndefinedUser_UndefinedLocation() {
    cosmicSurgery = cosmicSurgery
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil

    withEnvironment(countryCode: "XX") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height =  2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_nil_userLocation_SE")
    }
  }
}
