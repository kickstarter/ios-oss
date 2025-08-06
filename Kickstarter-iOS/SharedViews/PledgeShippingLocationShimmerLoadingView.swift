import Foundation
import Library
import Prelude
import UIKit

final class PledgeShippingLocationShimmerLoadingView: UIView {
  // MARK: - Properties

  internal lazy var amountPlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var buttonPlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()

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

    self.layoutGradientLayers()
  }

  override func bindStyles() { super.bindStyles() }

  // MARK: - Subviews

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.buttonPlaceholder, UIView(), self.amountPlaceholder], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.buttonPlaceholder.heightAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.amountPlaceholder.heightAnchor.constraint(equalToConstant: Styles.grid(3)),
      self.buttonPlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
      self.amountPlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2)
    ])
  }
}

// MARK: - ShimmerLoading

extension PledgeShippingLocationShimmerLoadingView: ShimmerLoading {
  func shimmerViews() -> [UIView] {
    return [self.amountPlaceholder, self.buttonPlaceholder]
  }
}
