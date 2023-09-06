import KsApi
import Library
import Prelude
import UIKit

final class ProjectTabAIGenerationCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private var consentText: String?
  private var detailsText: String?

  private lazy var categoryLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.text .~ Strings.I_plan_to_use_AI_generated_content()
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

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~ .init(leftRight: Styles.projectPageLeftRightInset)

    _ = self.contentView
      |> \.layoutMargins .~
      .init(topBottom: Styles.grid(2), leftRight: Styles.projectPageLeftRightInset)

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.categoryLabel
      |> categoryLabelStyle
  }

  // MARK: - Configuration

  func configureWith(value: ProjectTabGenerationDisclosure) {
    self.rootStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    self.rootStackView.addArrangedSubview(self.categoryLabel)

    if let detailsText = value.details {
      let detailsView = view(
        question: Strings.What_parts_of_your_project_will_use_AI_generated_content(),
        answer: detailsText
      )
      self.rootStackView.addArrangedSubview(detailsView)
    }

    if let consentText = value.consent {
      let consentView = view(
        question: Strings.Do_you_have_the_consent_of_the_owners_of_the_works_used_for_AI(),
        answer: consentText
      )
      self.rootStackView.addArrangedSubview(consentView)
    }
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}

// MARK: - Helpers

private func view(question: String, answer: String) -> UIView {
  let container = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  let questionLabel = UILabel(frame: .zero)
    |> questionLabelStyle
    |> \.text .~ question
  container.addSubview(questionLabel)

  let answerLabel = UILabel(frame: .zero)
    |> answerLabelStyle
    |> \.text .~ answer
  container.addSubview(answerLabel)

  let answerBar = UIView(frame: .zero)
    |> answerBarStyle
  container.addSubview(answerBar)

  NSLayoutConstraint.activate([
    questionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
    questionLabel.trailingAnchor
      .constraint(equalTo: container.trailingAnchor),
    questionLabel.topAnchor.constraint(equalTo: container.topAnchor),

    answerBar.leadingAnchor.constraint(equalTo: questionLabel.leadingAnchor),
    answerBar.widthAnchor.constraint(equalToConstant: Styles.grid(1)),
    answerBar.topAnchor.constraint(equalTo: answerLabel.topAnchor),
    answerBar.bottomAnchor.constraint(equalTo: answerLabel.bottomAnchor),

    answerLabel.leadingAnchor
      .constraint(equalTo: answerBar.trailingAnchor, constant: Styles.grid(2)),
    answerLabel.topAnchor
      .constraint(equalTo: questionLabel.bottomAnchor, constant: Styles.grid(2)),
    answerLabel.trailingAnchor.constraint(equalTo: questionLabel.trailingAnchor),
    answerLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
  ])

  return container
}

// MARK: - Styles

private let categoryLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_title3().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_700
}

private let answerLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_body()
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_700
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let questionLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_body().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_support_700
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let answerBarStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_create_700
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(3)
}
