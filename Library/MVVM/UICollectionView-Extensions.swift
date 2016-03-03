import class UIKit.UICollectionView
import class UIKit.UINib

public extension UICollectionView {
  func registerCellClass(cellClass: AnyClass) {
    registerClass(cellClass, forCellWithReuseIdentifier: cellClass.description())
  }

  func registerCellNibForClass(cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .componentsSeparatedByString(".")
      .dropFirst()
      .joinWithSeparator(".")

    registerNib(UINib(nibName: classNameWithoutModule, bundle: nil), forCellWithReuseIdentifier: classNameWithoutModule)
  }
}
