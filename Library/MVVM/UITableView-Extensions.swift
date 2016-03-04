import class UIKit.UITableView
import class UIKit.UINib

public extension UITableView {
  func registerCellClass(cellClass: AnyClass) {
    registerClass(cellClass, forCellReuseIdentifier: cellClass.description())
  }

  func registerCellNibForClass(cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .componentsSeparatedByString(".")
      .dropFirst()
      .joinWithSeparator(".")

    registerNib(UINib(nibName: classNameWithoutModule, bundle: nil), forCellReuseIdentifier: classNameWithoutModule)
  }
}
