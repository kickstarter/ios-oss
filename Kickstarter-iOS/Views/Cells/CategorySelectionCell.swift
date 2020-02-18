import Library
import Foundation
import KsApi
import UIKit
import Prelude

final class CategorySelectionCell: UITableViewCell, ValueCell {
  private lazy var rootStackView = { UIStackView(frame: .zero) }()
  private lazy var categoryNameLabel = { UILabel() }()
  private let pillDataSource = PillCollectionViewDataSource()
  private lazy var subCatsCollectionView = {
    UICollectionView(
      frame: .zero,
      collectionViewLayout: PillLayout(
        minimumInteritemSpacing: Styles.grid(1),
        minimumLineSpacing: Styles.grid(1),
        sectionInset: UIEdgeInsets(topBottom: Styles.grid(1))
      )
    )
      |> \.contentInsetAdjustmentBehavior .~ UIScrollView.ContentInsetAdjustmentBehavior.always
      |> \.dataSource .~ self.pillDataSource
      |> \.delegate .~ self
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.bindViewModel()
    self.bindStyles()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value category: KsApi.Category) {
    self.categoryNameLabel.text = category.name

    if let subcats = category.subcategories {
      self.pillDataSource.load(subcats.nodes.map { $0.name })
      self.subCatsCollectionView.reloadData()
    }
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([categoryNameLabel, subCatsCollectionView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.subCatsCollectionView.register(PillCell.self)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> \.distribution .~ .fill
      |> \.alignment .~ .fill
  }

  private func setupConstraints() {
    let pillCollectionViewConstraints = [
      self.pillCollectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.pillCollectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.pillCollectionViewHeightConstraint
    ]

    NSLayoutConstraint.activate(pillCollectionViewConstraints)
  }

  private func updateCollectionViewConstraints() {
    self.subCatsCollectionView.layoutIfNeeded()

    self.pillCollectionViewHeightConstraint.constant = self.pillCollectionView.contentSize.height
  }
}


// MARK: - UICollectionViewDelegate

extension CategorySelectionCell: UICollectionViewDelegate {
  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt _: IndexPath
  ) {
    guard let pillCell = cell as? PillCell else { return }

    _ = pillCell.label
      |> \.preferredMaxLayoutWidth .~ collectionView.bounds.width
  }
}
