import KsApi
import Library
import Prelude
import UIKit

final class CommentPostFailedCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel = CommentCellViewModel()

  private lazy var bodyTextView: UITextView = { UITextView(frame: .zero) }()
  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var retryButton = { UIButton(frame: .zero)
    |> \.isUserInteractionEnabled .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setupConstraints()
    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.rootStackView
      |> commentCellRootStackViewStyle

    _ = self.bodyTextView
      |> commentBodyTextViewStyle
      |> \.textColor .~ .ksr_support_400

    self.viewModel.inputs.bindStyles()
  }

  // MARK: - Configuration

  internal func configureWith(value: Comment) {
    self.commentCellHeaderStackView
      .configureWith(comment: value)
    self.viewModel.inputs.configureWith(comment: value, project: nil)
  }

  private func configureViews() {
    _ = ([self.commentCellHeaderStackView, self.bodyTextView, self.retryButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - View model

  internal override func bindViewModel() {
    self.bodyTextView.rac.text = self.viewModel.outputs.body

    self.viewModel.outputs.commentStatus
      .observeForUI()
      .observeValues { [weak self] status in
        guard let self = self else { return }
        _ = self.retryButton
          |> status == .retrying ? postingButtonStyle : retryButtonStyle
      }

    self.viewModel.outputs.shouldIndentContent
      .observeForUI()
      .observeValues { shouldIndent in
        guard shouldIndent else { return }

        _ = self.rootStackView
          |> commentCellIndentedRootStackViewStyle
      }
  }
}

// MARK: Styles

private let retryButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens
    .title(for: .normal) %~
    { _ in Strings.Couldnt_post() }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "circle-back")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.tintColor .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(1))
    |> UIButton.lens.contentHorizontalAlignment .~ .left
    |> UIButton.lens.titleLabel.numberOfLines .~ 0
}

private let postingButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Posting() }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "circle-back")?
    .withRenderingMode(.alwaysTemplate)
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_support_400
    |> UIButton.lens.tintColor .~ UIColor.ksr_support_400
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(1))
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}
