import Library
import Foundation
import KsApi
import UIKit
import Prelude

final class CategorySelectionCell: UITableViewCell, ValueCell {
  private lazy var categoryNameLabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
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

  private var subCatsHeightConstraint: NSLayoutConstraint?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
    self.bindStyles()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    self.updateCollectionViewConstraints()
  }

  func configureWith(value category: KsApi.Category) {
    self.categoryNameLabel.text = category.name

    if let subcats = category.subcategories {
      self.pillDataSource.load(subcats.nodes.map { $0.name })
      self.subCatsCollectionView.reloadData()

      self.updateCollectionViewConstraints()
    }
  }

  private func configureViews() {
    [self.categoryNameLabel, self.subCatsCollectionView].forEach { view in
      _ = (view, self.contentView)
      |> ksr_addSubviewToParent()
    }

    self.subCatsCollectionView.register(PillCell.self)

    self.categoryNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.categoryNameLabel.setContentHuggingPriority(.required, for: .vertical)
    self.subCatsCollectionView.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.subCatsCollectionView
      |> \.backgroundColor .~ .white

    _ = self.categoryNameLabel
      |> \.numberOfLines .~ 1
      |> \.lineBreakMode .~ .byTruncatingTail
      |> \.textColor .~ UIColor.ksr_soft_black
      |> \.font .~ UIFont.ksr_headline()
  }

  private func setupConstraints() {
    self.subCatsHeightConstraint = self.subCatsCollectionView.heightAnchor.constraint(equalToConstant: 0.0)

    self.subCatsHeightConstraint?.priority = .defaultHigh

    let margins = self.contentView.layoutMarginsGuide

    let constraints = [
      self.categoryNameLabel.topAnchor.constraint(equalTo: margins.topAnchor),
      self.categoryNameLabel.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.categoryNameLabel.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.subCatsCollectionView.topAnchor.constraint(equalTo: self.categoryNameLabel.bottomAnchor,
                                                      constant: Styles.grid(2)),
      self.subCatsCollectionView.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.subCatsCollectionView.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.subCatsCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
      self.subCatsHeightConstraint
      ].compact()

    NSLayoutConstraint.activate(constraints)
  }

  private func updateCollectionViewConstraints() {
    self.subCatsCollectionView.layoutIfNeeded()

    self.subCatsHeightConstraint?.constant = self.subCatsCollectionView.contentSize.height

    self.contentView.setNeedsLayout()
    self.contentView.layoutIfNeeded()

    print("CONTENT VIEW HEIGHT \(self.contentView.bounds.height)")
    print("COLLECTION VIEW HEIGHT \(self.subCatsCollectionView.bounds.height)")
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
