import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class CategorySelectionCell: UITableViewCell, ValueCell {
  private let viewModel: CategorySelectionCellViewModelType = CategorySelectionCellViewModel()
  private lazy var categoryNameLabel = { UILabel(frame: .zero) }()
  private let pillDataSource = PillCollectionViewDataSource()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
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

  private lazy var subCatsHeightConstraint: NSLayoutConstraint = {
    self.subCatsCollectionView.heightAnchor.constraint(equalToConstant: 0)
      |> \.priority .~ .defaultHigh
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupConstraints()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    self.updateCollectionViewConstraints()
  }

  func configureWith(value category: KsApi.Category) {
    self.viewModel.inputs.configure(with: category)
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.categoryNameLabel, self.subCatsCollectionView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.subCatsCollectionView.register(PillCell.self)

    self.categoryNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.categoryNameLabel.setContentHuggingPriority(.required, for: .vertical)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadSubCategories
      .observeForUI()
      .observeValues { [weak self] subcategories in
        guard let self = self else { return }
        self.pillDataSource.load(subcategories)
        self.subCatsCollectionView.reloadData()

        self.updateCollectionViewConstraints()

        self.setNeedsLayout()
    }

    self.categoryNameLabel.rac.text = self.viewModel.outputs.categoryTitleText
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.contentView
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(4))

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> \.spacing .~ Styles.grid(3)

    _ = self.subCatsCollectionView
      |> \.backgroundColor .~ .white

    _ = self.categoryNameLabel
      |> \.numberOfLines .~ 1
      |> \.lineBreakMode .~ .byTruncatingTail
      |> \.textColor .~ UIColor.ksr_soft_black
      |> \.font .~ UIFont.ksr_headline()
  }

  private func setupConstraints() {
    let margins = self.contentView.layoutMarginsGuide

    NSLayoutConstraint.activate([
      self.subCatsCollectionView.widthAnchor.constraint(equalTo: margins.widthAnchor),
      self.subCatsHeightConstraint
    ])
  }

  private func updateCollectionViewConstraints() {
    self.subCatsCollectionView.layoutIfNeeded()

    let contentHeight = self.subCatsCollectionView.contentSize.height

    self.subCatsHeightConstraint.constant = contentHeight
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
