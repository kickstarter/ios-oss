import Library
import Prelude
import Prelude_UIKit
import UIKit

final class SelectCurrencyTableViewHeader: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = (self.headerStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.headerImageView
      |> \.contentMode .~ .scaleAspectFill

    _ = self.headerStackView
      |> headerStackViewStyle

    _ = self.headerLabel
      |> settingsDescriptionLabelStyle
      |> headerLabelStyle
  }

  // MARK: - Accessors

  public var text: String? {
    didSet {
      _ = self.headerLabel |> \.text .~ self.text
    }
  }

  // MARK: - Subviews

  private lazy var headerStackView: UIStackView = {
    UIStackView(arrangedSubviews: [
      self.headerImageView,
      self.headerLabel
    ])
  }()

  private lazy var headerImageView: UIImageView = {
    UIImageView(image: image(named: "icon--currency-header", inBundle: Bundle.framework))
  }()

  private lazy var headerLabel: UILabel = { UILabel(frame: .zero) }()
}

// MARK: - Styles

private let headerStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.alignment .~ UIStackView.Alignment.center
    |> \.spacing .~ Styles.grid(2)
    |> \.layoutMargins .~ UIEdgeInsets(
      top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2)
    )
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let headerLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ UIColor.ksr_support_400
    |> \.backgroundColor .~ UIColor.ksr_support_100
}
