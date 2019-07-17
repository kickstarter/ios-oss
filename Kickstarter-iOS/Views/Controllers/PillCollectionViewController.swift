import Library
import Prelude
import UIKit

class PillCollectionViewController: UICollectionViewController {
  // MARK: - Properties

  private let dataSource = PillCollectionViewDataSource()

  // MARK: - Lifecycle

  static func instantiate() -> PillCollectionViewController {
    return PillCollectionViewController(
      collectionViewLayout: PillLayout(
        minimumInteritemSpacing: Styles.grid(1),
        minimumLineSpacing: Styles.grid(1),
        sectionInset: UIEdgeInsets(all: Styles.grid(1))
      )
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.collectionView
      |> \.backgroundColor .~ UIColor.white
      |> \.contentInsetAdjustmentBehavior .~ .always
      |> \.dataSource .~ self.dataSource

    self.collectionView.registerCellClass(PillCell.self)
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    self.collectionView.reloadData()
  }

  // MARK: - Configuration

  func configure(with values: [String]) {
    self.dataSource.load(values)
    self.collectionView.reloadData()
  }

  // MARK: - UICollectionViewDelegate

  override func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
    ) {
    guard let pillCell = cell as? PillCell else { return }

    _ = pillCell.label
      |> \.preferredMaxLayoutWidth .~ collectionView.bounds.width
  }
}
