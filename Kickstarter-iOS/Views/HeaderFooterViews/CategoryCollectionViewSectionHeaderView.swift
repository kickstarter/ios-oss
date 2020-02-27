import Foundation
import Library
import Prelude
import UIKit

public final class CategoryCollectionViewSectionHeaderView: UICollectionReusableView {
  private lazy var label: UILabel = { UILabel(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupSubviews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with value: String) {
    self.label.text = value
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.layoutMargins .~ .init(
        top: Styles.grid(4),
        left: Styles.grid(3),
        bottom: Styles.grid(1),
        right: Styles.grid(3)
      )
      |> \.backgroundColor .~ .white

    _ = self.label
      |> \.numberOfLines .~ 1
      |> \.lineBreakMode .~ .byTruncatingTail
      |> \.textColor .~ UIColor.ksr_soft_black
      |> \.font .~ UIFont.ksr_headline()
  }

  private func setupSubviews() {
    _ = (self.label, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent(priority: .defaultHigh)

    self.label.setContentCompressionResistancePriority(.required, for: .vertical)
    self.label.setContentHuggingPriority(.required, for: .vertical)
  }
}
