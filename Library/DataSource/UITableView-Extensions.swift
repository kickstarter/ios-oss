import UIKit

public extension UITableView {
  public func registerHeaderFooterClass(_ headerFooterClass: UITableViewHeaderFooterView.Type) {
    let className = self.classNameWithoutModule(headerFooterClass)
    self.register(headerFooterClass, forHeaderFooterViewReuseIdentifier: className)
  }

  public func registerCellClass(_ cellClass: UITableViewCell.Type) {
    let className = self.classNameWithoutModule(cellClass)
    self.register(cellClass, forCellReuseIdentifier: className)
  }

  // MARK: - Nibs

  public func registerCellNibForClass(_ cellClass: AnyClass) {
    let className = self.classNameWithoutModule(cellClass)
    self.register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: className)
  }

  // Reuse

  public func dequeueReusableHeaderFooterView(withClass headerFooterClass: UITableViewHeaderFooterView.Type) -> UITableViewHeaderFooterView? {
    let className = self.classNameWithoutModule(headerFooterClass)
    return self.dequeueReusableHeaderFooterView(withIdentifier: className)
  }

  public func dequeueReusableCell(withClass cellClass: UITableViewCell.Type, for indexPath: IndexPath) -> UITableViewCell {
    let className = self.classNameWithoutModule(cellClass)
    return self.dequeueReusableCell(withIdentifier: className, for: indexPath)
  }

  // MARK: - Functions

  private func classNameWithoutModule(_ klass: AnyClass) -> String {
    return klass
      .description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")
  }
}
