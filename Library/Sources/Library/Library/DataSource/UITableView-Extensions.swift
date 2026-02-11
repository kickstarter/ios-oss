import UIKit

public extension UITableView {
  // MARK: - Registration

  func registerHeaderFooterClass(_ headerFooterClass: UITableViewHeaderFooterView.Type) {
    let className = classNameWithoutModule(headerFooterClass)
    self.register(headerFooterClass, forHeaderFooterViewReuseIdentifier: className)
  }

  func registerCellClass(_ cellClass: UITableViewCell.Type) {
    let className = classNameWithoutModule(cellClass)
    self.register(cellClass, forCellReuseIdentifier: className)
  }

  func registerCellNibForClass(_ cellClass: AnyClass) {
    let className = classNameWithoutModule(cellClass)
    self.register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: className)
  }

  // MARK: - Reuse

  func dequeueReusableHeaderFooterView(withClass headerFooterClass: UITableViewHeaderFooterView.Type)
    -> UITableViewHeaderFooterView? {
    let className = classNameWithoutModule(headerFooterClass)
    return self.dequeueReusableHeaderFooterView(withIdentifier: className)
  }

  func dequeueReusableCell(withClass cellClass: UITableViewCell.Type, for indexPath: IndexPath)
    -> UITableViewCell {
    let className = classNameWithoutModule(cellClass)
    return self.dequeueReusableCell(withIdentifier: className, for: indexPath)
  }
}
