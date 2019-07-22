import UIKit

public extension UICollectionView {
  // MARK: - Registration

  func registerCellClass<CellClass: UICollectionViewCell>(_ cellClass: CellClass.Type) {
    self.register(cellClass, forCellWithReuseIdentifier: classNameWithoutModule(cellClass))
  }

  func register<T: ValueCell>(_ cellClass: T.Type) {
    self.register(cellClass, forCellWithReuseIdentifier: T.defaultReusableId)
  }

  func registerCellNibForClass(_ cellClass: AnyClass) {
    let className = classNameWithoutModule(cellClass)

    self.register(UINib(nibName: className, bundle: nil), forCellWithReuseIdentifier: className)
  }

  // MARK: - Reuse

  func dequeueReusableCell(withClass cellClass: UICollectionViewCell.Type, for indexPath: IndexPath)
    -> UICollectionViewCell {
    let className = classNameWithoutModule(cellClass)
    return self.dequeueReusableCell(withReuseIdentifier: className, for: indexPath)
  }
}
