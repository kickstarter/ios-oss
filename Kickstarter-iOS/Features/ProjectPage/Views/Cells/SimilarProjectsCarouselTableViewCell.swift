import KsApi
import Library
import UIKit

/*
 A container for the Similar Projects Carousel.

 Right now this just contains the projects card, but will eventualy contain the UICollectionView carousel that displays multiple similar project cards.
 */

final class SimilarProjectsCarouselTableViewCell: UITableViewCell, ValueCell {
  private lazy var projectCardView: SimilarProjectsCardView = { SimilarProjectsCardView(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

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

private func applyBaseCellStyle(_ cell: UITableViewCell) {
  cell.contentView.layoutMargins = .init(topBottom: Styles.grid(3), leftRight: Styles.grid(12))
  cell.contentView.preservesSuperviewLayoutMargins = false
  cell.backgroundColor = .ksr_white
  cell.layoutMargins = .init(all: 0.0)
  cell.preservesSuperviewLayoutMargins = false
  cell.selectionStyle = .none
}
