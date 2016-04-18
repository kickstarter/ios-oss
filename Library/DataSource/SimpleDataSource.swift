import UIKit

// Represents the simplest form of a data source: one that is homogenous with respect to cell views
// and uses `SimpleViewModel` for its data.
public final class SimpleDataSource <
  Cell: ValueCell,
  Value: Any
  where
  Cell.Value == Value>: ValueCellDataSource {

  public override init() {
  }

  public override func registerClasses(collectionView collectionView: UICollectionView?) {
    collectionView?.registerCellNibForClass(Cell.self)
  }

  public override func registerClasses(tableView tableView: UITableView?) {
    tableView?.registerCellNibForClass(Cell.self)
  }

  public func reload(values: [Value]) {
    self.set(values: values, cellClass: Cell.self, inSection: 0)
  }

  public override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    if let cell = cell as? Cell, value = value as? Cell.Value {
      cell.configureWith(value: value)
    }
  }

  public override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
    if let cell = cell as? Cell, value = value as? Cell.Value {
      cell.configureWith(value: value)
    }
  }
}
