import UIKit

public extension UICollectionView {
  public func registerCellClass <CellClass: UICollectionViewCell> (_ cellClass: CellClass.Type) {
    register(cellClass, forCellWithReuseIdentifier: cellClass.description())
  }

  public func register<T: ValueCell>(_ cellClass: T.Type) {
    self.register(cellClass, forCellWithReuseIdentifier: T.defaultReusableId)
  }

  public func registerCellNibForClass(_ cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")

    register(UINib(nibName: classNameWithoutModule, bundle: nil),
             forCellWithReuseIdentifier: classNameWithoutModule)
  }
}
