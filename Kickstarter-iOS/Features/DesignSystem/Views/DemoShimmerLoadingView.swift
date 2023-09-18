import Foundation
import Library
import Prelude
import UIKit

final class DemoShimmerLoadingView: UIView {
  // MARK: - Properties

  private lazy var buttonPlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()

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

    self.layoutGradientLayers()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(1))

    _ = self.buttonPlaceholder
      |> roundedStyle(cornerRadius: Styles.gridHalf(3))
  }

  // MARK: - Subviews

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.buttonPlaceholder], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.buttonPlaceholder.heightAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.buttonPlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor)
    ])
  }
}

// MARK: - ShimmerLoading

extension DemoShimmerLoadingView: ShimmerLoading {
  func shimmerViews() -> [UIView] {
    return [self.buttonPlaceholder]
  }
}
