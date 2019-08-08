import Library
import Prelude
import UIKit

final class PillCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties

  private(set) lazy var label = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = self.contentView
      |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.gridHalf(2), leftRight: Styles.gridHalf(3))

    _ = (self.label, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.label
      |> labelStyle
  }

  // MARK: - Configuration

  func configureWith(value: String) {
    _ = self.label
      |> \.text .~ value
  }
}

// MARK: - Styles

private let contentViewStyle: ViewStyle = { view in
  view
    |> checkoutRoundedCornersStyle
    |> \.backgroundColor .~ UIColor.ksr_green_500.withAlphaComponent(0.06)
}

private let labelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ UIColor.ksr_green_500
}
