import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol SimilarProjectsCollectionViewCellDelegate: AnyObject {}

final class SimilarProjectsCollectionViewCell: UICollectionViewCell, ValueCell {
  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.configureConstraints()
    self.bindStyles()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindViewModel() {
    super.bindViewModel()
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
