import class Foundation.NSIndexPath
import class Foundation.NSObject
import protocol UIKit.UICollectionViewDataSource
import protocol UIKit.UITableViewDataSource
import class UIKit.UICollectionViewCell
import class UIKit.UITableViewCell
import class UIKit.UICollectionView
import class UIKit.UITableView

public protocol CellType {
  static var defaultReusableId: String { get }
}
extension UICollectionViewCell: CellType {}
extension UITableViewCell: CellType {}

public class MVVMDataSource: NSObject, UICollectionViewDataSource, UITableViewDataSource {
  private var data = [[(viewModel: AnyObject, reusableId: String)]]()

  // Override this to check the types of `cell` and `viewModel` and configure the cell accordingly.
  public func configureCell(collectionCell cell: UICollectionViewCell, withViewModel viewModel: AnyObject) {
  }

  // Override this to check the types of `cell` and `viewModel` and configure the cell accordingly.
  public func configureCell(tableCell cell: UITableViewCell, withViewModel viewModel: AnyObject) {
  }

  // Override this to perform any registrations of cell classes and nibs. Also call this method
  // before setting the data source of your collection view.
  public func registerClasses(collectionView collectionView: UICollectionView?) {
  }

  // Override this to perform any registrations of cell classes and nibs. Also call this method
  // before setting the data source of your table view.
  public func registerClasses(tableView tableView: UITableView?) {
  }

  // Clear all data from the data source
  public final func clearData() {
    self.data = [[]]
  }

  // Add a row of data to a section.
  public final func appendRowData <
    Cell: CellType,
    ViewModel: AnyObject
    where
    Cell: ViewModeledCellType,
    ViewModel: ViewModelType,
    Cell.ViewModel == ViewModel>
    (viewModel: ViewModel, cellClass: Cell.Type, toSection section: Int) {

      padDataForSection(section)
      self.data[section].append( (viewModel, Cell.defaultReusableId) )
  }

  // Add a homogenous section of data.
  public final func appendSectionData <
    Cell: CellType,
    ViewModel: AnyObject
    where
    Cell: ViewModeledCellType,
    ViewModel: ViewModelType,
    Cell.ViewModel == ViewModel>
    (viewModels: [ViewModel], cellClass: Cell.Type) {

      self.data.append(viewModels.map { ($0, Cell.defaultReusableId) })
  }

  // Replace the entirety of a section with homogenous data.
  public final func setData <
    Cell: CellType,
    ViewModel: AnyObject
    where
    Cell: ViewModeledCellType,
    ViewModel: ViewModelType,
    Cell.ViewModel == ViewModel>
    (viewModels: [ViewModel], cellClass: Cell.Type, inSection section: Int) {

      padDataForSection(section)
      self.data[section] = viewModels.map { ($0, Cell.defaultReusableId) }
  }

  /// Get the data value at a specific `indexPath`.
  public final subscript(indexPath: NSIndexPath) -> AnyObject {
    return self.data[indexPath.section][indexPath.item].viewModel
  }

  /// Get the data value at a specific section+item combo.
  public final subscript(itemSection: (section: Int, item: Int)) -> AnyObject {
    return self.data[itemSection.section][itemSection.item].viewModel
  }

  public final func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return self.data.count
  }

  public final func collectionView(collectionView: UICollectionView,
                                   numberOfItemsInSection section: Int) -> Int {
    return self.data[section].count
  }

  public final var numberOfItems: Int {
    return self.data.reduce(0) { accum, section in accum + section.count }
  }

  public final func collectionView(collectionView: UICollectionView,
                                   cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let (viewModel, reusableId) = self.data[indexPath.section][indexPath.item]

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableId, forIndexPath: indexPath)

    self.configureCell(collectionCell: cell, withViewModel: viewModel)

    return cell
  }

  public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.data.count
  }

  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.data[section].count
  }

  public func tableView(tableView: UITableView,
                        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let (viewModel, reusableId) = self.data[indexPath.section][indexPath.row]

    let cell = tableView.dequeueReusableCellWithIdentifier(reusableId, forIndexPath: indexPath)

    self.configureCell(tableCell: cell, withViewModel: viewModel)

    return cell
  }

  private func padDataForSection(section: Int) {
    guard self.data.count <= section else { return }

    (self.data.count...section).forEach { _ in
      self.data.append([])
    }
  }
}
