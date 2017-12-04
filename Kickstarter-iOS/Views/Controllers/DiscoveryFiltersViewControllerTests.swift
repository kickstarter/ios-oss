@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import Result
import XCTest

internal final class DiscoveryFiltersViewControllerTests: TestCase {
  fileprivate let selectableRowTemplate = SelectableRow(isSelected: false, params: .defaults)

  fileprivate static let comics = .template
    |> Category.lens.id .~ "Q2F0ZWdvcnktMw=="
    <> Category.lens.name .~ "Comics"

  fileprivate static let crafts = .template
    |> Category.lens.id .~ "Q2F0ZWdvcnktMjY="
    <> Category.lens.name .~ "Crafts"

  fileprivate static let dance = .template
    |> Category.lens.id .~ "Q2F0ZWdvcnktNg=="
    <> Category.lens.name .~ "Dance"

  fileprivate static let design = .template
    |> Category.lens.id .~ "Q2F0ZWdvcnktNg=="
    <> Category.lens.name .~ "Design"

  fileprivate static let fashion = .template
    |> Category.lens.id .~ "Q2F0ZWdvcnktOQ=="
    <> Category.lens.name .~ "Fashion"

  fileprivate static let ceramics = .template
    |> Category.lens.id .~ "Q2F0ZWdvcnktMTk="
    <> Category.lens.name .~ "Ceramics"
    <> Category.lens.parentId .~ Category.art.id
    <> Category.lens.parent .~ ParentCategory(id: Category.art.id, name: Category.art.name)

  fileprivate static let action = .template
    |> Category.lens.id .~ "Q2F0ZWdvcnktMjc="
    <> Category.lens.name .~ "Action"
    <> Category.lens.parentId .~ Category.filmAndVideo.id
    <> Category.lens.parent .~ ParentCategory(id: Category.filmAndVideo.id, name: Category.filmAndVideo.name)

  fileprivate static let mobileGames = .template
    |> Category.lens.id .~ "Q2F0ZWdvcnktMzE="
    <> Category.lens.name .~ "Mobile Games"
    <> Category.lens.parentId .~ Category.games.id
    <> Category.lens.parent .~ ParentCategory(id: Category.games.id, name: Category.games.name)

  fileprivate let categories = [Category.art, ceramics, .illustration, comics, crafts, dance, design, fashion,
                            .filmAndVideo, action, .documentary, .games, mobileGames, .tabletopGames]

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    self.cache[KSCache.ksr_discoveryFiltersCategories] = categories
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testDefaultRow_Selected_View() {
    let staffPicksRow = selectableRowTemplate
      |> SelectableRow.lens.params.staffPicks .~ true

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryFiltersViewController.configuredWith(selectedRow: staffPicksRow)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1000

        FBSnapshotVerifyView(parent.view, identifier: "Filters - lang_\(language)")
      }
    }
  }

  func testDefaultRow_Selected_iPad_View() {
    let staffPicksRow = selectableRowTemplate
      |> SelectableRow.lens.params.staffPicks .~ true

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryFiltersViewController.configuredWith(selectedRow: staffPicksRow)
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1500

        FBSnapshotVerifyView(parent.view, identifier: "Filters - lang_\(language)")
      }
    }
  }

  func testCategoryRow_Selected_Art_iPad_View() {
    let artSelectableRow = selectableRowTemplate
      |> SelectableRow.lens.params.category .~ .illustration

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryFiltersViewController.configuredWith(selectedRow: artSelectableRow)
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1000

        FBSnapshotVerifyView(parent.view, identifier: "Filters - lang_\(language)")
      }
    }
  }

  func testCategoryRow_Selected_Art_View() {
    let artSelectableRow = selectableRowTemplate
      |> SelectableRow.lens.params.category .~ .illustration

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryFiltersViewController.configuredWith(selectedRow: artSelectableRow)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1000

        FBSnapshotVerifyView(parent.view, identifier: "Filters - lang_\(language)")
      }
    }
  }
}
