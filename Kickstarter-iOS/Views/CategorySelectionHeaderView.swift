import Foundation
import Prelude
import Library

final class CategorySelectionHeaderView: UIView {
  private lazy var rootStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel = { UILabel(frame: .zero) }()
  private lazy var subtitleLabel = { UILabel(frame: .zero) }()
  private lazy var imageView = { UIImageView(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupViews()
    self.bindStyles()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> \.spacing .~ Styles.grid(2)
      |> \.alignment .~ .leading

    _ = self.titleLabel
      |> \.font .~ UIFont.ksr_title1()
      |> \.textColor .~ .ksr_soft_black
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.text .~ "Welcome! Let's find you some creative projects to back."

    _ = self.subtitleLabel
      |> \.font .~ UIFont.ksr_body()
      |> \.textColor .~ .ksr_soft_black
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.text .~ "Select at least 5 categories below to get started."

    _ = self.imageView
      |> \.tintColor .~ .ksr_green_500
      |> \.image .~ UIImage(named: "shortcut-icon-k")
  }

  private func setupViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([imageView, titleLabel, subtitleLabel], self.rootStackView)
    |> ksr_addArrangedSubviewsToStackView()
  }
}
