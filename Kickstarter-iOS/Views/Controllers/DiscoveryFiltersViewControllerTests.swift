@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import Result
import XCTest

internal final class DiscoveryFiltersViewControllerTests: TestCase {
  fileprivate let selectableRowTemplate = SelectableRow(isSelected: false, params: .defaults)

  fileprivate static let comics = .template
    |> Category.lens.id .~ 3
    <> Category.lens.name .~ "Comics"
    <> Category.lens.slug .~ "comics"
    <> Category.lens.position .~ 2

  fileprivate static let crafts = .template
    |> Category.lens.id .~ 26
    <> Category.lens.name .~ "Crafts"
    <> Category.lens.slug .~ "crafts"
    <> Category.lens.position .~ 3

  fileprivate static let dance = .template
    |> Category.lens.id .~ 6
    <> Category.lens.name .~ "Dance"
    <> Category.lens.slug .~ "dance"
    <> Category.lens.position .~ 4

  fileprivate static let design = .template
    |> Category.lens.id .~ 6
    <> Category.lens.name .~ "Design"
    <> Category.lens.slug .~ "design"
    <> Category.lens.position .~ 5

  fileprivate static let fashion = .template
    |> Category.lens.id .~ 9
    <> Category.lens.name .~ "Fashion"
    <> Category.lens.slug .~ "fashion"
    <> Category.lens.position .~ 6

  fileprivate static let ceramics = .template
    |> Category.lens.id .~ 19
    <> Category.lens.name .~ "Ceramics"
    <> Category.lens.slug .~ "art/ceramics"
    <> Category.lens.position .~ 1
    <> Category.lens.parentId .~ Category.art.id
    <> Category.lens.parent .~ Category.art

  fileprivate static let action = .template
    |> Category.lens.id .~ 27
    <> Category.lens.name .~ "Action"
    <> Category.lens.slug .~ "film-and-video/action"
    <> Category.lens.position .~ 1
    <> Category.lens.parentId .~ Category.filmAndVideo.id
    <> Category.lens.parent .~ Category.filmAndVideo

  fileprivate static let mobileGames = .template
    |> Category.lens.id .~ 31
    <> Category.lens.name .~ "Mobile Games"
    <> Category.lens.slug .~ "games/mobile-games"
    <> Category.lens.position .~ 6
    <> Category.lens.parentId .~ Category.games.id
    <> Category.lens.parent .~ Category.games

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

  func testCategoryRow_Selected_Culture_iPad_View() {
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

  func testCategoryRow_Selected_Culture_View() {
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

  func testCategoryRow_Selected_Story_View() {
    let documentarySelectableRow = selectableRowTemplate
      |> SelectableRow.lens.params.category .~ .documentary

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryFiltersViewController.configuredWith(selectedRow: documentarySelectableRow)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1000

        FBSnapshotVerifyView(parent.view, identifier: "Filters - lang_\(language)")
      }
    }
  }

  func testCategoryRow_Selected_Entertainment_View() {
    let gamesSelectableRow = selectableRowTemplate
      |> SelectableRow.lens.params.category .~ .tabletopGames

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryFiltersViewController.configuredWith(selectedRow: gamesSelectableRow)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1000

        FBSnapshotVerifyView(parent.view, identifier: "Filters - lang_\(language)")
      }
    }
  }
}
