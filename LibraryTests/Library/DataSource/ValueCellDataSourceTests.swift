@testable import Library
import UIKit
import XCTest

internal final class IntTableCell: UITableViewCell, ValueCell {
  internal var value: Int = 0
  internal func configureWith(value: Int) {
    self.value = value
  }
}

internal final class IntCollectionCell: UICollectionViewCell, ValueCell {
  internal var value: Int = 0
  internal func configureWith(value: Int) {
    self.value = value
  }
}

internal final class IntDataSource: ValueCellDataSource {
  internal override func registerClasses(tableView: UITableView?) {
    tableView?.registerCellClass(IntTableCell.self)
  }

  internal override func registerClasses(collectionView: UICollectionView?) {
    collectionView?.registerCellClass(IntCollectionCell.self)
  }
}

internal final class ValueCellDataSourceTests: XCTestCase {
  fileprivate let dataSource = IntDataSource()
  fileprivate let tableView = UITableView()
  fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

  override func setUp() {
    super.setUp()

    self.dataSource.registerClasses(tableView: self.tableView)
    self.dataSource.registerClasses(collectionView: self.collectionView)

    self.dataSource.appendRow(value: 1, cellClass: IntTableCell.self, toSection: 0)
    self.dataSource.appendRow(value: 2, cellClass: IntTableCell.self, toSection: 0)
    self.dataSource.appendSection(values: [1, 2, 3], cellClass: IntTableCell.self)
    self.dataSource.set(values: [1, 2, 3], cellClass: IntTableCell.self, inSection: 5)
  }

  func testTableViewDataSourceMethods() {
    XCTAssertEqual(6, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 4))
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 5))
  }

  func testCollectionViewDataSourceMethods() {
    XCTAssertEqual(6, self.dataSource.numberOfSections(in: self.collectionView))
    XCTAssertEqual(2, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0))
    XCTAssertEqual(3, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 1))
    XCTAssertEqual(0, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 2))
    XCTAssertEqual(0, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 3))
    XCTAssertEqual(0, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 4))
    XCTAssertEqual(3, self.dataSource.collectionView(self.collectionView, numberOfItemsInSection: 5))
  }

  func testSubscript_IndexPath() {
    XCTAssertEqual(1, self.dataSource[IndexPath(item: 0, section: 0)] as? Int)
    XCTAssertEqual(2, self.dataSource[IndexPath(item: 1, section: 0)] as? Int)
    XCTAssertEqual(1, self.dataSource[IndexPath(item: 0, section: 1)] as? Int)
    XCTAssertEqual(2, self.dataSource[IndexPath(item: 1, section: 1)] as? Int)
    XCTAssertEqual(3, self.dataSource[IndexPath(item: 2, section: 1)] as? Int)
    XCTAssertEqual(1, self.dataSource[IndexPath(item: 0, section: 5)] as? Int)
    XCTAssertEqual(2, self.dataSource[IndexPath(item: 1, section: 5)] as? Int)
    XCTAssertEqual(3, self.dataSource[IndexPath(item: 2, section: 5)] as? Int)
  }

  func testSubscript_ItemSection() {
    XCTAssertEqual(1, self.dataSource[itemSection: (0, 0)] as? Int)
    XCTAssertEqual(2, self.dataSource[itemSection: (1, 0)] as? Int)
    XCTAssertEqual(1, self.dataSource[itemSection: (0, 1)] as? Int)
    XCTAssertEqual(2, self.dataSource[itemSection: (1, 1)] as? Int)
    XCTAssertEqual(3, self.dataSource[itemSection: (2, 1)] as? Int)
    XCTAssertEqual(1, self.dataSource[itemSection: (0, 5)] as? Int)
    XCTAssertEqual(2, self.dataSource[itemSection: (1, 5)] as? Int)
    XCTAssertEqual(3, self.dataSource[itemSection: (2, 5)] as? Int)
  }

  func testNumberOfItems() {
    XCTAssertEqual(8, self.dataSource.numberOfItems())
  }

  func testItemAtIndex() {
    XCTAssertEqual(0, self.dataSource.itemIndexAt(IndexPath(item: 0, section: 0)))
    XCTAssertEqual(1, self.dataSource.itemIndexAt(IndexPath(item: 1, section: 0)))
    XCTAssertEqual(2, self.dataSource.itemIndexAt(IndexPath(item: 0, section: 1)))
    XCTAssertEqual(3, self.dataSource.itemIndexAt(IndexPath(item: 1, section: 1)))
    XCTAssertEqual(4, self.dataSource.itemIndexAt(IndexPath(item: 2, section: 1)))
    XCTAssertEqual(5, self.dataSource.itemIndexAt(IndexPath(item: 0, section: 5)))
    XCTAssertEqual(6, self.dataSource.itemIndexAt(IndexPath(item: 1, section: 5)))
    XCTAssertEqual(7, self.dataSource.itemIndexAt(IndexPath(item: 2, section: 5)))
  }

  func testClearValues() {
    self.dataSource.clearValues()
    XCTAssertEqual(0, self.dataSource.numberOfItems())
  }

  func testClearValuesInSection() {
    self.dataSource.clearValues(section: 0)
    XCTAssertEqual(6, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 4))
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 5))
  }

  func testAppendStaticRow() {
    self.dataSource.appendStaticRow(cellIdentifier: "Test", toSection: 0)
    XCTAssertEqual(6, self.dataSource.numberOfSections(in: self.tableView))

    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual("Test", self.dataSource.reusableId(item: 2, section: 0))

    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 3))
    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 4))
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 5))
  }

  func testInsertRow() {
    self.dataSource.clearValues(section: 0)
    // Add 3 rows
    self.dataSource.appendStaticRow(cellIdentifier: "Test", toSection: 0)
    self.dataSource.appendStaticRow(cellIdentifier: "Test", toSection: 0)
    self.dataSource.appendStaticRow(cellIdentifier: "Test", toSection: 0)

    self.dataSource.insertRow(value: 1, cellClass: IntTableCell.self, atIndex: 1, inSection: 0)

    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(1, self.dataSource.itemIndexAt(IndexPath(item: 1, section: 0)))
  }

  func testDeleteRow() {
    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))

    _ = self.dataSource.deleteRow(value: 1, cellClass: IntTableCell.self, atIndex: 1, inSection: 1)

    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
  }

  func testItemsInSection() {
    let items1 = self.dataSource.items(in: 0) as? [(value: Int, reusableId: String)]

    XCTAssertEqual(items1?.compactMap { $0.value }, [1, 2])
    XCTAssertEqual(items1?.compactMap { $0.reusableId }, ["IntTableCell", "IntTableCell"])

    self.dataSource.clearValues()

    let items2 = self.dataSource.items(in: 0) as? [(value: Int, reusableId: String)]

    XCTAssertTrue(items2?.isEmpty ?? false)
  }

  func testPadValuesForSection() {
    let myDataSource = IntDataSource()

    myDataSource.padValuesForSection(0)

    let array = myDataSource.items(in: 0)

    XCTAssertTrue(array.isEmpty)
  }
}
