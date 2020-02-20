import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class CategorySelectionCell: UITableViewCell, ValueCell {
  private let viewModel: CategorySelectionCellViewModelType = CategorySelectionCellViewModel()
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
        sectionInset: .init(topBottom: Styles.grid(1))
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

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    self.updateCollectionViewConstraints()

    super.layoutSubviews()

    print("CONTENT Size HEIGHT \(self.subCatsCollectionView.contentSize.height)")
    print("COLLECTION VIEW HEIGHT \(self.subCatsCollectionView.bounds.height)")
  }

//  public override func didMoveToSuperview() {
//    super.didMoveToSuperview()
//
//    self.updateCollectionViewConstraints()
////
////    self.setNeedsLayout()
////    self.layoutIfNeeded()
//  }

  func configureWith(value category: KsApi.Category) {
    self.viewModel.inputs.configure(with: category)
  }

  private func configureViews() {
    [self.categoryNameLabel, self.subCatsCollectionView].forEach { view in
      _ = (view, self.contentView)
        |> ksr_addSubviewToParent()
    }

    self.subCatsCollectionView.register(PillCell.self)

    self.categoryNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.categoryNameLabel.setContentHuggingPriority(.required, for: .vertical)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadSubCategories
      .observeForUI()
      .observeValues { [weak self] subcategories in
        self?.pillDataSource.load(subcategories)
        self?.subCatsCollectionView.reloadData()

        self?.setNeedsLayout()
    }

    self.categoryNameLabel.rac.text = self.viewModel.outputs.categoryTitleText
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.contentView
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(4))

    _ = self.subCatsCollectionView
      |> \.backgroundColor .~ .white

    _ = self.categoryNameLabel
      |> \.numberOfLines .~ 1
      |> \.lineBreakMode .~ .byTruncatingTail
      |> \.textColor .~ UIColor.ksr_soft_black
      |> \.font .~ UIFont.ksr_headline()
  }

  private func setupConstraints() {
    self.subCatsHeightConstraint = self.subCatsCollectionView.heightAnchor.constraint(equalToConstant: 0)
    self.subCatsHeightConstraint?.priority = .defaultHigh

    let margins = self.contentView.layoutMarginsGuide

    let constraints = [
      self.categoryNameLabel.topAnchor.constraint(equalTo: margins.topAnchor),
      self.categoryNameLabel.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.categoryNameLabel.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.subCatsCollectionView.topAnchor.constraint(
        equalTo: self.categoryNameLabel.bottomAnchor,
        constant: Styles.grid(2)
      ),
      self.subCatsCollectionView.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.subCatsCollectionView.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.subCatsCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
      self.subCatsHeightConstraint
    ].compact()

    NSLayoutConstraint.activate(constraints)
  }

  private func updateCollectionViewConstraints() {
    self.subCatsCollectionView.layoutIfNeeded()

    let contentHeight = self.subCatsCollectionView.contentSize.height

    self.subCatsHeightConstraint?.constant = contentHeight

    self.setNeedsLayout()
  }

  override func prepareForReuse() {
    self.subCatsHeightConstraint?.constant = 0
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

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let shouldSelect = self.viewModel.inputs.categorySelected(at: indexPath.row)

    if !shouldSelect {
      collectionView.deselectItem(at: indexPath, animated: true)
    }
  }
}
