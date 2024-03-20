import Foundation
import Library
import Prelude
import UIKit

public final class RewardsCollectionViewHeaderView: UICollectionReusableView {
  // MARK: - Properties

  private var label: UILabel = { UILabel(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.label.text = Strings.Select_your_reward()
    self.setupSubviews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseStyle

    _ = self.label
      |> labelStyle
  }

  private func setupSubviews() {
    _ = (self.label, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent(priority: .defaultHigh)

    self.label.setContentCompressionResistancePriority(.required, for: .vertical)
    self.label.setContentHuggingPriority(.required, for: .vertical)
  }
}

private let baseStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ .init(
      top: Styles.grid(4),
      left: Styles.grid(3),
      bottom: Styles.grid(1),
      right: Styles.grid(3)
    )
    |> \.backgroundColor .~ .clear
}

private let labelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 1
    |> \.textColor .~ UIColor.ksr_support_700
    |> \.font .~ UIFont.ksr_title2().bolded
}
