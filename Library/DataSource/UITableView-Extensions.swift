import UIKit

public extension UITableView {
  public func registerCellClass <CellClass: UITableViewCell> (cellClass: CellClass.Type) {
    registerClass(cellClass, forCellReuseIdentifier: cellClass.description())
  }

  public func registerCellNibForClass(cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .componentsSeparatedByString(".")
      .dropFirst()
      .joinWithSeparator(".")

    registerNib(UINib(nibName: classNameWithoutModule, bundle: nil),
                forCellReuseIdentifier: classNameWithoutModule)
  }
}
