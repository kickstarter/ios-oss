@testable import Kickstarter_Framework
import KsApi
@testable import Library
import Prelude
import XCTest

internal final class DiscoveryFiltersDataSourceTests: XCTestCase {
  fileprivate let collectionsHeader = DiscoveryFiltersDataSource.Section.collectionsHeader.rawValue
  fileprivate let collections = DiscoveryFiltersDataSource.Section.collections.rawValue
  fileprivate let categoriesHeader = DiscoveryFiltersDataSource.Section.categoriesHeader.rawValue
  fileprivate let categories = DiscoveryFiltersDataSource.Section.categories.rawValue
  fileprivate let favoritesHeader = DiscoveryFiltersDataSource.Section.favoritesHeader.rawValue
  fileprivate let favorites = DiscoveryFiltersDataSource.Section.favorites.rawValue

  fileprivate let dataSource = DiscoveryFiltersDataSource()
  fileprivate let tableView = UITableView()

  func testLoadTopRows() {
    self.dataSource.load(
      topRows: [
        SelectableRow(isSelected: false, params: .defaults),
        SelectableRow(isSelected: false, params: .defaults),
        SelectableRow(isSelected: false, params: .defaults),
        SelectableRow(isSelected: false, params: .defaults)
      ],
      categoryId: nil
    )

    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.collections))
    XCTAssertEqual(
      "DiscoverySelectableRowCell",
      self.dataSource.reusableId(item: 0, section: self.collections)
    )
    XCTAssertEqual(
      1,
      self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.collectionsHeader)
    )
    XCTAssertEqual(
      "DiscoveryFiltersStaticRowCell",
      self.dataSource.reusableId(item: 0, section: self.collectionsHeader)
    )
  }

  func testLoadFavoriteRows() {
    self.dataSource.load(
      favoriteRows: [
        SelectableRow(isSelected: false, params: .defaults),
        SelectableRow(isSelected: false, params: .defaults),
        SelectableRow(isSelected: false, params: .defaults),
        SelectableRow(isSelected: false, params: .defaults)
      ],
      categoryId: nil
    )

    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.favorites))
    XCTAssertEqual("DiscoverySelectableRowCell", self.dataSource.reusableId(item: 0, section: self.favorites))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.favoritesHeader))
    XCTAssertEqual(
      "DiscoveryFiltersStaticRowCell",
      self.dataSource.reusableId(item: 0, section: self.favoritesHeader)
    )
  }

  func testLoadCategories() {
    self.dataSource.load(
      categoryRows: [
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
      ],
      categoryId: nil
    )

    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.categories))
    XCTAssertEqual(
      "DiscoveryExpandableRowCell",
      self.dataSource.reusableId(item: 0, section: self.categories)
    )
    XCTAssertEqual(
      "DiscoveryExpandableRowCell",
      self.dataSource.reusableId(item: 1, section: self.categories)
    )
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.categoriesHeader))
  }

  func testLoadCategoriesWithExpansion() {
    self.dataSource.load(
      categoryRows: [
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
      ],
      categoryId: nil
    )

    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.categories))
    XCTAssertEqual(
      "DiscoveryExpandableRowCell",
      self.dataSource.reusableId(item: 0, section: self.categories)
    )
    XCTAssertEqual(
      "DiscoveryExpandableRowCell",
      self.dataSource.reusableId(item: 1, section: self.categories)
    )
    XCTAssertEqual(
      "DiscoveryExpandedSelectableRowCell",
      self.dataSource.reusableId(item: 2, section: self.categories)
    )
    XCTAssertEqual(
      "DiscoveryExpandedSelectableRowCell",
      self.dataSource.reusableId(item: 3, section: self.categories)
    )
  }

  func testLoadCategoriesLoaderRow() {
    self.dataSource.loadCategoriesLoaderRow()

    let row1 = self.dataSource.deleteCategoriesLoaderRow(self.tableView)

    XCTAssertNotNil(row1)
    XCTAssertEqual(row1?.first?.row, .some(0))
    XCTAssertEqual(row1?.first?.section, .some(DiscoveryFiltersDataSource.Section.categoriesLoader.rawValue))

    let row2 = self.dataSource.deleteCategoriesLoaderRow(self.tableView)

    XCTAssertNil(row2)
  }
}
