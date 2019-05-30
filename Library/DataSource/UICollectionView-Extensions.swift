import UIKit

public extension UICollectionView {
  func registerCellClass<CellClass: UICollectionViewCell>(_ cellClass: CellClass.Type) {
    self.register(cellClass, forCellWithReuseIdentifier: cellClass.description())
  }

  func register<T: ValueCell>(_ cellClass: T.Type) {
    self.register(cellClass, forCellWithReuseIdentifier: T.defaultReusableId)
  }

  func registerCellNibForClass(_ cellClass: AnyClass) {
    let classNameWithoutModule = cellClass
      .description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")

    self.register(
      UINib(nibName: classNameWithoutModule, bundle: nil),
      forCellWithReuseIdentifier: classNameWithoutModule
    )
  }
}
