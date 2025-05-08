@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class SearchViewContollerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_initialLoadingState() {
    // This is a loading page with a spinner, so just test it in one language.
    let language = Language.en

    [Device.phone4_7inch, Device.phone5_8inch, Device.pad].forEach { device in
      withEnvironment(language: Language.en) {
        let controller = Storyboard.Search.instantiate(SearchViewController.self)
        controller.viewWillAppear(true)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_loadingMoreResults() {
    // We're testing that the loading spinner is visible, no need to check translations.
    let language = Language.en

    [Device.phone4_7inch, Device.phone5_8inch, Device.pad].forEach { device in

      let searchResponse = [(
        GraphAPI.SearchQuery.self,
        GraphAPI.SearchQuery.Data.activeResults
      )]

      let controller = Storyboard.Search.instantiate(SearchViewController.self)
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

      // Load the first set of results
      withEnvironment(
        apiService: MockService(fetchGraphQLResponses: searchResponse), language: language
      ) {
        controller.viewWillAppear(true)

        self.scheduler.run()
      }

      guard let numProjects = GraphAPI.SearchQuery.Data.activeResults.projects?.nodes?.count else {
        XCTFail("Missing projects data")
        return
      }

      let lastIndex = IndexPath(row: numProjects, section: 0)

      // For some reason the scrolling is finicky on iPad, not sure why.
      let scrollPosition: UITableView.ScrollPosition = device == .pad ? .bottom : .top

      withEnvironment(apiService: MockService()) {
        // Scroll to the bottom to trigger a new load
        XCTAssertNoThrow(
          controller.tableView.scrollToRow(
            at: lastIndex,
            at: scrollPosition,
            animated: false
          )
        )

        self.scheduler.run()

        // Force a layout pass so the footer is displayed
        parent.view.layoutIfNeeded()

        // Scroll again so the footer is actually visible for the test
        XCTAssertNoThrow(
          controller.tableView.scrollToRow(
            at: lastIndex,
            at: scrollPosition,
            animated: false
          )
        )

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_defaultState() {
    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.activeResults
    )]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchGraphQLResponses: searchResponse), language: language
        ) {
          let controller = Storyboard.Search.instantiate(SearchViewController.self)
          controller.viewWillAppear(true)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.run()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_EmptyState() {
    let emptyResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.emptyResults
    )]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchGraphQLResponses: emptyResponse), language: language
        ) {
          let controller = Storyboard.Search.instantiate(SearchViewController.self)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          controller.viewModel.inputs.searchTextChanged("abcdefgh")

          self.scheduler.run()

          assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
        }
      }
  }

  func testView_SearchState() {
    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.activeResults
    )]

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchGraphQLResponses: searchResponse), language: language
        ) {
          let controller = Storyboard.Search.instantiate(SearchViewController.self)
          let _ = controller.view
          controller.viewWillAppear(true)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          controller.viewModel.inputs.searchTextChanged("abcdefgh")

          self.scheduler.run()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_PrelaunchProject_InSearch_Success() {
    let searchResponse = [(
      GraphAPI.SearchQuery.self,
      GraphAPI.SearchQuery.Data.prelaunchResults
    )]

    orthogonalCombos(Language.allLanguages, [Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchGraphQLResponses: searchResponse), language: language
        ) {
          let controller = Storyboard.Search.instantiate(SearchViewController.self)
          let _ = controller.view
          controller.viewWillAppear(true)

          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          controller.viewModel.inputs.searchTextChanged("abcdefgh")

          self.scheduler.run()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testScrollToTop() {
    let controller = ActivitiesViewController.instantiate()

    XCTAssertNotNil(controller.view as? UIScrollView)
  }
}

internal extension GraphAPI.SearchQuery.Data {
  static var emptyResults: GraphAPI.SearchQuery.Data {
    let url = Bundle(for: SearchViewContollerTests.self).url(
      forResource: "SearchQuery_EmptyResults",
      withExtension: "json"
    )
    return try! Self(fromResource: url!)
  }

  static var activeResults: GraphAPI.SearchQuery.Data {
    let url = Bundle(for: SearchViewContollerTests.self).url(
      forResource: "SearchQuery_SearchViewControllerTests_Active",
      withExtension: "json"
    )
    return try! Self(fromResource: url!)
  }

  static var prelaunchResults: GraphAPI.SearchQuery.Data {
    let url = Bundle(for: SearchViewContollerTests.self).url(
      forResource: "SearchQuery_SearchViewControllerTests_Prelaunch",
      withExtension: "json"
    )
    return try! Self(fromResource: url!)
  }
}
