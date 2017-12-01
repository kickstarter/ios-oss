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
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testCategory() {

    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController.self)
    navBar.configureWith(
      project: Project.lens.category.set(Category.art, .template), refTag: nil
    )

    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: navBar)
    parent.view.frame.size.height = 55

    navBar.setProjectImageIsVisible(true)
    FBSnapshotVerifyView(parent.view, identifier: "category_Art")
  }

  func testWhenProjectImageIsNotVisible() {
    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController.self)
    navBar.configureWith(project: Project.lens.category.set(.art, .template), refTag: nil)

    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: navBar)
    parent.view.frame.size.height = 55

    navBar.setProjectImageIsVisible(false)
    FBSnapshotVerifyView(parent.view)
  }

  func testLongProjectName() {
    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController.self)
    let project = .template
      |> Project.lens.name .~ "This project has a quite a long name"
    navBar.configureWith(project: Project.lens.category.set(.art, project), refTag: nil)

    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: navBar)
    parent.view.frame.size.height = 55

    navBar.setProjectImageIsVisible(false)
    FBSnapshotVerifyView(parent.view)
  }

  func testStarred() {
    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController.self)
    navBar.configureWith(project: .template |> Project.lens.personalization.isStarred .~ true, refTag: nil)

    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: navBar)
    parent.view.frame.size.height = 55

    navBar.setProjectImageIsVisible(true)
    FBSnapshotVerifyView(parent.view)
  }

  func testLongCategoryName_SmallDevice() {
    let navBar = Storyboard.ProjectPamphlet.instantiate(ProjectNavBarViewController.self)
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
