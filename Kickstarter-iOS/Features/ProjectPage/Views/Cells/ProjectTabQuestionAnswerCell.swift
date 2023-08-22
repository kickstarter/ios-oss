import KsApi
import Library
import Prelude
import UIKit

public enum ProjectTabQuestionAnswerCellStyles {
  public enum Layout {
    public static let stackViewSpacing: CGFloat = Styles.grid(2)
  }
}

final class ProjectTabQuestionAnswerCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel = ProjectTabQuestionAnswerCellViewModel()

  private lazy var questionLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var answerLabel: UILabel = {
    UILabel(frame: .zero)
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
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bindings

  override func bindViewModel() {
    super.bindViewModel()

    self.answerLabel.rac.text = self.viewModel.outputs.answerLabelText
    self.questionLabel.rac.text = self.viewModel.outputs.questionLabelText
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~ .init(
        top: 0,
        left: 0,
        bottom: 0,
        right: self.bounds.size.width + ProjectHeaderCellStyles.Layout.insets
      )

    _ = self.contentView
      |> \.layoutMargins .~
      .init(topBottom: Styles.grid(2), leftRight: Styles.projectPageLeftRightInset)

    _ = self.questionLabel
      |> questionLabelStyle

    _ = self.answerLabel
      |> answerLabelStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Configuration

  func configureWith(value: (String, String)) {
    self.viewModel.inputs.configureWith(value: value)
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.questionLabel, self.answerLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
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

private let questionLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_body().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_700
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ ProjectTabQuestionAnswerCellStyles.Layout.stackViewSpacing
}
