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
  
  private lazy var headerView: SimilarProjectsCollectionViewHeaderView = SimilarProjectsCollectionViewHeaderView()

  private let dataSource: SimilarProjectsCollectionViewDataSource = SimilarProjectsCollectionViewDataSource()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.collectionView.dataSource = self.dataSource
    self.collectionView.delegate = self
    self.collectionView.registerCellClass(SimilarProjectsCollectionViewCell.self)

    self.configureSubviews()
    self.bindStyles()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    
    collectionView.frame = contentView.bounds
  }

  override func bindStyles() {
    super.bindStyles()
    
    applyCollectionViewStyle(self.collectionView)
    applyCollectionViewLayoutStyle(self.layout)
    applyCollectionViewHeaderStyle(self.headerView)
  }
  
  private func configureSubviews() {
    self.contentView.addSubview(self.collectionView)
  }

  func configureWith(value: Project) {
    self.dataSource.load([value, value, value, value, value])
    self.collectionView.reloadData()
  }
}

private func applyCollectionViewStyle(_ collectionView: UICollectionView) {
  collectionView.showsHorizontalScrollIndicator = false
  collectionView.backgroundColor = .clear
}

private func applyCollectionViewLayoutStyle(_ layout: UICollectionViewFlowLayout) {
  layout.scrollDirection = .horizontal
  layout.itemSize = CGSize(width: 200, height: 400)
  layout.minimumInteritemSpacing = 10
  layout.minimumLineSpacing = 10
}

private func applyCollectionViewHeaderStyle(_ layout: UICollectionReusableView) {
  layout.translatesAutoresizingMaskIntoConstraints = false
}

private func applyTitleLabelStyle(_ label: UILabel) {
  label.text = "Similar projects"
  label.font = .ksr_title3()
  label.translatesAutoresizingMaskIntoConstraints = false
}
