import KsApi
import Library
import UIKit

enum SimilarProjectsCellConstants {
  static let spacing: CGFloat = Styles.grid(3)
  static let collectionViewInteritemSpacing: CGFloat = 8.0
  static let collectionViewItemSize = CGSize(width: 327, height: 279)
  static let collectionViewBottomSpacing: CGFloat = -Styles.grid(6)
  static let collectionViewHeight: CGFloat = 350.0
}

class SimilarProjectsTableViewCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let dataSource: SimilarProjectsCollectionViewDataSource = SimilarProjectsCollectionViewDataSource()
  private let layout = UICollectionViewFlowLayout()

  private lazy var collectionView: UICollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: layout
  )

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
      self.titleLabel.topAnchor.constraint(
        equalTo: self.contentView.topAnchor,
        constant: SimilarProjectsCellConstants.spacing
      ),
      self.titleLabel.leadingAnchor.constraint(
        equalTo: self.contentView.leadingAnchor,
        constant: SimilarProjectsCellConstants.spacing
      ),
      self.collectionView.topAnchor.constraint(
        equalTo: self.titleLabel.bottomAnchor,
        constant: SimilarProjectsCellConstants.spacing
      ),
      self.collectionView.leadingAnchor.constraint(
        equalTo: self.contentView.leadingAnchor,
        constant: SimilarProjectsCellConstants.spacing
      ),
      self.collectionView.trailingAnchor.constraint(
        equalTo: self.contentView.trailingAnchor,
        constant: -SimilarProjectsCellConstants.spacing
      ),
      self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])

    super.updateConstraints()
  }

  func configureWith(value: SimilarProjectsState?) {
    guard let state = value else { return }

    switch state {
    case .hidden:
      self.dataSource.load([], isLoading: false)
    case .loading:
      self.dataSource.load([], isLoading: true)

      self.collectionView.isScrollEnabled = false
    case let .loaded(projects):
      self.dataSource.load(projects, isLoading: false)

      self.collectionView.isScrollEnabled = true
    case let .error(error):
      self.dataSource.load([], isLoading: false)
    }

    self.collectionView.reloadData()
    self.layoutIfNeeded()
  }
}

// MARK: - Styles

private func applyBaseCellStyle(_ cell: UITableViewCell) {
  cell.contentView.preservesSuperviewLayoutMargins = false
  cell.backgroundColor = .ksr_white
  cell.preservesSuperviewLayoutMargins = false
  cell.selectionStyle = .none
}

private func applyCollectionViewStyle(_ collectionView: UICollectionView) {
  collectionView.backgroundColor = .clear
  collectionView.showsHorizontalScrollIndicator = false
  collectionView.translatesAutoresizingMaskIntoConstraints = false
}

private func applyCollectionViewLayoutStyle(_ layout: UICollectionViewFlowLayout) {
  layout.scrollDirection = .horizontal
  layout.minimumInteritemSpacing = SimilarProjectsCellConstants.collectionViewInteritemSpacing
  layout.itemSize = SimilarProjectsCellConstants.collectionViewItemSize
}

private func applyTitleLabelStyle(_ label: UILabel) {
  label.text = Strings.Similar_projects()
  label.font = .ksr_title3()
  label.translatesAutoresizingMaskIntoConstraints = false
}
