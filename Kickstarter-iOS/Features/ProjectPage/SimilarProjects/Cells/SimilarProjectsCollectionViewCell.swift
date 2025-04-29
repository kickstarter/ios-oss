import KsApi
import Library
import UIKit

protocol SimilarProjectsCollectionViewCellDelegate: AnyObject {
  func didSelectProject(_ project: SimilarProject)
}

/*
 A Collection View Cell for the Similar Projects Carousel.

 Contains a Similar Projects Card UIView that can then be registered and used in a UICollectionView

 */

final class SimilarProjectsCollectionViewCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties

  private lazy var projectCardView: ProjectCardView = { ProjectCardView(frame: .zero) }()

  internal var project: SimilarProject?

  weak var delegate: SimilarProjectsCollectionViewCellDelegate?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindStyles()

    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    self.contentView.isUserInteractionEnabled = true
    self.contentView.addGestureRecognizer(gesture)
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
    self.project = value

    self.layoutIfNeeded()
  }

  override func bindStyles() {
    applyBaseCellStyle(self)
  }

  // MARK: - Accessors

  @objc func handleTap(_: UITapGestureRecognizer) {
    guard let project = project else { return }

    self.delegate?.didSelectProject(project)
  }
}

private func applyBaseCellStyle(_ cell: UICollectionViewCell) {
  cell.contentView.preservesSuperviewLayoutMargins = false
  cell.backgroundColor = .ksr_white
  cell.preservesSuperviewLayoutMargins = false
}

extension SimilarProjectsCollectionViewCell: UIGestureRecognizerDelegate {}
