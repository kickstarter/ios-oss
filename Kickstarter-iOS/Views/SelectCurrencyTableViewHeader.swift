import Library
import Prelude
import Prelude_UIKit
import UIKit

final class SelectCurrencyTableViewHeader: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(self.headerStackView)
    self.headerStackView.constrainEdges(to: self)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.headerImageView
      |> \.contentMode .~ .scaleAspectFill

    _ = self.headerStackView
      |> \.axis .~ .vertical
      |> \.alignment .~ .center
      |> \.spacing .~ Styles.grid(2)
      |> \.layoutMargins .~ .init(
        top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2)
      )
      |> \.isLayoutMarginsRelativeArrangement .~ true

    _ = self.headerLabel
      |> settingsDescriptionLabelStyle
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.backgroundColor .~ .ksr_grey_200
  }

  // MARK: Accessors

  public var text: String? {
    didSet {
      self.headerLabel.text = text
    }
  }

  // MARK: Subviews

  private lazy var headerStackView: UIStackView = {
    return UIStackView(arrangedSubviews: [
      self.headerImageView,
      self.headerLabel
    ])
  }()

  private lazy var headerImageView: UIImageView = {
    UIImageView(image: image(named: "icon--currency-header", inBundle: Bundle.framework))
  }()

  private lazy var headerLabel: UILabel = { UILabel(frame: .zero) }()
}
