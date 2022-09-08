import Prelude
import UIKit

class PillLayout: UICollectionViewFlowLayout {
  var shouldInvalidateLayout: Bool = true

  // MARK: - Lifecycle

  required init(
    minimumInteritemSpacing: CGFloat = 0,
    minimumLineSpacing: CGFloat = 0,
    sectionInset: UIEdgeInsets = .zero
  ) {
    super.init()

    _ = self
      |> \.estimatedItemSize .~ UICollectionViewFlowLayout.automaticSize
      |> \.minimumInteritemSpacing .~ minimumInteritemSpacing
      |> \.minimumLineSpacing .~ minimumLineSpacing
      |> \.sectionInset .~ sectionInset
      |> \.sectionInsetReference .~ .fromSafeArea
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let baseAttributes = super.layoutAttributesForElements(in: rect) else { return nil }

    let layoutAttributes = baseAttributes.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }

    guard scrollDirection == .vertical else { return layoutAttributes }

    // Filter attributes to compute only cell attributes
    let cellAttributes = layoutAttributes.filter { $0.representedElementCategory == .cell }

    let dictionary = Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 })

    // Group cell attributes by row (cells with same vertical center) and loop on those groups
    for (_, attributes) in dictionary {
      // Set the initial left inset
      var leftInset = sectionInset.left

      // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
      for attribute in attributes {
        attribute.frame.origin.x = leftInset
        leftInset = attribute.frame.maxX + minimumInteritemSpacing
      }
    }

    return layoutAttributes
  }

  override func invalidateLayout() {
    if self.shouldInvalidateLayout {
      super.invalidateLayout()
    }
  }
}
