import KsApi
import Library
import ReactiveSwift
import UIKit

protocol SimilarProjectsCollectionViewCellDelegate: AnyObject {
  func projectTapped(
    _ cell: SimilarProjectsCollectionViewCell,
    atIndex index: IndexPath
  )
}

final class SimilarProjectsCollectionViewCell: UICollectionViewCell, ValueCell {
  weak var delegate: SimilarProjectsCollectionViewCellDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.configureConstraints()
    self.bindStyles()
    self.bindViewModel()

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.projectTapped))
    self.contentView.addGestureRecognizer(tapRecognizer)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindViewModel() {
    super.bindViewModel()
  }

  // MARK: - Accessors

  @objc func projectTapped(indexPath: IndexPath) {
    self.delegate?.projectTapped(self, atIndex: indexPath)
  }

  // MARK: - Functions

  private func configureViews() {}

  private func configureConstraints() {}

  override func bindStyles() {
    super.bindStyles()

    self.backgroundColor = .blue
  }

  func configureWith(value _: Project) {}

  override func prepareForReuse() {
    super.prepareForReuse()
  }
}
