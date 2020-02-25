import Foundation
import Library
import Prelude

final class CategorySelectionHeaderView: UIView {
  private lazy var imageView = { UIImageView(frame: .zero) } ()
  private lazy var rootStackView = { UIStackView(frame: .zero) }()
  private lazy var stepLabel = { UILabel(frame: .zero) }()
  private lazy var subtitleLabel = { UILabel(frame: .zero) }()
  private lazy var titleLabel = { UILabel(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupViews()
    self.bindStyles()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> \.spacing .~ Styles.grid(2)
      |> \.alignment .~ .leading
      |> UIStackView.lens.layoutMargins .~ .init(top: Styles.grid(4),
                                                 left: Styles.grid(3),
                                                 bottom: 0,
                                                 right: 0)
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.titleLabel
      |> \.font .~ UIFont.ksr_title1().bolded
      |> \.textColor .~ .white
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.text .~ "Which categories interest you?"

    _ = self.subtitleLabel
      |> \.font .~ UIFont.ksr_subhead()
      |> \.textColor .~ .white
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.text .~ "Select at least three from the options below."

    _ = self.stepLabel
      |> \.font .~ UIFont.ksr_footnote()
      |> \.textColor .~ .white
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.text .~ "Step 1 of 2"

    _ = self.imageView
      |> UIImageView.lens.image .~ UIImage(named: "shapes")

  }

  private func setupViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([stepLabel, titleLabel, subtitleLabel, imageView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}
