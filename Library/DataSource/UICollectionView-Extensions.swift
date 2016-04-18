import UIKit

public extension UICollectionView {
  public func registerCellClass <CellClass: UICollectionViewCell> (cellClass: CellClass.Type) {
    registerClass(cellClass, forCellWithReuseIdentifier: cellClass.description())
  }

  public func registerCellNibForClass(cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .componentsSeparatedByString(".")
      .dropFirst()
      .joinWithSeparator(".")

    registerNib(UINib(nibName: classNameWithoutModule, bundle: nil),
                forCellWithReuseIdentifier: classNameWithoutModule)
  }
}
