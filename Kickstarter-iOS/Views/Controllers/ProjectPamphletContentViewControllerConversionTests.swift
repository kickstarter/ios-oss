@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectPamphletContentViewControllerConversionTests: TestCase {
  fileprivate var cosmicSurgery: Project = Project.cosmicSurgery

  override func setUp() {
    super.setUp()
    let deadline = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0
    let launchedAt = self.dateType.init().timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 14.0
    let project = Project.cosmicSurgery
      |> Project.lens.photo.full .~ ""
      |> (Project.lens.creator.avatar .. User.Avatar.lens.small) .~ ""
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.dates.launchedAt .~ launchedAt
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ (self.cosmicSurgery.stats.goal * 3 / 4)
      |> Project.lens.stats.convertedPledgedAmount .~ 21_615

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
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_US_userLocation_US")
    }
  }

  func test_UKProject_USUser_NonUSLocation() {
    withEnvironment(countryCode: "AU") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_US_userLocation_AU")
    }
  }

  func test_USProject_USUser_USLocation() {
    self.cosmicSurgery = self.cosmicSurgery
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrencyRate .~ 1.0

    withEnvironment(countryCode: "US") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_US_userCurrency_US_userLocation_US")
    }
  }

  func test_USProject_USUser_NonUSLocation() {
    self.cosmicSurgery = self.cosmicSurgery
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrencyRate .~ 1.0

    withEnvironment(countryCode: "CA") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_US_userCurrency_US_userLocation_CA")
    }
  }

  func test_USProject_USUser_NonUSLocation_Backer() {
    let deadline = self.dateType.init().addingTimeInterval(-100).timeIntervalSince1970
    let backing = .template
      // swiftlint:disable:next force_unwrapping
      |> Backing.lens.amount .~ (self.cosmicSurgery.rewards.first!.minimum + 5.00)
      |> Backing.lens.rewardId .~ self.cosmicSurgery.rewards.first?.id
      |> Backing.lens.reward .~ self.cosmicSurgery.rewards.first

    self.cosmicSurgery = self.cosmicSurgery
      |> Project.lens.rewards %~ { rewards in [rewards[0], rewards[2]] }
      |> Project.lens.dates.stateChangedAt .~ deadline
      |> Project.lens.dates.deadline .~ deadline
      |> Project.lens.state .~ .successful
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrencyRate .~ 1.0
      |> Project.lens.personalization.backing .~ backing

    withEnvironment(countryCode: "CA") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_US_userCurrency_US_userLocation_CA")
    }
  }

  func test_USProject_NonUSUser_NonUSLocation() {
    let rewards = self.cosmicSurgery.rewards
      .map { $0 |> Reward.lens.convertedMinimum .~ ($0.minimum * 3.0) }

    self.cosmicSurgery = self.cosmicSurgery
      |> Project.lens.rewards .~ rewards
      |> Project.lens.country .~ .us
      |> Project.lens.stats.currency .~ "USD"
      |> Project.lens.stats.currentCurrency .~ "SEK"
      |> Project.lens.stats.currentCurrencyRate .~ 3.0
      |> Project.lens.stats.convertedPledgedAmount .~ 49_500

    withEnvironment(countryCode: "SE") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_US_userCurrency_SEK_userLocation_SE")
    }
  }

  func test_UKProject_UndefinedUser_USLocation() {
    self.cosmicSurgery = self.cosmicSurgery
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil

    withEnvironment(countryCode: "US") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_nil_userLocation_US")
    }
  }

  func test_UKProject_UndefinedUser_NonUSLocation() {
    self.cosmicSurgery = self.cosmicSurgery
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil

    withEnvironment(countryCode: "CA") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_nil_userLocation_SE")
    }
  }

  func test_UKProject_UndefinedUser_UndefinedLocation() {
    self.cosmicSurgery = self.cosmicSurgery
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.currency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil

    withEnvironment(countryCode: "XX") {
      let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(cosmicSurgery), refTag: nil)
      let (parent, _) = traitControllers(device: Device.phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 2_200

      FBSnapshotVerifyView(vc.view, identifier: "projectLocation_UK_userCurrency_nil_userLocation_SE")
    }
  }
}
