@testable import Kickstarter_Framework
import KsApi
import Library
import XCTest

class SearchDataSourceTests: XCTestCase {
  func test_indexOfProject_withTitleRow_returnsCorrectProjectIndex() {
    let datasource = SearchDataSource()

    datasource.load(projects: threeTestProjects, withDiscoverTitle: true)

    XCTAssertEqual(
      datasource.numberOfItems(in: projectsSection),
      4,
      "Adding title row should add additional item to the top of the projects"
    )

    XCTAssertEqual(
      datasource.numberOfItems(),
      4,
      "Datasource should have a total of 4 items - three projects and a title"
    )

    XCTAssertTrue(
      datasource[IndexPath(row: 0, section: projectsSection)] is Void,
      "First value in the data source should be a title row"
    )

    XCTAssertTrue(
      datasource[IndexPath(row: 1, section: projectsSection)] is TestProject,
      "Second value in the data source should be a project"
    )

    XCTAssertTrue(
      datasource[IndexPath(row: 2, section: projectsSection)] is TestProject,
      "Third value in the data source should be a project"
    )

    XCTAssertTrue(
      datasource[IndexPath(row: 3, section: projectsSection)] is TestProject,
      "Fourth value in the data source should be a project"
    )

    XCTAssertNil(
      datasource.indexOfProject(forCellAtIndexPath: IndexPath(row: 0, section: projectsSection)),
      "Tapping on title row should return nil index"
    )

    if let index = datasource.indexOfProject(forCellAtIndexPath: IndexPath(
      row: 1,
      section: projectsSection
    )) {
      let tappedProject = threeTestProjects[index]
      XCTAssertEqual(tappedProject, threeTestProjects[0], "Tapping on second row should return first project")
    } else {
      XCTFail("Expected value for index")
    }

    if let index = datasource.indexOfProject(forCellAtIndexPath: IndexPath(
      row: 2,
      section: projectsSection
    )) {
      let tappedProject = threeTestProjects[index]
      XCTAssertEqual(
        tappedProject,
        threeTestProjects[1],
        "Tapping on second row should return second project"
      )
    } else {
      XCTFail("Expected value for index")
    }

    if let index = datasource.indexOfProject(forCellAtIndexPath: IndexPath(
      row: 3,
      section: projectsSection
    )) {
      let tappedProject = threeTestProjects[index]
      XCTAssertEqual(tappedProject, threeTestProjects[2], "Tapping on last row should return last project")
    } else {
      XCTFail("Expected value for index")
    }

    XCTAssertNil(
      datasource.indexOfProject(forCellAtIndexPath: IndexPath(row: 4, section: projectsSection)),
      "Requesting index for out-of-bounds project should return nil"
    )
  }

  func test_indexOfProject_withoutTitleRow_returnsCorrectProjectIndex() {
    let datasource = SearchDataSource()

    datasource.load(projects: threeTestProjects, withDiscoverTitle: false)

    XCTAssertEqual(
      datasource.numberOfItems(in: projectsSection),
      3,
      "When no title row is set, number of items should equal the number of projects"
    )

    XCTAssertEqual(
      datasource.numberOfItems(),
      3,
      "Datasource should have a total of 3 items - three projects"
    )

    XCTAssertTrue(
      datasource[IndexPath(row: 0, section: projectsSection)] is TestProject,
      "First value in the data source should be a project"
    )

    XCTAssertTrue(
      datasource[IndexPath(row: 1, section: projectsSection)] is TestProject,
      "Second value in the data source should be a project"
    )

    XCTAssertTrue(
      datasource[IndexPath(row: 2, section: projectsSection)] is TestProject,
      "Third value in the data source should be a project"
    )

    if let index = datasource.indexOfProject(forCellAtIndexPath: IndexPath(
      row: 0,
      section: projectsSection
    )) {
      let tappedProject = threeTestProjects[index]
      XCTAssertEqual(tappedProject, threeTestProjects[0], "Tapping on first row should return first project")
    } else {
      XCTFail("Expected value for index")
    }

    if let index = datasource.indexOfProject(forCellAtIndexPath: IndexPath(
      row: 1,
      section: projectsSection
    )) {
      let tappedProject = threeTestProjects[index]
      XCTAssertEqual(
        tappedProject,
        threeTestProjects[1],
        "Tapping on second row should return second project"
      )
    } else {
      XCTFail("Expected value for index")
    }

    if let index = datasource.indexOfProject(forCellAtIndexPath: IndexPath(
      row: 2,
      section: projectsSection
    )) {
      let tappedProject = threeTestProjects[index]
      XCTAssertEqual(tappedProject, threeTestProjects[2], "Tapping on last row should return last project")
    } else {
      XCTFail("Expected value for index")
    }

    XCTAssertNil(
      datasource.indexOfProject(forCellAtIndexPath: IndexPath(row: 3, section: projectsSection)),
      "Requesting index for out-of-bounds project should return nil"
    )
  }

  func test_indexOfProject_withEmptyState_returnsNil() {
    let datasource = SearchDataSource()

    datasource.load(params: DiscoveryParams.defaults, visible: true)

    XCTAssertEqual(
      datasource.numberOfItems(in: projectsSection),
      0,
      "No projects should be visible in empty state"
    )
    XCTAssertEqual(
      datasource.numberOfItems(in: emptySection),
      1,
      "Adding visible empty state should have one item displayed"
    )

    XCTAssertTrue(
      datasource[IndexPath(row: 0, section: emptySection)] is DiscoveryParams,
      "First value in the empty section should be a DiscoveryParams"
    )

    XCTAssertNil(
      datasource.indexOfProject(forCellAtIndexPath: IndexPath(row: 0, section: emptySection)),
      "Tapping on empty state should return no project index"
    )

    XCTAssertNil(
      datasource.indexOfProject(forCellAtIndexPath: IndexPath(row: 0, section: projectsSection)),
      "Trying to tap on a project when the data source is in the empty state should return no project index"
    )
  }
}

struct TestProject: BackerDashboardProjectCellViewModel.ProjectCellModel, Equatable {
  let name: String
  let state: KsApi.Project.State
  var fundingProgress: Float
  let percentFunded: Int

  let imageURL: String? = nil
  let displayPrelaunch: Bool? = false
  let prelaunchActivated: Bool? = false
  let launchedAt: TimeInterval? = nil
  let deadline: TimeInterval? = nil
  let isStarred: Bool? = false
}

let threeTestProjects = [
  TestProject(
    name: "Test Project One",
    state: .live,
    fundingProgress: 0.5,
    percentFunded: 50
  ),
  TestProject(
    name: "Test Project Two",
    state: .live,
    fundingProgress: 0.5,
    percentFunded: 50
  ),
  TestProject(
    name: "Test Project Three",
    state: .live,
    fundingProgress: 0.5,
    percentFunded: 50
  )
]

let projectsSection = SearchDataSource.Section.projects.rawValue
let emptySection = SearchDataSource.Section.noResults.rawValue
