import KsApi
import Library
import Prelude
import UIKit

public enum ProjectFAQsCellStyles {
  public enum Layout {
    public static let chevronImageViewWidth: CGFloat = Styles.grid(5)
    public static let cornerRadius: CGFloat = Styles.grid(1)
    public static let stackViewSpacing: CGFloat = Styles.grid(2)
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

  private lazy var updatedLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var updatedLabelContainerView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var updatedLabelStackView = {
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
    self.updatedLabel.rac.text = self.viewModel.outputs.updatedLabelText

    self.viewModel.outputs.configureChevronImageView
      .observeForUI()
      .observeValues { [weak self] isExpanded in
        guard let self = self else { return }

        _ = self.chevronImageView |> isExpanded ?
          chevronUpImageViewStyle : chevronDownImageViewStyle
      }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~ .init(leftRight: Styles.projectPageLeftRightInset)

    _ = self.contentView
      |> \.layoutMargins .~
      .init(topBottom: Styles.grid(2), leftRight: Styles.projectPageLeftRightInset)

    _ = self.answerLabel
      |> answerLabelStyle

    _ = self.answerStackView
      |> answerStackViewStyle

    _ = self.imageViewStackView
      |> imageViewStackViewStyle

    _ = self.questionLabel
      |> questionLabelStyle

    _ = self.questionStackView
      |> questionStackViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.updatedLabel
      |> updatedLabelStyle

    _ = self.updatedLabelContainerView
      |> updatedLabelContainerViewStyle

    _ = self.updatedLabelStackView
      |> updatedLabelStackViewStyle
  }

  // MARK: - Configuration

  func configureWith(value: (ProjectFAQ, Bool)) {
    self.viewModel.inputs.configureWith(value: value)
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.answerLabel, self.updatedLabelStackView], self.answerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([UIView(), self.chevronImageView, UIView()], self.imageViewStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.questionLabel, self.imageViewStackView], self.questionStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.questionStackView, self.answerStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.updatedLabel, self.updatedLabelContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.updatedLabelContainerView, UIView()], self.updatedLabelStackView)
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
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_body()
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_700
}

private let answerStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ ProjectFAQsCellStyles.Layout.stackViewSpacing
}

private let chevronDownImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.backgroundColor .~ .ksr_support_100
    |> \.contentMode .~ .scaleAspectFit
    |> \.image .~ image(named: "icon_chevron_down")
    |> \.layer.cornerRadius .~ ProjectFAQsCellStyles.Layout.cornerRadius
}

private let chevronUpImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.backgroundColor .~ .ksr_support_100
    |> \.contentMode .~ .scaleAspectFit
    |> \.image .~ image(named: "icon_chevron_up")
    |> \.layer.cornerRadius .~ ProjectFAQsCellStyles.Layout.cornerRadius
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
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ ProjectFAQsCellStyles.Layout.stackViewSpacing
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ ProjectFAQsCellStyles.Layout.stackViewSpacing
}

private let updatedLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption2().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_500
}

private let updatedLabelContainerViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_support_100
    |> roundedStyle(cornerRadius: ProjectFAQsCellStyles.Layout.cornerRadius)
}

private let updatedLabelStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ ProjectFAQsCellStyles.Layout.stackViewSpacing
}
