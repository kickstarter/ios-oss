// swiftlint:disable type_name
import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class ProjectPamphletContentViewControllerTests: TestCase {
  private let cosmicSurgery = Project.cosmicSurgery
    |> Project.lens.photo.full .~ ""
    |> (Project.lens.creator.avatar • User.Avatar.lens.small) .~ ""

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(
      config: .template |> Config.lens.countryCode .~ self.cosmicSurgery.country.countryCode,
      mainBundle: NSBundle.framework
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testAllCategoryGroups() {
    let project = self.cosmicSurgery
      |> Project.lens.rewards .~ [self.cosmicSurgery.rewards.first!]
      |> Project.lens.state .~ .live

    [Category.art, Category.filmAndVideo, Category.games].forEach { category in
      let categorizedProject = project |> Project.lens.category .~ category
      let vc = ProjectPamphletViewController.configuredWith(
        projectOrParam: .left(categorizedProject), refTag: nil
      )
      let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
      parent.view.frame.size.height = 1_000

      FBSnapshotVerifyView(vc.view, identifier: "category_\(category.slug)")
    }
  }

  func testNonBacker_LiveProject() {
    let project = self.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ self.cosmicSurgery.stats.goal * 3/4

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 2_200

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }

  func testNonBacker_SuccessfulProject() {
    let project = self.cosmicSurgery
      |> Project.lens.state .~ .successful

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 1_750

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }

  func testBacker_LiveProject() {
    let project = self.cosmicSurgery
      |> Project.lens.rewards %~ { rewards in [rewards[0], rewards[2]] }
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ self.cosmicSurgery.stats.goal * 3/4
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing %~~ { _, project in
        .template
          |> Backing.lens.rewardId .~ project.rewards.first?.id
          |> Backing.lens.reward .~ project.rewards.first
    }

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {

        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 1_350

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }

  func testBacker_SuccessfulProject() {
    let project = self.cosmicSurgery
      |> Project.lens.rewards %~ { rewards in [rewards[0], rewards[2]] }
      |> Project.lens.dates.stateChangedAt .~ 1234567890.0
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing %~~ { _, project in
        .template
          |> Backing.lens.rewardId .~ project.rewards.first?.id
          |> Backing.lens.reward .~ project.rewards.first
    }

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {

        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 1_300

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }

  func testBackerOfSoldOutReward() {
    let soldOutReward = self.cosmicSurgery.rewards.filter { $0.remaining == 0 }.first!
    let project = self.cosmicSurgery
      |> Project.lens.rewards .~ [soldOutReward]
      |> Project.lens.state .~ .live
      |> Project.lens.stats.pledged .~ self.cosmicSurgery.stats.goal * 3/4
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing %~~ { _, project in
        .template
          |> Backing.lens.rewardId .~ project.rewards.first?.id
          |> Backing.lens.reward .~ project.rewards.first
    }

    let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    parent.view.frame.size.height = 1_000

    FBSnapshotVerifyView(vc.view)
  }

  func testFailedProject() {
    let project = self.cosmicSurgery
      |> Project.lens.dates.stateChangedAt .~ 1234567890.0
      |> Project.lens.state .~ .failed

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 1_700

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)")
      }
    }
  }
}
