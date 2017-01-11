import UIKit

public extension UITableView {
  public func registerCellClass <CellClass: UITableViewCell> (_ cellClass: CellClass.Type) {
    register(cellClass, forCellReuseIdentifier: cellClass.description())
  }

  public func registerCellNibForClass(_ cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")

    register(UINib(nibName: classNameWithoutModule, bundle: nil),
             forCellReuseIdentifier: classNameWithoutModule)
  }
}
