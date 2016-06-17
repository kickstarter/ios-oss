import XCTest
@testable import Kickstarter_iOS
@testable import Library
import KsApi
import Prelude

internal final class DiscoveryFiltersDataSourceTests: XCTestCase {
  private let topFilters = DiscoveryFiltersDataSource.Section.topFilters.rawValue
  private let categories = DiscoveryFiltersDataSource.Section.categories.rawValue

  private let dataSource = DiscoveryFiltersDataSource()
  private let tableView = UITableView()

  func testLoadTopRows() {
    self.dataSource.load(topRows: [
      SelectableRow(isSelected: false, params: .defaults),
      SelectableRow(isSelected: false, params: .defaults),
      SelectableRow(isSelected: false, params: .defaults),
      SelectableRow(isSelected: false, params: .defaults)
      ]
    )

    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: topFilters))
    XCTAssertEqual("DiscoverySelectableRowCell", self.dataSource.reusableId(item: 0, section: topFilters))
  }

  func testLoadCategories() {
    self.dataSource.load(categoryRows: [
      ExpandableRow(
        isExpanded: false,
        params: .defaults,
        selectableRows: [
          SelectableRow(isSelected: false, params: .defaults),
          SelectableRow(isSelected: false, params: .defaults)
        ]
      ),
      ExpandableRow(
        isExpanded: false,
        params: .defaults,
        selectableRows: [
          SelectableRow(isSelected: false, params: .defaults),
          SelectableRow(isSelected: false, params: .defaults)
        ]
      )
      ])

    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: categories))
    XCTAssertEqual("CategorySeparator", self.dataSource.reusableId(item: 0, section: categories))
    XCTAssertEqual("DiscoveryExpandableRowCell", self.dataSource.reusableId(item: 1, section: categories))
    XCTAssertEqual("DiscoveryExpandableRowCell", self.dataSource.reusableId(item: 2, section: categories))
  }

  func testLoadCategoriesWithExpansion() {
    self.dataSource.load(categoryRows: [
      ExpandableRow(
        isExpanded: false,
        params: .defaults,
        selectableRows: [
          SelectableRow(isSelected: false, params: .defaults),
          SelectableRow(isSelected: false, params: .defaults)
        ]
      ),
      ExpandableRow(
        isExpanded: true,
        params: .defaults,
        selectableRows: [
          SelectableRow(isSelected: false, params: .defaults),
          SelectableRow(isSelected: false, params: .defaults)
        ]
      )
      ])

    XCTAssertEqual(5, self.dataSource.tableView(self.tableView, numberOfRowsInSection: categories))
    XCTAssertEqual("CategorySeparator", self.dataSource.reusableId(item: 0, section: categories))
    XCTAssertEqual("DiscoveryExpandableRowCell", self.dataSource.reusableId(item: 1, section: categories))
    XCTAssertEqual("DiscoveryExpandableRowCell", self.dataSource.reusableId(item: 2, section: categories))
    XCTAssertEqual("DiscoveryExpandedSelectableRowCell",
                   self.dataSource.reusableId(item: 3, section: categories))
    XCTAssertEqual("DiscoveryExpandedSelectableRowCell",
                   self.dataSource.reusableId(item: 4, section: categories))
  }
}
