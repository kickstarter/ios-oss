import Foundation
import Library
import Prelude
import UIKit

public final class RewardsWithShippingCollectionViewHeaderView: UICollectionReusableView {
  // MARK: - Properties

  public let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private var label: UILabel = { UILabel(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.label.text = Strings.Select_your_reward()
    self.setupSubviews()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.label
      |> labelStyle
  }

  private func setupSubviews() {
    _ = ([self.label], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent(priority: .defaultHigh)

    self.label.setContentCompressionResistancePriority(.required, for: .vertical)
    self.label.setContentHuggingPriority(.required, for: .vertical)
  }
}

private func baseStyle(_ view: UIView) {
  view.layoutMargins = .init(
    top: Styles.grid(4),
    left: Styles.grid(3),
    bottom: Styles.grid(1),
    right: Styles.grid(3)
  )
  view.backgroundColor = .clear
}

private func rootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = NSLayoutConstraint.Axis.vertical
  stackView.spacing = Styles.grid(2)
}

private func labelStyle(_ label: UILabel) {
  label.numberOfLines = 1
  label.textColor = UIColor.ksr_support_700
  label.font = UIFont.ksr_title2().bolded
}
