import KsApi
import Library
import UIKit

/*
 A Collection View Cell for the Similar Projects Carousel.

 Contains a Similar Projects Card UIView that can then be registered and used in a UICollectionView

 */

final class SimilarProjectsCollectionViewCell: UICollectionViewCell, ValueCell {
  private lazy var projectCardView: SimilarProjectsCardView = { SimilarProjectsCardView(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindStyles()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
  }

  private func configureViews() {
    self.contentView.addSubview(self.projectCardView)

    NSLayoutConstraint.activate([
      self.projectCardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      self.projectCardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.projectCardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
      self.projectCardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])
  }

  // MARK: - Configuration

  func configureWith(value: any SimilarProject) {
    self.projectCardView.configureWith(value: value)

    self.layoutIfNeeded()
  }

  override func bindStyles() {
    applyBaseCellStyle(self)
  }
}

private func applyBaseCellStyle(_ cell: UICollectionViewCell) {
  cell.contentView.layoutMargins = .init(topBottom: Styles.grid(3), leftRight: Styles.grid(12))
  cell.contentView.preservesSuperviewLayoutMargins = false
  cell.backgroundColor = .ksr_white
  cell.layoutMargins = .init(all: 0.0)
  cell.preservesSuperviewLayoutMargins = false
}
