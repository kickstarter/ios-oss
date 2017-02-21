import Foundation
import UIKit

/**
 A type-safe wrapper around a two-dimensional array of values that can be used to provide a data source for
 `UICollectionView`s and `UITableView`s. There is no direct access to the two-dimensional array, and instead
 values can be appended via public methods that make sure the value you are add to the data source matches
 the type of value the table/collection cell can handle.
 */
open class ValueCellDataSource: NSObject, UICollectionViewDataSource, UITableViewDataSource {

  private var values: [[(value: Any, reusableId: String)]] = []

  /**
   Override this method to destructure `cell` and `value` in order to call the `configureWith(value:)` method
   on the cell with the value. This method is called by the internals of `ValueCellDataSource`, it does not
   need to be called directly.

   - parameter cell:  A cell that is about to be displayed.
   - parameter value: A value that is associated with the cell.
   */
  open func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
  }

  /**
   Override this method to destructure `cell` and `value` in order to call the `configureWith(value:)` method
   on the cell with the value. This method is called by the internals of `ValueCellDataSource`, it does not
   need to be called directly.

   - parameter cell:  A cell that is about to be displayed.
   - parameter value: A value that is associated with the cell.
   */
  open func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
  }

  /**
   Override this to perform any registrations of cell classes and nibs. Call this method from your controller
   before the data source is set on the collection view. If you are using prototype cells you do not need
   to call this.

   - parameter collectionView: A collection view that needs to have cells registered.
   */
  open func registerClasses(collectionView: UICollectionView?) {
  }

  /**
   Override this to perform any registrations of cell classes and nibs. Call this method from your controller
   before the data source is set on the table view. If you are using prototype cells you do not need
   to call this.

   - parameter tableView: A table view that needs to have cells registered.
   */
  open func registerClasses(tableView: UITableView?) {
  }

  /**
   Removes all values from the data source.
   */
  public final func clearValues() {
    self.values = [[]]
  }

  /**
   Clears all the values stored in a particular section.

   - parameter section: A section index.
   */
  public final func clearValues(section: Int) {
    self.padValuesForSection(section)
    self.values[section] = []
  }

  /**
   Adds a single value to the end of the section specified.

   - parameter value:     A value to append.
   - parameter cellClass: The type of cell associated with the value.
   - parameter section:   The section to append the value to.
   
   - returns: The index path of the appended row.
   */
  @discardableResult
  public final func appendRow <
    Cell: ValueCell,
    Value: Any>
    (value: Value, cellClass: Cell.Type, toSection section: Int) -> IndexPath
    where
    Cell.Value == Value {
      self.padValuesForSection(section)
      self.values[section].append((value, Cell.defaultReusableId))
      return IndexPath(row: self.values[section].count - 1, section: section)
  }

  /**
   Adds a single row to the end of a section without specifying a value. This can be useful for
   providing static rows.

   - parameter cellIdentifier: The cell identifier of the static row in your table view.
   - parameter section:        The section to append the row to.
   */
  public final func appendStaticRow(cellIdentifier: String, toSection section: Int) {
    self.padValuesForSection(section)
    self.values[section].append(((), cellIdentifier))
  }

  /**
   Sets an entire section of static cells.

   - parameter cellIdentifiers: A list of cell identifiers that represent the rows.
   - parameter section:         The section to replace.
   */
  public final func set(cellIdentifiers: [String], inSection section: Int) {
    self.padValuesForSection(section)
    self.values[section] = cellIdentifiers.map { ((), $0) }
  }

  /**
   Appends a section of values to the end of the data source.

   - parameter values:    An array of values that make up the section.
   - parameter cellClass: The type of cell associated with all the values.
   */
  public final func appendSection <
    Cell: ValueCell,
    Value: Any>
    (values: [Value], cellClass: Cell.Type)
    where
    Cell.Value == Value {

    self.values.append(values.map { ($0, Cell.defaultReusableId) })
  }

  /**
   Replaces a section with values.

   - parameter values:    An array of values to replace the section with.
   - parameter cellClass: The type of cell associated with the values.
   - parameter section:   The section to replace.
   */
  public final func set <
    Cell: ValueCell,
    Value: Any>
    (values: [Value], cellClass: Cell.Type, inSection section: Int)
    where
    Cell.Value == Value {

    self.padValuesForSection(section)
    self.values[section] = values.map { ($0, Cell.defaultReusableId) }
  }

  /**
   Replaces a row with a value.

   - parameter value:     A value to replace the row with.
   - parameter cellClass: The type of cell associated with the value.
   - parameter section:   The section for the row.
   - parameter row:       The row to replace.
   */
  public final func set <
    Cell: ValueCell,
    Value: Any>
    (value: Value, cellClass: Cell.Type, inSection section: Int, row: Int)
    where
    Cell.Value == Value {

    self.values[section][row] = (value, Cell.defaultReusableId)
  }

  /**
   - parameter indexPath: An index path to retrieve a value.

   - returns: The value at the index path given.
   */
  public final subscript(indexPath: IndexPath) -> Any {
    return self.values[indexPath.section][indexPath.item].value
  }

  /**
   - parameter section: The section to retrieve a value.
   - parameter item:    The item to retrieve a value.

   - returns: The value at the section, item given.
   */
  public final subscript(itemSection itemSection: (item: Int, section: Int)) -> Any {
    return self.values[itemSection.section][itemSection.item].value
  }

  /**
   - parameter section: The section to retrieve a value.

   - returns: The array of values in the section.
   */
  public final subscript(section section: Int) -> [Any] {
    return self.values[section].map { $0.value }
  }

  /**
   - returns: The total number of items in the data source.
   */
  public final func numberOfItems() -> Int {
    return self.values.reduce(0) { accum, section in accum + section.count }
  }

  /**
   - parameter indexPath: An index path that we want to convert to a linear index.

   - returns: A linear index representation of the index path.
   */
  public final func itemIndexAt(_ indexPath: IndexPath) -> Int {
    return self.values[0..<indexPath.section]
      .reduce(indexPath.item) { accum, section in accum + section.count }
  }

  // MARK: UICollectionViewDataSource methods

  public final func numberOfSections(in collectionView: UICollectionView) -> Int {
    return self.values.count
  }

  public final func collectionView(_ collectionView: UICollectionView,
                                   numberOfItemsInSection section: Int) -> Int {
    return self.values[section].count
  }

  public final func collectionView(_ collectionView: UICollectionView,
                                   cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let (value, reusableId) = self.values[indexPath.section][indexPath.item]

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableId, for: indexPath)

    self.configureCell(collectionCell: cell, withValue: value)

    return cell
  }

  // MARK: UITableViewDataSource methods

  public final func numberOfSections(in tableView: UITableView) -> Int {
    return self.values.count
  }

  public final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.values[section].count
  }

  public final func tableView(_ tableView: UITableView,
                              cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let (value, reusableId) = self.values[indexPath.section][indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: reusableId, for: indexPath)

    self.configureCell(tableCell: cell, withValue: value)

    return cell
  }

  /**
   - parameter item:    An item index.
   - parameter section: A section index.

   - returns: The resuableId associated with an (item, section) pair. Marked as internal as it's
              only useful for testing.
   */
  internal final func reusableId(item: Int, section: Int) -> String? {
    if !self.values.isEmpty && self.values.count >= section &&
      !self.values[section].isEmpty && self.values[section].count >= item {

      return self.values[section][item].reusableId
    }
    return nil
  }

  /**
   Only useful for testing.

   - parameter itemSection: A pair containing an item index and a section index.

   - returns: The value of Any? type that is contained within the section at the item index.
   */
  internal final subscript(testItemSection itemSection: (item: Int, section: Int)) -> Any? {
    let (item, section) = itemSection

    if !self.values.isEmpty && self.values.count >= section &&
      !self.values[section].isEmpty && self.values[section].count >= item {
      return self.values[itemSection.section][itemSection.item].value
    }
    return nil
  }

  private func padValuesForSection(_ section: Int) {
    guard self.values.count <= section else { return }

    (self.values.count...section).forEach { _ in
      self.values.append([])
    }
  }
}
