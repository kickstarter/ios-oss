import Foundation
import Library
import Prelude
import UIKit

private enum Layout {
  enum AvatarView {
    static let minWidth: CGFloat = 40.0
  }
}

final class ProjectCreatorDetailsShimmerLoadingView: UIView {
  // MARK: - Properties

  private lazy var avatarPlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var contentStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var subtitlePlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var subtitleStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titlePlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var titleStackView: UIStackView = { UIStackView(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()

    self.startLoading()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.layoutPlaceholderViews()

    self.layoutGradientLayers()
  }

  private func layoutPlaceholderViews() {
    self.avatarPlaceholder.layoutIfNeeded()
    self.subtitlePlaceholder.layoutIfNeeded()
    self.titlePlaceholder.layoutIfNeeded()

    _ = self.avatarPlaceholder
      |> roundedStyle(cornerRadius: self.avatarPlaceholder.bounds.width / 2)

    _ = self.subtitlePlaceholder
      |> roundedStyle(cornerRadius: self.subtitlePlaceholder.bounds.height / 2)

    _ = self.titlePlaceholder
      |> roundedStyle(cornerRadius: self.titlePlaceholder.bounds.height / 2)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> \.spacing .~ Styles.grid(1)

    _ = self.contentStackView
      |> \.axis .~ .vertical
      |> \.distribution .~ .fillEqually
      |> \.spacing .~ Styles.gridHalf(3)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(1))
  }

  // MARK: - Subviews

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titlePlaceholder, UIView()], self.titleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.subtitlePlaceholder, UIView()], self.subtitleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleStackView, self.subtitleStackView], self.contentStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.avatarPlaceholder, self.contentStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.avatarPlaceholder.widthAnchor.constraint(equalToConstant: Layout.AvatarView.minWidth),
      self.avatarPlaceholder.heightAnchor.constraint(equalTo: self.avatarPlaceholder.widthAnchor),
      self.titlePlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35),
      self.subtitlePlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
    ])
  }
}

// MARK: - ShimmerLoading

extension ProjectCreatorDetailsShimmerLoadingView: ShimmerLoading {
  func shimmerViews() -> [UIView] {
    return [self.avatarPlaceholder, self.titlePlaceholder, self.subtitlePlaceholder]
  }
}
