import Foundation
import Library
import Prelude
import UIKit

private enum Constants {
  static let imageAspectRatio = CGFloat(9.0 / 16.0)
}

final class SimilarProjectsLoadingCollectionViewCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties

  private lazy var imagePlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var titleLabelPlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var subtitleLabelPlaceholder: UIView = { UIView(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()

    self.startLoading()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.layoutPlaceholderViews()
    self.layoutGradientLayers()
  }

  private func layoutPlaceholderViews() {
    self.imagePlaceholder.layoutIfNeeded()
    self.titleLabelPlaceholder.layoutIfNeeded()
    self.subtitleLabelPlaceholder.layoutIfNeeded()

    self.titleLabelPlaceholder.layer.cornerRadius = self.titleLabelPlaceholder.bounds.height / 2
    self.subtitleLabelPlaceholder.layer.cornerRadius = self.subtitleLabelPlaceholder.bounds.height / 2
  }

  override func bindStyles() {
    super.bindStyles()

    applyImageViewStyle(self.imagePlaceholder)

    applyLabelViewStyle(self.titleLabelPlaceholder)
    applyLabelViewStyle(self.subtitleLabelPlaceholder)
  }

  func configureWith(value _: Void) {}

  // MARK: - Subviews

  private func configureViews() {
    self.contentView.addSubview(self.imagePlaceholder)
    self.contentView.addSubview(self.titleLabelPlaceholder)
    self.contentView.addSubview(self.subtitleLabelPlaceholder)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.imagePlaceholder.heightAnchor.constraint(
        equalTo: self.contentView.heightAnchor,
        multiplier: Constants.imageAspectRatio
      ),
      self.imagePlaceholder.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
      self.titleLabelPlaceholder.topAnchor.constraint(
        equalTo: self.imagePlaceholder.bottomAnchor,
        constant: Styles.grid(3)
      ),
      self.titleLabelPlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75),
      self.titleLabelPlaceholder.heightAnchor.constraint(equalToConstant: 20),
      self.subtitleLabelPlaceholder.topAnchor.constraint(
        equalTo: self.titleLabelPlaceholder.bottomAnchor,
        constant: Styles.grid(3)
      ),
      self.subtitleLabelPlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
      self.subtitleLabelPlaceholder.heightAnchor.constraint(equalToConstant: 20)
    ])
  }
}

private func applyImageViewStyle(_ view: UIView) {
  view.backgroundColor = .ksr_support_300
  view.layer.cornerRadius = Styles.grid(2)
  view.clipsToBounds = true
  view.layer.masksToBounds = true
  view.translatesAutoresizingMaskIntoConstraints = false
}

private func applyLabelViewStyle(_ view: UIView) {
  view.backgroundColor = .ksr_support_300
  view.clipsToBounds = true
  view.layer.masksToBounds = true
  view.insetsLayoutMarginsFromSafeArea = false
  view.translatesAutoresizingMaskIntoConstraints = false
}

// MARK: - ShimmerLoading

extension SimilarProjectsLoadingCollectionViewCell: ShimmerLoading {
  func shimmerViews() -> [UIView] {
    return [self.imagePlaceholder]
  }
}
