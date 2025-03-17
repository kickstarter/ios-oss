import KsApi
import Library
import UIKit

class SimilarProjectsTableViewCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var collectionView: UICollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: layout
  )
  private let layout = UICollectionViewFlowLayout()

  private let dataSource: SimilarProjectsCollectionViewDataSource = SimilarProjectsCollectionViewDataSource()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.collectionView.dataSource = self.dataSource
    self.collectionView.registerCellClass(SimilarProjectsCollectionViewCell.self)

    self.configureSubviews()
    self.bindStyles()
    self.updateConstraints()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    applyBaseCellStyle(self)
    applyTitleLabelStyle(self.titleLabel)
    applyCollectionViewStyle(self.collectionView)
    applyCollectionViewLayoutStyle(self.layout)
  }

  override func systemLayoutSizeFitting(
    _: CGSize,
    withHorizontalFittingPriority _: UILayoutPriority,
    verticalFittingPriority _: UILayoutPriority
  ) -> CGSize {
    self.contentView.frame = self.bounds
    self.contentView.layoutIfNeeded()

    return self.collectionView.contentSize
  }

  private func configureSubviews() {
    self.contentView.addSubview(self.collectionView)
    self.contentView.addSubview(self.titleLabel)
  }

  override func updateConstraints() {
    NSLayoutConstraint.activate([
      self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      self.titleLabel.leadingAnchor.constraint(
        equalTo: self.contentView.leadingAnchor,
        constant: Styles.grid(3)
      ),
      self.collectionView.topAnchor.constraint(
        equalTo: self.titleLabel.bottomAnchor
      ),
      self.collectionView.leadingAnchor.constraint(
        equalTo: self.contentView.leadingAnchor,
        constant: Styles.grid(3)
      ),
      self.collectionView.trailingAnchor.constraint(
        equalTo: self.contentView.trailingAnchor,
        constant: -Styles.grid(3)
      ),
      self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])

    super.updateConstraints()
  }

  func configureWith(value: [any SimilarProject]) {
    self.dataSource.load(value)
    self.collectionView.reloadData()
    self.layoutIfNeeded()
  }
}

// MARK: - Styles

private func applyBaseCellStyle(_ cell: UITableViewCell) {
  cell.contentView.layoutMargins = .init(topBottom: Styles.grid(3), leftRight: Styles.grid(12))
  cell.contentView.preservesSuperviewLayoutMargins = false
  cell.backgroundColor = .ksr_white
  cell.preservesSuperviewLayoutMargins = false
  cell.selectionStyle = .none
}

private func applyCollectionViewStyle(_ collectionView: UICollectionView) {
  collectionView.backgroundColor = .clear
  collectionView.contentInset = .init(all: 0)
  collectionView.showsHorizontalScrollIndicator = false
  collectionView.translatesAutoresizingMaskIntoConstraints = false
}

private func applyCollectionViewLayoutStyle(_ layout: UICollectionViewFlowLayout) {
  layout.scrollDirection = .horizontal
  layout.minimumInteritemSpacing = 10
  layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
}

private func applyTitleLabelStyle(_ label: UILabel) {
  label.text = "Similar projects"
  label.font = .ksr_title3()
  label.translatesAutoresizingMaskIntoConstraints = false
}
