import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class ProjectNavBarViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
    AppEnvironment.pushEnvironment(mainBundle: NSBundle.framework)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testCategoryGroups() {

    [Category.art, Category.filmAndVideo, Category.games].forEach { category in

      let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController)
      navBar.configureWith(project: Project.lens.category.set(category, .template), refTag: nil)

      let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: navBar)
      parent.view.frame.size.height = 55

      navBar.setProjectImageIsVisible(true)
      FBSnapshotVerifyView(parent.view, identifier: "category_\(category.name)")
    }
  }

  func testWhenProjectImageIsNotVisible() {
    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController)
    navBar.configureWith(project: Project.lens.category.set(.art, .template), refTag: nil)

    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: navBar)
    parent.view.frame.size.height = 55

    navBar.setProjectImageIsVisible(false)
    FBSnapshotVerifyView(parent.view)
  }

  func testLongProjectName() {
    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController)
    let project = .template
      |> Project.lens.name .~ "This project has a quite a long name"
    navBar.configureWith(project: Project.lens.category.set(.art, project), refTag: nil)

    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: navBar)
    parent.view.frame.size.height = 55

    navBar.setProjectImageIsVisible(false)
    FBSnapshotVerifyView(parent.view)
  }

  func testStarred() {
    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController)
    navBar.configureWith(project: .template |> Project.lens.personalization.isStarred .~ true, refTag: nil)

    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: navBar)
    parent.view.frame.size.height = 55

    navBar.setProjectImageIsVisible(true)
    FBSnapshotVerifyView(parent.view)
  }

  func testLongCategoryName_SmallDevice() {
    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController)
    navBar.configureWith(
      project: .template |> Project.lens.category.name .~ "Herramientas de fabricación",
      refTag: nil
    )

    let (parent, _) = traitControllers(device: .phone4inch, orientation: .portrait, child: navBar)
    parent.view.frame.size.height = 55

    navBar.setProjectImageIsVisible(true)
    FBSnapshotVerifyView(parent.view)
  }
}
