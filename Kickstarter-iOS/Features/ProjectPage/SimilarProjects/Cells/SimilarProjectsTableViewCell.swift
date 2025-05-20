import KsApi
import Library
import UIKit

protocol SimilarProjectsTableViewCellDelegate: AnyObject {
  func didSelectProject(_ project: ProjectCardProperties)
}

enum SimilarProjectsCellConstants {
  static let spacing: CGFloat = Styles.grid(3)
  static let collectionViewInteritemSpacing: CGFloat = 8.0
  static let collectionViewItemSize = CGSize(width: 327, height: 279)
  static let collectionViewBottomSpacing: CGFloat = -Styles.grid(6)
  static let collectionViewHeight: CGFloat = 350.0
}

/*
 Contains the SimilarProjectsCarousel Title and UICollectionView.
 */

final class SimilarProjectsTableViewCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  weak var delegate: SimilarProjectsTableViewCellDelegate?

  private let dataSource: SimilarProjectsCollectionViewDataSource = SimilarProjectsCollectionViewDataSource()
  private let layout = UICollectionViewFlowLayout()

  private lazy var collectionView: UICollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: layout
  )

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  private let pageControl: UIPageControl = { UIPageControl(frame: .zero) }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.bindStyles()
    self.updateConstraints()
    self.setupCollectionView()
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
    applyPageControlStyle(self.pageControl)
  }

  /// UITableViewCells have a hard time adjusting to a nested UICollectionView's contentSize.
  /// This helps make sure that the layout is updated if needed.
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
    self.contentView.addSubview(self.pageControl)
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
      self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
      self.pageControl.topAnchor.constraint(
        equalTo: self.contentView.topAnchor,
        constant: SimilarProjectsCellConstants.spacing
      ),
      self.pageControl.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
      self.pageControl.heightAnchor.constraint(equalToConstant: 30)
    ])

    super.updateConstraints()
  }

  func configureWith(value: SimilarProjectsState?) {
    self.collectionView.isScrollEnabled = false

    guard let state = value else { return }

    switch state {
    case .hidden, .error:
      self.dataSource.load([], isLoading: false)
    case .loading:
      self.dataSource.load([], isLoading: true)
    case let .loaded(projects):
      self.pageControl.numberOfPages = projects.count
      self.dataSource.load(projects, isLoading: false)
      self.collectionView.isScrollEnabled = true
    }

    self.collectionView.reloadData()
    self.layoutIfNeeded()
  }

  private func setupCollectionView() {
    self.collectionView.dataSource = self.dataSource
    self.collectionView.delegate = self
    self.dataSource.delegate = self
    self.collectionView.registerCellClass(SimilarProjectsCollectionViewCell.self)
    self.collectionView.registerCellClass(SimilarProjectsLoadingCollectionViewCell.self)
  }
}

// MARK: - Styles

private func applyBaseCellStyle(_ cell: UITableViewCell) {
  cell.contentView.preservesSuperviewLayoutMargins = false
  cell.backgroundColor = LegacyColors.ksr_white.uiColor()
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

private func applyPageControlStyle(_ pageControl: UIPageControl) {
  pageControl.currentPage = 0
  pageControl.currentPageIndicatorTintColor = LegacyColors.ksr_support_700.uiColor()
  pageControl.pageIndicatorTintColor = LegacyColors.ksr_support_300.uiColor()
  pageControl.hidesForSinglePage = true
  pageControl.isUserInteractionEnabled = false
  pageControl.translatesAutoresizingMaskIntoConstraints = false
}

private func applyTitleLabelStyle(_ label: UILabel) {
  label.text = Strings.Similar_projects()
  label.font = .ksr_title3().bolded
  label.translatesAutoresizingMaskIntoConstraints = false
}

extension SimilarProjectsTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
    self.pageControl.currentPage = Int(pageIndex)
  }
}

extension SimilarProjectsTableViewCell: SimilarProjectsCollectionViewDataSourceDelegate {
  func didSelectProject(_ project: ProjectCardProperties) {
    self.delegate?.didSelectProject(project)
  }
}
