import Foundation
import Library
import Prelude

final class CategorySelectionHeaderView: UIView {
  private lazy var imageView = { UIImageView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

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

    _ = self
      |> \.backgroundColor .~ UIColor.ksr_trust_700

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> \.distribution .~ .fill
      |> \.alignment .~ .fill
      |> \.spacing .~ Styles.grid(2)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.titleLabel
      |> \.font .~ UIFont.ksr_title3().bolded
      |> \.textColor .~ .white
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.text .~ "Which categories interest you?"

    _ = self.subtitleLabel
      |> \.font .~ UIFont.ksr_subhead()
      |> \.textColor .~ .white
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.text .~ "Select up to five from the list below."

    _ = self.stepLabel
      |> \.font .~ UIFont.ksr_footnote()
      |> \.textColor .~ .white
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.text .~ "Step 1 of 2"

    _ = self.imageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill
      |> UIImageView.lens.image .~ UIImage(named: "shapes")
  }

  private func setupViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()

    _ = ([stepLabel, titleLabel, subtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.imageView, self)
      |> ksr_addSubviewToParent()

    NSLayoutConstraint.activate([
      self.rootStackView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.rootStackView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.rootStackView.topAnchor.constraint(equalTo: self.topAnchor),
      self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.imageView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.imageView.topAnchor.constraint(equalTo: self.rootStackView.bottomAnchor),
      self.imageView.heightAnchor.constraint(equalToConstant: 44)
    ])
  }
}
