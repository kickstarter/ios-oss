import KsApi
import Library
import Prelude
import UIKit

public enum ProjectFAQsCellStyles {
  public enum Layout {
    public static let chevronImageViewWidth: CGFloat = Styles.grid(5)
  }
}

final class ProjectFAQsCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel = ProjectFAQsCellViewModel()

  private lazy var answerLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var answerStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var chevronImageView: UIImageView = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var imageViewStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var questionLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var questionStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
    self.configureConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bindings

  override func bindViewModel() {
    super.bindViewModel()

    self.answerLabel.rac.text = self.viewModel.outputs.answerLabelText
    self.answerStackView.rac.hidden = self.viewModel.outputs.answerStackViewIsHidden
    self.questionLabel.rac.text = self.viewModel.outputs.questionLabelText
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.answerLabel
      |> answerLabelStyle

    _ = self.chevronImageView
      |> chevronImageViewStyle

    _ = self.imageViewStackView
      |> imageViewStackViewStyle

    _ = self.questionLabel
      |> questionLabelStyle

    _ = self.questionStackView
      |> questionStackViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Configuration

  func configureWith(value: ProjectFAQ) {
    self.viewModel.inputs.configureWith(faq: value)
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.answerLabel], self.answerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([UIView(), self.chevronImageView, UIView()], self.imageViewStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.questionLabel, self.imageViewStackView], self.questionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.questionStackView, self.answerStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func configureConstraints() {
    NSLayoutConstraint.activate(
      [
        self.chevronImageView.heightAnchor
          .constraint(equalToConstant: ProjectFAQsCellStyles.Layout.chevronImageViewWidth),
        self.chevronImageView.widthAnchor
          .constraint(equalToConstant: ProjectFAQsCellStyles.Layout.chevronImageViewWidth),
        self.answerStackView.widthAnchor
          .constraint(
            equalTo: self.questionStackView.widthAnchor,
            constant: -ProjectFAQsCellStyles.Layout.chevronImageViewWidth
          )
      ]
    )
  }
}

// MARK: - Styles

private let answerLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_body()
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_700
}

private let chevronImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.backgroundColor .~ .ksr_support_100
    |> \.contentMode .~ .scaleAspectFit
    |> \.image .~ image(named: "icon_chevron_down")
    |> \.layer.cornerRadius .~ Styles.grid(1)
}

private let imageViewStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let questionLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_body().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_700
}

private let questionStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.alignment .~ .top
    |> \.axis .~ .horizontal
    |> \.distribution .~ .fill
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(2)
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.layoutMargins .~ .init(all: Styles.grid(1))
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(2)
}
